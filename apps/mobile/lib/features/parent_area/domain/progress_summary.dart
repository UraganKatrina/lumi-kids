import '../../catalog/domain/development_area.dart';
import '../../content_library/domain/task.dart';
import '../../progress/domain/progress.dart';

/// Наблюдение, а не оценка: без «отстаёт» и сравнений с другими детьми.
enum AreaStatus { notTried, trying, confident }

class AreaSummary {
  const AreaSummary({
    required this.area,
    required this.status,
    required this.tried,
    required this.total,
  });

  final DevelopmentArea area;
  final AreaStatus status;
  final int tried;
  final int total;
}

class ChildSummary {
  const ChildSummary({
    required this.completed,
    required this.lastWeek,
    required this.areas,
  });

  /// Всего завершённых занятий (из загруженной истории).
  final int completed;

  /// Занятий за последние 7 дней.
  final int lastWeek;

  /// Только направления, для которых есть задания этого возраста.
  final List<AreaSummary> areas;
}

/// Доля набранных звёзд, начиная с которой считаем, что ребёнок справляется.
const confidentShare = 2 / 3;

ChildSummary summarize({
  required List<LearningTask> tasks,
  required Map<String, int> bestStars,
  required List<AttemptRecord> history,
  required DateTime now,
}) {
  final weekAgo = now.subtract(const Duration(days: 7));
  final areas = <AreaSummary>[];
  for (final area in DevelopmentArea.values) {
    final areaTasks = tasks.where((t) => t.area == area).toList();
    if (areaTasks.isEmpty) continue;
    final tried = areaTasks.where((t) => bestStars.containsKey(t.id));
    final scored = tried.where((t) => t.rewardStars > 0);
    final earned = scored.fold(0, (s, t) => s + bestStars[t.id]!);
    final possible = scored.fold(0, (s, t) => s + t.rewardStars);
    final status = tried.isEmpty
        ? AreaStatus.notTried
        : possible == 0 || earned / possible >= confidentShare
        ? AreaStatus.confident
        : AreaStatus.trying;
    areas.add(
      AreaSummary(
        area: area,
        status: status,
        tried: tried.length,
        total: areaTasks.length,
      ),
    );
  }
  return ChildSummary(
    completed: history.length,
    lastWeek: history.where((a) => a.finishedAt.isAfter(weekAgo)).length,
    areas: areas,
  );
}
