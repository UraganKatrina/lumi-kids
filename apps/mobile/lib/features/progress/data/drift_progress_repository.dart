import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/progress.dart';
import 'progress_database.dart';

class DriftProgressRepository implements ProgressRepository {
  DriftProgressRepository(this._db);

  static const _uuid = Uuid();

  final ProgressDatabase _db;

  @override
  Future<void> saveAttempt(AttemptRecord attempt) {
    return _db
        .into(_db.attempts)
        .insert(
          AttemptsCompanion.insert(
            id: _uuid.v4(),
            childId: Value(attempt.childId),
            taskId: attempt.taskId,
            taskVersion: attempt.taskVersion,
            startedAt: attempt.startedAt,
            finishedAt: attempt.finishedAt,
            mistakes: attempt.mistakes,
            stars: attempt.stars,
          ),
        );
  }

  @override
  Future<Map<String, int>> bestStarsByTask(String childId) async {
    final best = _db.attempts.stars.max();
    final rows =
        await (_db.selectOnly(_db.attempts)
              ..addColumns([_db.attempts.taskId, best])
              ..where(_db.attempts.childId.equals(childId))
              ..groupBy([_db.attempts.taskId]))
            .get();
    return {
      for (final row in rows)
        row.read(_db.attempts.taskId)!: row.read(best) ?? 0,
    };
  }

  @override
  Future<List<AttemptRecord>> history(String childId, {int limit = 30}) async {
    final rows =
        await (_db.select(_db.attempts)
              ..where((a) => a.childId.equals(childId))
              ..orderBy([(a) => OrderingTerm.desc(a.finishedAt)])
              ..limit(limit))
            .get();
    return [
      for (final row in rows)
        AttemptRecord(
          childId: childId,
          taskId: row.taskId,
          taskVersion: row.taskVersion,
          startedAt: row.startedAt,
          finishedAt: row.finishedAt,
          mistakes: row.mistakes,
          stars: row.stars,
        ),
    ];
  }
}
