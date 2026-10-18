import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/task.dart';
import '../domain/task_parser.dart';
import 'pack_store.dart';

/// Откуда взяты задания: для кабинета родителя.
class ContentSource {
  const ContentSource({required this.downloaded, required this.version});

  final bool downloaded;
  final int version;

  String get label => downloaded
      ? 'пакет №$version с сервера'
      : 'встроенный пакет (версия $version)';
}

class LoadedContent {
  const LoadedContent({required this.tasks, required this.source});

  final List<LearningTask> tasks;
  final ContentSource source;
}

/// Источник заданий: скачанный пакет, а если его нет или он не читается —
/// встроенный стартовый пакет. Приложение работает и без сети.
abstract interface class ContentRepository {
  Future<LoadedContent> load();
}

class PackContentRepository implements ContentRepository {
  PackContentRepository({
    required this.appVersion,
    this.store,
    AssetBundle? bundle,
    this.packPath = 'assets/content/starter_pack.json',
  }) : _bundle = bundle ?? rootBundle;

  final String appVersion;
  final PackStore? store;
  final String packPath;
  final AssetBundle _bundle;

  @override
  Future<LoadedContent> load() async {
    final stored = await store?.read();
    if (stored != null) {
      try {
        final tasks = _parse(stored.json);
        if (tasks.isNotEmpty) {
          return LoadedContent(
            tasks: tasks,
            source: ContentSource(downloaded: true, version: stored.version),
          );
        }
      } on FormatException {
        // Падаем обратно на встроенный пакет.
      } on TypeError {
        // То же.
      }
    }
    final raw = await _bundle.loadString(packPath);
    return LoadedContent(
      tasks: _parse(raw),
      source: ContentSource(
        downloaded: false,
        version:
            (jsonDecode(raw) as Map<String, Object?>)['packVersion'] as int,
      ),
    );
  }

  List<LearningTask> _parse(String raw) =>
      TaskParser(appVersion: appVersion)
          .parsePack(jsonDecode(raw) as Map<String, Object?>);
}
