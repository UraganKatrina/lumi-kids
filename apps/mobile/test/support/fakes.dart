import 'dart:convert';
import 'dart:io';

import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/features/content_library/data/content_repository.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/content_library/domain/task_parser.dart';
import 'package:lumi_kids/features/progress/domain/progress.dart';

Map<String, Object?> loadStarterPackJson() =>
    jsonDecode(File('assets/content/starter_pack.json').readAsStringSync())
        as Map<String, Object?>;

class FileContentRepository implements ContentRepository {
  @override
  Future<List<LearningTask>> loadTasks() async =>
      TaskParser(appVersion: appVersion).parsePack(loadStarterPackJson());
}

class InMemoryProgressRepository implements ProgressRepository {
  final List<AttemptRecord> attempts = [];

  @override
  Future<void> saveAttempt(AttemptRecord attempt) async =>
      attempts.add(attempt);

  @override
  Future<Map<String, int>> bestStarsByTask() async {
    final best = <String, int>{};
    for (final a in attempts) {
      if ((best[a.taskId] ?? -1) < a.stars) best[a.taskId] = a.stars;
    }
    return best;
  }
}
