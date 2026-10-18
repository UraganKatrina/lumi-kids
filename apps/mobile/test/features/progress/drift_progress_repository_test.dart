import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/progress/data/drift_progress_repository.dart';
import 'package:lumi_kids/features/progress/data/progress_database.dart';
import 'package:lumi_kids/features/progress/domain/progress.dart';

AttemptRecord attempt(String taskId, int stars) => AttemptRecord(
  taskId: taskId,
  taskVersion: 1,
  startedAt: DateTime(2026, 10, 18, 10),
  finishedAt: DateTime(2026, 10, 18, 10, 1),
  mistakes: 3 - stars,
  stars: stars,
);

void main() {
  late ProgressDatabase db;
  late DriftProgressRepository repo;

  setUp(() {
    db = ProgressDatabase(NativeDatabase.memory());
    repo = DriftProgressRepository(db);
  });
  tearDown(() => db.close());

  test('пустой прогресс', () async {
    expect(await repo.bestStarsByTask(), isEmpty);
  });

  test('сохраняет каждую попытку и показывает лучший результат', () async {
    await repo.saveAttempt(attempt('a', 1));
    await repo.saveAttempt(attempt('a', 3));
    await repo.saveAttempt(attempt('a', 2));
    await repo.saveAttempt(attempt('b', 2));

    expect(await db.select(db.attempts).get(), hasLength(4));
    expect(await repo.bestStarsByTask(), {'a': 3, 'b': 2});
  });
}
