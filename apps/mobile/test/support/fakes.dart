import 'dart:convert';
import 'dart:io';

import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/features/content_library/data/content_repository.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/content_library/domain/task_parser.dart';
import 'package:lumi_kids/features/profiles/domain/child_profile.dart';
import 'package:lumi_kids/features/progress/domain/progress.dart';

Map<String, Object?> loadStarterPackJson() =>
    jsonDecode(File('assets/content/starter_pack.json').readAsStringSync())
        as Map<String, Object?>;

List<LearningTask> loadStarterTasks() =>
    TaskParser(appVersion: appVersion).parsePack(loadStarterPackJson());

class FileContentRepository implements ContentRepository {
  @override
  Future<List<LearningTask>> loadTasks() async => loadStarterTasks();
}

class InMemoryProgressRepository implements ProgressRepository {
  final List<AttemptRecord> attempts = [];

  @override
  Future<void> saveAttempt(AttemptRecord attempt) async =>
      attempts.add(attempt);

  @override
  Future<Map<String, int>> bestStarsByTask(String childId) async {
    final best = <String, int>{};
    for (final a in attempts.where((a) => a.childId == childId)) {
      if ((best[a.taskId] ?? -1) < a.stars) best[a.taskId] = a.stars;
    }
    return best;
  }

  @override
  Future<List<AttemptRecord>> history(String childId, {int limit = 30}) async {
    final mine = attempts.where((a) => a.childId == childId).toList()
      ..sort((a, b) => b.finishedAt.compareTo(a.finishedAt));
    return mine.take(limit).toList();
  }
}

class InMemoryProfileRepository implements ProfileRepository {
  InMemoryProfileRepository(this.progress, [List<ChildProfile>? initial])
    : profiles = [...?initial],
      activeId = initial?.firstOrNull?.id;

  final InMemoryProgressRepository progress;
  final List<ChildProfile> profiles;
  String? activeId;

  @override
  Future<List<ChildProfile>> loadAll() async => [...profiles];

  @override
  Future<void> save(ChildProfile profile) async {
    final i = profiles.indexWhere((p) => p.id == profile.id);
    if (i >= 0) {
      profiles[i] = profile;
    } else {
      profiles.add(profile);
    }
  }

  @override
  Future<void> delete(String childId) async {
    profiles.removeWhere((p) => p.id == childId);
    progress.attempts.removeWhere((a) => a.childId == childId);
    if (activeId == childId) activeId = null;
  }

  @override
  Future<void> deleteEverything() async {
    profiles.clear();
    progress.attempts.clear();
    activeId = null;
  }

  @override
  Future<String?> activeChildId() async => activeId;

  @override
  Future<void> setActiveChild(String childId) async => activeId = childId;
}
