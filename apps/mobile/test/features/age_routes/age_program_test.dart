import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/age_routes/domain/age_program.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';

import '../../support/builders.dart';
import '../../support/fakes.dart';

void main() {
  test('задание подходит программе, если возрасты пересекаются', () {
    final task = buildTask(ageRange: const AgeRange(30, 40));
    expect(AgeProgram.early.fits(task), isTrue);
    expect(AgeProgram.preschool.fits(task), isTrue);
    expect(AgeProgram.toddler.fits(task), isFalse);
  });

  test('программы покрывают 0–84 месяца без дыр', () {
    var expected = 0;
    for (final p in AgeProgram.values) {
      expect(p.range.minMonths, expected);
      expected = p.range.maxMonths + 1;
    }
    expect(expected, 85);
  });

  test('в стартовом пакете есть занятия для каждой программы', () {
    final tasks = loadStarterTasks();
    for (final p in AgeProgram.values) {
      expect(
        tasks.where(p.fits).length,
        greaterThanOrEqualTo(5),
        reason: p.code,
      );
    }
  });

  test('для младенцев только занятия вместе со взрослым', () {
    final infant = loadStarterTasks().where(AgeProgram.infant.fits);
    expect(infant.every((t) => t.withParent), isTrue);
    expect(infant.every((t) => t.type == ExerciseType.together), isTrue);
  });
}
