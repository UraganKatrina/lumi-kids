import 'dart:io';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../features/age_routes/domain/age_program.dart';
import '../features/content_library/data/content_repository.dart';
import '../features/content_library/data/pack_store.dart';
import '../features/content_library/data/pack_updater.dart';
import '../features/content_library/domain/task.dart';
import '../features/parent_area/domain/parental_gate.dart';
import '../features/profiles/data/drift_profile_repository.dart';
import '../features/profiles/domain/child_profile.dart';
import '../features/progress/data/drift_progress_repository.dart';
import '../features/progress/data/progress_database.dart';
import '../features/progress/domain/progress.dart';
import '../features/recommendations/domain/recommender.dart';

/// Должна совпадать с `version` в pubspec.yaml (проверяется тестом).
const appVersion = '0.3.0';

/// Текущее время; в тестах подменяется фиксированной датой.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Новый вопрос родительского барьера на каждое открытие.
final gateQuestionProvider = Provider<GateQuestion Function()>((ref) {
  final random = Random();
  return () => GateQuestion.random(random);
});

/// Адрес API задаётся при сборке: `--dart-define=LUMI_API_URL=https://...`.
/// Пусто — приложение работает только на встроенном пакете.
const apiBaseUrl = String.fromEnvironment('LUMI_API_URL');

final packStoreProvider = Provider<PackStore>(
  (ref) => FilePackStore(
    () async =>
        Directory('${(await getApplicationSupportDirectory()).path}/content'),
  ),
);

final contentRepositoryProvider = Provider<ContentRepository>(
  (ref) => PackContentRepository(
    appVersion: appVersion,
    store: ref.watch(packStoreProvider),
  ),
);

final contentProvider = FutureProvider<LoadedContent>(
  (ref) => ref.watch(contentRepositoryProvider).load(),
);

final tasksProvider = FutureProvider<List<LearningTask>>(
  (ref) async => (await ref.watch(contentProvider.future)).tasks,
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final packUpdaterProvider = Provider<PackUpdater>(
  (ref) => PackUpdater(
    baseUrl: apiBaseUrl,
    client: ref.watch(httpClientProvider),
    store: ref.watch(packStoreProvider),
    appVersion: appVersion,
  ),
);

/// Проверка обновления заданий. Новый пакет начинает работать со следующего
/// запуска, чтобы задания не менялись у ребёнка посреди игры.
final packUpdateProvider = FutureProvider<PackUpdateResult>(
  (ref) => ref.watch(packUpdaterProvider).check(),
);

final progressDatabaseProvider = Provider<ProgressDatabase>((ref) {
  final db = ProgressDatabase.onDevice();
  ref.onDispose(db.close);
  return db;
});

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => DriftProgressRepository(ref.watch(progressDatabaseProvider)),
);

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => DriftProfileRepository(
    ref.watch(progressDatabaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

final profilesProvider = FutureProvider<List<ChildProfile>>(
  (ref) => ref.watch(profileRepositoryProvider).loadAll(),
);

/// Ребёнок, который сейчас играет; null — профилей ещё нет.
final activeChildProvider = FutureProvider<ChildProfile?>((ref) async {
  final profiles = await ref.watch(profilesProvider.future);
  if (profiles.isEmpty) return null;
  final id = await ref.watch(profileRepositoryProvider).activeChildId();
  return profiles.where((p) => p.id == id).firstOrNull ?? profiles.first;
});

final childBestStarsProvider = FutureProvider.family<Map<String, int>, String>(
  (ref, childId) =>
      ref.watch(progressRepositoryProvider).bestStarsByTask(childId),
);

/// История для кабинета родителя; новые занятия первыми.
final childHistoryProvider = FutureProvider.family<List<AttemptRecord>, String>(
  (ref, childId) =>
      ref.watch(progressRepositoryProvider).history(childId, limit: 500),
);

final bestStarsProvider = FutureProvider<Map<String, int>>((ref) async {
  final child = await ref.watch(activeChildProvider.future);
  if (child == null) return const {};
  return ref.watch(childBestStarsProvider(child.id).future);
});

/// Возрастная программа текущего ребёнка, по его месяцу рождения.
final ageProgramProvider = FutureProvider<AgeProgram?>((ref) async {
  final child = await ref.watch(activeChildProvider.future);
  return child?.programAt(ref.watch(clockProvider)());
});

/// Задания, подходящие возрасту текущего ребёнка.
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

/// Сохраняет профиль; новый профиль сразу становится текущим.
Future<void> saveChild(
  WidgetRef ref,
  ChildProfile profile, {
  required bool isNew,
}) async {
  final repo = ref.read(profileRepositoryProvider);
  await repo.save(profile);
  if (isNew) await repo.setActiveChild(profile.id);
  ref.invalidate(profilesProvider);
  // Первый профиль мог забрать прогресс прежней версии.
  invalidateProgress(ref);
}

Future<void> switchChild(WidgetRef ref, String childId) async {
  await ref.read(profileRepositoryProvider).setActiveChild(childId);
  ref.invalidate(activeChildProvider);
}

Future<void> deleteChild(WidgetRef ref, String childId) async {
  await ref.read(profileRepositoryProvider).delete(childId);
  ref.invalidate(profilesProvider);
  invalidateProgress(ref);
}

Future<void> eraseAllData(WidgetRef ref) async {
  await ref.read(profileRepositoryProvider).deleteEverything();
  ref.invalidate(profilesProvider);
  invalidateProgress(ref);
}

void invalidateProgress(WidgetRef ref) {
  ref.invalidate(childBestStarsProvider);
  ref.invalidate(childHistoryProvider);
}
