import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/features/content_library/data/content_repository.dart';
import 'package:lumi_kids/features/content_library/data/pack_store.dart';
import 'package:lumi_kids/features/content_library/data/pack_updater.dart';

import '../../support/fakes.dart';

/// Пакет с сервера: стартовые задания под новой версией.
String serverPack(int version) =>
    jsonEncode({...loadStarterPackJson(), 'packVersion': version});

http.Response packResponse(String body, {String? hash}) {
  final bytes = utf8.encode(body);
  return http.Response.bytes(
    bytes,
    200,
    headers: {'x-pack-sha256': hash ?? sha256Hex(bytes)},
  );
}

class _FileBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async =>
      ByteData.sublistView(Uint8List.fromList(File(key).readAsBytesSync()));
}

void main() {
  late InMemoryPackStore store;
  final requests = <http.Request>[];

  PackUpdater updater(
    Future<http.Response> Function(http.Request) handler, {
    String baseUrl = 'https://api.example',
  }) => PackUpdater(
    baseUrl: baseUrl,
    client: MockClient((request) {
      requests.add(request);
      return handler(request);
    }),
    store: store,
    appVersion: appVersion,
  );

  setUp(() {
    store = InMemoryPackStore();
    requests.clear();
  });

  test('без адреса сервера сеть не трогаем', () async {
    final result = await updater(
      (_) async => throw StateError('нельзя'),
      baseUrl: '',
    ).check();
    expect(result, PackUpdateResult.notConfigured);
    expect(requests, isEmpty);
  });

  test('новый пакет скачивается, проверяется и сохраняется', () async {
    final body = serverPack(5);
    final result = await updater((_) async => packResponse(body)).check();

    expect(result, PackUpdateResult.updated);
    expect(store.pack!.version, 5);
    expect(store.pack!.json, body);
    expect(
      requests.single.url.toString(),
      'https://api.example/v1/content/packs/latest',
    );
    // Ничего лишнего о ребёнке или устройстве в запросе нет.
    expect(requests.single.headers.keys, isNot(contains('if-none-match')));
    expect(requests.single.body, isEmpty);
  });

  test('если пакет не изменился, сервер отвечает 304', () async {
    final body = serverPack(5);
    store.pack = StoredPack(
      version: 5,
      sha256: sha256Hex(utf8.encode(body)),
      json: body,
    );
    final result = await updater((_) async => http.Response('', 304)).check();

    expect(result, PackUpdateResult.upToDate);
    expect(requests.single.headers['If-None-Match'], '"${store.pack!.sha256}"');
  });

  test('повреждённый пакет не сохраняется', () async {
    final result = await updater(
      (_) async => packResponse(serverPack(5), hash: 'f' * 64),
    ).check();
    expect(result, PackUpdateResult.rejected);
    expect(store.pack, isNull);
  });

  test('пакет без пригодных заданий не заменяет рабочий', () async {
    final empty = jsonEncode({
      'packVersion': 9,
      'schemaVersion': 1,
      'tasks': [],
    });
    expect(
      await updater((_) async => packResponse(empty)).check(),
      PackUpdateResult.rejected,
    );
    expect(
      await updater((_) async => packResponse('{не json')).check(),
      PackUpdateResult.rejected,
    );
    expect(store.pack, isNull);
  });

  test('старый пакет не заменяет более новый', () async {
    store.pack = StoredPack(version: 7, sha256: 'x', json: serverPack(7));
    final result = await updater((_) async => packResponse(serverPack(6)))
        .check();
    expect(result, PackUpdateResult.upToDate);
    expect(store.pack!.version, 7);
  });

  test('без сети и при ошибке сервера — работаем дальше', () async {
    expect(
      await updater((_) async => throw const SocketException('нет сети'))
          .check(),
      PackUpdateResult.offline,
    );
    expect(
      await updater((_) async => http.Response('oops', 503)).check(),
      PackUpdateResult.offline,
    );
  });

  group('источник заданий', () {
    PackContentRepository repo() => PackContentRepository(
      appVersion: appVersion,
      store: store,
      bundle: _FileBundle(),
    );

    test('без скачанного пакета — встроенный', () async {
      final content = await repo().load();
      expect(content.source.downloaded, isFalse);
      expect(content.tasks, hasLength(loadStarterTasks().length));
    });

    test('скачанный пакет важнее встроенного', () async {
      final body = jsonEncode({
        ...loadStarterPackJson(),
        'packVersion': 3,
        'tasks': (loadStarterPackJson()['tasks']! as List).take(2).toList(),
      });
      store.pack = StoredPack(version: 3, sha256: 'x', json: body);
      final content = await repo().load();
      expect(content.source.downloaded, isTrue);
      expect(content.source.version, 3);
      expect(content.tasks, hasLength(2));
    });

    test('нечитаемый скачанный пакет — снова встроенный', () async {
      store.pack = const StoredPack(version: 3, sha256: 'x', json: '{');
      expect((await repo().load()).source.downloaded, isFalse);
    });
  });

  group('файл пакета', () {
    late Directory dir;
    setUp(() => dir = Directory.systemTemp.createTempSync('lumi_pack'));
    tearDown(() => dir.deleteSync(recursive: true));

    test('записывается и читается целиком', () async {
      final files = FilePackStore(() async => Directory('${dir.path}/content'));
      expect(await files.read(), isNull);
      final body = serverPack(4);
      await files.write(
        StoredPack(
          version: 4,
          sha256: sha256Hex(utf8.encode(body)),
          json: body,
        ),
      );
      final read = await files.read();
      expect(read!.version, 4);
      expect(read.json, body);
    });

    test('испорченный файл не читается', () async {
      final files = FilePackStore(() async => dir);
      final body = serverPack(4);
      await files.write(
        StoredPack(
          version: 4,
          sha256: sha256Hex(utf8.encode(body)),
          json: body,
        ),
      );
      File('${dir.path}/content_pack.json').writeAsStringSync('{"tasks": []}');
      expect(await files.read(), isNull);
    });
  });
}
