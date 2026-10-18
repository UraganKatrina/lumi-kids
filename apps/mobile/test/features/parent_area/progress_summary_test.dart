import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/parent_area/domain/progress_summary.dart';
import 'package:lumi_kids/features/progress/domain/progress.dart';

import '../../support/builders.dart';

AttemptRecord done(String task, DateTime at) => AttemptRecord(
  childId: 'k',
  taskId: task,
  taskVersion: 1,
  startedAt: at,
  finishedAt: at,
  mistakes: 0,
  stars: 3,
);

void main() {
  final now = DateTime(2026, 10, 18);
  final tasks = [
    buildTask(id: 'math.a', area: DevelopmentArea.math),
    buildTask(id: 'math.b', area: DevelopmentArea.math),
    buildTask(id: 'logic.a', area: DevelopmentArea.logic),
    buildTask(id: 'speech.a', area: DevelopmentArea.speech),
  ];

  AreaSummary area(ChildSummary s, DevelopmentArea a) =>
      s.areas.firstWhere((x) => x.area == a);

  test('статусы по направлениям — наблюдения, без оценок', () {
    final summary = summarize(
      tasks: tasks,
      bestStars: {'math.a': 3, 'math.b': 2, 'logic.a': 1},
      history: const [],
      now: now,
    );
    expect(area(summary, DevelopmentArea.math).status, AreaStatus.confident);
    expect(area(summary, DevelopmentArea.math).tried, 2);
    expect(area(summary, DevelopmentArea.logic).status, AreaStatus.trying);
    expect(area(summary, DevelopmentArea.speech).status, AreaStatus.notTried);
    // Направлений без заданий для этого возраста нет в списке.
    expect(summary.areas, hasLength(3));
  });

  test('считает занятия за неделю', () {
    final summary = summarize(
      tasks: tasks,
      bestStars: const {},
      history: [
        done('math.a', now.subtract(const Duration(days: 1))),
        done('math.a', now.subtract(const Duration(days: 6))),
        done('math.b', now.subtract(const Duration(days: 9))),
      ],
      now: now,
    );
    expect(summary.completed, 3);
    expect(summary.lastWeek, 2);
  });
}
