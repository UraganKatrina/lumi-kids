import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Скачанный пакет: JSON ровно в том виде, как пришёл, и его хэш.
class StoredPack {
  const StoredPack({
    required this.version,
    required this.sha256,
    required this.json,
  });

  final int version;
  final String sha256;
  final String json;
}

abstract interface class PackStore {
  /// null — пакета нет или файл повреждён.
  Future<StoredPack?> read();

  Future<void> write(StoredPack pack);
}

String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

/// Пакет в каталоге приложения. Запись через временный файл: если телефон
/// выключится посреди записи, останется прежний целый пакет.
class FilePackStore implements PackStore {
  FilePackStore(this._directory);

  final Future<Directory> Function() _directory;

  Future<File> _file(String name) async =>
      File('${(await _directory()).path}/$name');

  @override
  Future<StoredPack?> read() async {
    try {
      final meta = await _file('content_pack.meta.json');
      final body = await _file('content_pack.json');
      if (!await meta.exists() || !await body.exists()) return null;
      final info =
          jsonDecode(await meta.readAsString()) as Map<String, Object?>;
      final json = await body.readAsString();
      final hash = info['sha256'] as String;
      if (sha256Hex(utf8.encode(json)) != hash) return null;
      return StoredPack(
        version: info['version'] as int,
        sha256: hash,
        json: json,
      );
    } on Object {
      // Повреждённый файл не должен ломать запуск: вернёмся к встроенному пакету.
      return null;
    }
  }

  @override
  Future<void> write(StoredPack pack) async {
    final dir = await _directory();
    await dir.create(recursive: true);
    Future<void> replace(String name, String content) async {
      final tmp = File('${dir.path}/$name.tmp');
      await tmp.writeAsString(content, flush: true);
      await tmp.rename('${dir.path}/$name');
    }

    // Сначала тело, потом описание: описание без тела не появится.
    await replace('content_pack.json', pack.json);
    await replace(
      'content_pack.meta.json',
      jsonEncode({'version': pack.version, 'sha256': pack.sha256}),
    );
  }
}
