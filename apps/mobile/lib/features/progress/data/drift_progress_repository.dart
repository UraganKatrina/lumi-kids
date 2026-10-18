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
  Future<Map<String, int>> bestStarsByTask() async {
    final best = _db.attempts.stars.max();
    final rows =
        await (_db.selectOnly(_db.attempts)
              ..addColumns([_db.attempts.taskId, best])
              ..groupBy([_db.attempts.taskId]))
            .get();
    return {
      for (final row in rows)
        row.read(_db.attempts.taskId)!: row.read(best) ?? 0,
    };
  }
}
