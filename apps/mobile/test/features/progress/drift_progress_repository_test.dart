import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/progress/data/drift_progress_repository.dart';
import 'package:lumi_kids/features/progress/data/progress_database.dart';
import 'package:lumi_kids/features/progress/domain/progress.dart';

AttemptRecord attempt(
  String taskId,
  int stars, {
  String child = 'kid',
  int minute = 1,
}) => AttemptRecord(
  childId: child,
  taskId: taskId,
  taskVersion: 1,
  startedAt: DateTime(2026, 10, 18, 10),
  finishedAt: DateTime(2026, 10, 18, 10, minute),
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
    expect(await repo.bestStarsByTask('kid'), isEmpty);
    expect(await repo.history('kid'), isEmpty);
  });

  test('сохраняет каждую попытку и показывает лучший результат', () async {
    await repo.saveAttempt(attempt('a', 1));
    await repo.saveAttempt(attempt('a', 3));
    await repo.saveAttempt(attempt('a', 2));
    await repo.saveAttempt(attempt('b', 2));

    expect(await db.select(db.attempts).get(), hasLength(4));
    expect(await repo.bestStarsByTask('kid'), {'a': 3, 'b': 2});
  });

  test('прогресс детей не смешивается', () async {
    await repo.saveAttempt(attempt('a', 3, child: 'masha'));
    await repo.saveAttempt(attempt('a', 1, child: 'petya'));

    expect(await repo.bestStarsByTask('masha'), {'a': 3});
    expect(await repo.bestStarsByTask('petya'), {'a': 1});
    expect((await repo.history('petya')).single.stars, 1);
  });

  test('история: новые первыми, с ограничением', () async {
    for (var m = 1; m <= 5; m++) {
      await repo.saveAttempt(attempt('t$m', 3, minute: m));
    }
    final last = await repo.history('kid', limit: 3);
    expect(last.map((a) => a.taskId), ['t5', 't4', 't3']);
    expect(last.first.childId, 'kid');
  });
}
