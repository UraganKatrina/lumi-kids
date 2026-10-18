import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/task.dart';
import '../domain/task_parser.dart';

/// Источник заданий. Сейчас — встроенный стартовый пакет; позже добавятся
/// скачанные пакеты с сервера.
abstract interface class ContentRepository {
  Future<List<LearningTask>> loadTasks();
}

class AssetContentRepository implements ContentRepository {
  AssetContentRepository({
    required this.appVersion,
    AssetBundle? bundle,
    this.packPath = 'assets/content/starter_pack.json',
  }) : _bundle = bundle ?? rootBundle;

  final String appVersion;
  final String packPath;
  final AssetBundle _bundle;

  @override
  Future<List<LearningTask>> loadTasks() async {
    final raw = await _bundle.loadString(packPath);
    final pack = jsonDecode(raw) as Map<String, Object?>;
    return TaskParser(appVersion: appVersion).parsePack(pack);
  }
}
