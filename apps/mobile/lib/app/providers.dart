import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/age_routes/domain/age_program.dart';
import '../features/content_library/data/content_repository.dart';
import '../features/content_library/domain/task.dart';
import '../features/progress/data/drift_progress_repository.dart';
import '../features/progress/data/progress_database.dart';
import '../features/progress/data/settings_repository.dart';
import '../features/progress/domain/progress.dart';
import '../features/recommendations/domain/recommender.dart';

/// Должна совпадать с `version` в pubspec.yaml (проверяется тестом).
const appVersion = '0.2.0';

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

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(progressDatabaseProvider)),
);

final bestStarsProvider = FutureProvider<Map<String, int>>(
  (ref) => ref.watch(progressRepositoryProvider).bestStarsByTask(),
);

/// Выбранная возрастная программа; null — ещё не выбрана.
final ageProgramProvider = FutureProvider<AgeProgram?>((ref) async {
  final code = await ref
      .watch(settingsRepositoryProvider)
      .read(SettingsRepository.ageProgramKey);
  return AgeProgram.fromCode(code);
});

Future<void> chooseAgeProgram(WidgetRef ref, AgeProgram program) async {
  await ref
      .read(settingsRepositoryProvider)
      .write(SettingsRepository.ageProgramKey, program.code);
  ref.invalidate(ageProgramProvider);
}

/// Задания, подходящие выбранному возрасту.
final ageTasksProvider = FutureProvider<List<LearningTask>>((ref) async {
  final tasks = await ref.watch(tasksProvider.future);
  final program = await ref.watch(ageProgramProvider.future);
  if (program == null) return tasks;
  return tasks.where(program.fits).toList();
});

final recommendedTaskProvider = FutureProvider<LearningTask?>((ref) async {
  final tasks = await ref.watch(ageTasksProvider.future);
  final stars = await ref.watch(bestStarsProvider.future);
  return recommendNext(tasks, stars);
});
