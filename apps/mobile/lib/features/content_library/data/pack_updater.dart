import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/task_parser.dart';
import 'pack_store.dart';

enum PackUpdateResult {
  /// Скачан новый пакет; он откроется при следующем запуске.
  updated,
  upToDate,

  /// Адрес сервера не задан при сборке.
  notConfigured,

  /// Нет сети или сервер недоступен: работаем на том, что есть.
  offline,

  /// Пакет пришёл повреждённым или непригодным и не сохранён.
  rejected,
}

/// Проверяет, нет ли на сервере нового пакета заданий.
///
/// В запросе нет ничего о ребёнке и устройстве: только адрес пакета и
/// хэш уже скачанного (чтобы сервер мог ответить «не изменилось»).
class PackUpdater {
  PackUpdater({
    required this.baseUrl,
    required this.client,
    required this.store,
    required this.appVersion,
    this.timeout = const Duration(seconds: 20),
  });

  final String baseUrl;
  final http.Client client;
  final PackStore store;
  final String appVersion;
  final Duration timeout;

  Future<PackUpdateResult> check() async {
    if (baseUrl.isEmpty) return PackUpdateResult.notConfigured;
    final current = await store.read();
    final http.Response response;
    try {
      response = await client
          .get(
            Uri.parse('$baseUrl/v1/content/packs/latest'),
            headers: {
              if (current != null) 'If-None-Match': '"${current.sha256}"',
            },
          )
          .timeout(timeout);
    } on Exception {
      return PackUpdateResult.offline;
    }
    if (response.statusCode == 304) return PackUpdateResult.upToDate;
    if (response.statusCode != 200) return PackUpdateResult.offline;

    final hash = sha256Hex(response.bodyBytes);
    if (response.headers['x-pack-sha256'] != hash) {
      return PackUpdateResult.rejected;
    }
    try {
      final json = utf8.decode(response.bodyBytes);
      final pack = jsonDecode(json) as Map<String, Object?>;
      final version = pack['packVersion'] as int;
      if (current != null && version <= current.version) {
        return PackUpdateResult.upToDate;
      }
      // Пакет, из которого эта версия приложения не может показать ни одного
      // задания, не заменяет рабочий.
      if (TaskParser(appVersion: appVersion).parsePack(pack).isEmpty) {
        return PackUpdateResult.rejected;
      }
      await store.write(StoredPack(version: version, sha256: hash, json: json));
      return PackUpdateResult.updated;
    } on FormatException {
      return PackUpdateResult.rejected;
    } on TypeError {
      return PackUpdateResult.rejected;
    }
  }
}
