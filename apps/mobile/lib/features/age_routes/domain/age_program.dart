import '../../content_library/domain/task.dart';

/// Возрастные программы. Возраст задаёт стартовый набор заданий, а сложность
/// дальше подстраивается по результатам ребёнка.
enum AgeProgram {
  infant('infant', '0–1 год', 'Занятия вместе со взрослым', AgeRange(0, 11)),
  toddler(
    'toddler',
    '1–2 года',
    'Предметы, животные, первые слова',
    AgeRange(12, 23),
  ),
  early('early', '2–3 года', 'Цвета, формы, сортировка', AgeRange(24, 35)),
  preschool('preschool', '3–5 лет', 'Речь, логика, счёт', AgeRange(36, 59)),
  schoolPrep('school_prep', '5–7 лет', 'Подготовка к школе', AgeRange(60, 84));

  const AgeProgram(this.code, this.title, this.subtitle, this.range);

  final String code;
  final String title;
  final String subtitle;
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
