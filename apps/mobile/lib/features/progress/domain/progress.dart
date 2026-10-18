/// Результат завершённого задания.
class AttemptRecord {
  const AttemptRecord({
    required this.childId,
    required this.taskId,
    required this.taskVersion,
    required this.startedAt,
    required this.finishedAt,
    required this.mistakes,
    required this.stars,
  });

  final String childId;
  final String taskId;
  final int taskVersion;
  final DateTime startedAt;
  final DateTime finishedAt;
  final int mistakes;
  final int stars;
}

abstract interface class ProgressRepository {
  Future<void> saveAttempt(AttemptRecord attempt);

  /// Лучший результат ребёнка по каждому заданию: id задания → звёзды.
  Future<Map<String, int>> bestStarsByTask(String childId);

  /// Последние попытки ребёнка, новые первыми.
  Future<List<AttemptRecord>> history(String childId, {int limit = 30});
}
