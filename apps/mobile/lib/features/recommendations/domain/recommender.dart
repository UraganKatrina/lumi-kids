import '../../catalog/domain/development_area.dart';
import '../../content_library/domain/task.dart';

/// Подбирает следующее занятие.
///
/// Правила:
/// 1. Сначала задания, которые ещё не пробовали; потом те, где можно
///    получить больше звёзд.
/// 2. Сложность растёт постепенно: доступен уровень на 1 выше самого
///    сложного задания, пройденного на все звёзды.
/// 3. Направления чередуются: выбирается то, где пройдено меньше всего.
LearningTask? recommendNext(
  List<LearningTask> tasks,
  Map<String, int> bestStars,
) {
  if (tasks.isEmpty) return null;

  bool tried(LearningTask t) => bestStars.containsKey(t.id);
  final mastered = tasks.where(
    (t) => tried(t) && bestStars[t.id]! >= t.rewardStars,
  );
  final easiest = tasks
      .map((t) => t.difficulty)
      .reduce((a, b) => a < b ? a : b);
  final level = mastered.isEmpty
      ? easiest
      : mastered.map((t) => t.difficulty).reduce((a, b) => a > b ? a : b) + 1;

  final untried = tasks.where((t) => !tried(t)).toList();
  final improvable = tasks
      .where((t) => tried(t) && bestStars[t.id]! < t.rewardStars)
      .toList();
  final pool = untried.isNotEmpty ? untried : improvable;
  if (pool.isEmpty) return null;

  final done = <DevelopmentArea, int>{};
  for (final t in tasks.where(tried)) {
    done[t.area] = (done[t.area] ?? 0) + 1;
  }

  // Если всё доступное по уровню пройдено, берём самое лёгкое из оставшегося.
  final inLevel = pool.where((t) => t.difficulty <= level).toList();
  final candidates = inLevel.isNotEmpty ? inLevel : pool;

  candidates.sort((a, b) {
    final byDifficulty = a.difficulty.compareTo(b.difficulty);
    if (byDifficulty != 0) return byDifficulty;
    final byArea = (done[a.area] ?? 0).compareTo(done[b.area] ?? 0);
    if (byArea != 0) return byArea;
    return a.id.compareTo(b.id);
  });
  return candidates.first;
}
