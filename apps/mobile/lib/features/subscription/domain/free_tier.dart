import '../../age_routes/domain/age_program.dart';
import '../../catalog/domain/development_area.dart';
import '../../content_library/domain/task.dart';

/// Без подписки в каждом направлении каждой возрастной программы открыты
/// первые задания по сложности.
const freeTasksPerArea = 3;

/// Бесплатные задания. Набор не зависит от ребёнка: при переходе в
/// следующую возрастную программу открываются её первые задания.
Set<String> freeTaskIds(List<LearningTask> tasks) {
  final free = <String>{};
  for (final program in AgeProgram.values) {
    for (final area in DevelopmentArea.values) {
      final inArea =
          tasks.where((t) => t.area == area && program.fits(t)).toList()
            ..sort((a, b) {
              final byDifficulty = a.difficulty.compareTo(b.difficulty);
              return byDifficulty != 0 ? byDifficulty : a.id.compareTo(b.id);
            });
      free.addAll(inArea.take(freeTasksPerArea).map((t) => t.id));
    }
  }
  return free;
}
