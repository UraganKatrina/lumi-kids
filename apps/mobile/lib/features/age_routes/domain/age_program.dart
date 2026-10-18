import '../../content_library/domain/task.dart';

/// Возрастные программы. Возраст задаёт стартовый набор заданий, а сложность
/// дальше подстраивается по результатам ребёнка.
enum AgeProgram {
  infant('infant', AgeRange(0, 11)),
  toddler('toddler', AgeRange(12, 23)),
  early('early', AgeRange(24, 35)),
  preschool('preschool', AgeRange(36, 59)),
  schoolPrep('school_prep', AgeRange(60, 84));

  const AgeProgram(this.code, this.range);

  final String code;
  final AgeRange range;

  /// Для младенцев экран — только подсказка взрослому.
  bool get parentLed => this == infant;

  bool fits(LearningTask task) => task.ageRange.overlaps(range);

  /// Программа по возрасту в месяцах; старше 7 лет — подготовка к школе.
  static AgeProgram forMonths(int months) {
    for (final p in values) {
      if (months <= p.range.maxMonths) return p;
    }
    return schoolPrep;
  }

  static AgeProgram? fromCode(String? code) {
    for (final p in values) {
      if (p.code == code) return p;
    }
    return null;
  }
}
