import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/content_library/data/content_repository.dart';
import '../features/content_library/domain/task.dart';
import '../features/progress/data/drift_progress_repository.dart';
import '../features/progress/data/progress_database.dart';
import '../features/progress/domain/progress.dart';

/// Должна совпадать с `version` в pubspec.yaml (проверяется тестом).
const appVersion = '0.1.0';

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => AssetContentRepository(appVersion: appVersion),
);

final tasksProvider = FutureProvider<List<LearningTask>>(
  (ref) => ref.watch(contentRepositoryProvider).loadTasks(),
);

final progressDatabaseProvider = Provider<ProgressDatabase>((ref) {
  final db = ProgressDatabase.onDevice();
  ref.onDispose(db.close);
  return db;
});

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => DriftProgressRepository(ref.watch(progressDatabaseProvider)),
);

final bestStarsProvider = FutureProvider<Map<String, int>>(
  (ref) => ref.watch(progressRepositoryProvider).bestStarsByTask(),
);
