import '../../catalog/domain/development_area.dart';

/// Типы упражнений, которые эта версия приложения умеет показывать.
/// [code] совпадает с `exerciseType` в схеме контента.
enum ExerciseType {
  choice('choice'),
  sequence('sequence'),
  matchPairs('match_pairs'),
  sort('sort'),
  classify('classify'),
  together('audio_instruction');

  const ExerciseType(this.code);

  final String code;

  static ExerciseType? fromCode(Object? code) {
    for (final type in values) {
      if (type.code == code) return type;
    }
    return null;
  }
}

/// Возраст в месяцах, включительно с обеих сторон.
class AgeRange {
  const AgeRange(this.minMonths, this.maxMonths);

  final int minMonths;
  final int maxMonths;

  bool overlaps(AgeRange other) =>
      minMonths <= other.maxMonths && other.minMonths <= maxMonths;
}

/// Элемент задания: вариант ответа, шаг, карточка пары или группа.
class TaskItem {
  const TaskItem({required this.id, this.label});

  final String id;

  /// Подпись на русском. В прототипе здесь же эмодзи-иллюстрация.
  final String? label;

  String get display => label ?? id;
}

/// Данные упражнения. У каждого типа свой подкласс.
sealed class ExerciseContent {
  const ExerciseContent();
}

class ChoiceContent extends ExerciseContent {
  const ChoiceContent({
    required this.options,
    required this.correct,
    this.prompt,
    this.shuffle = true,
  });

  final TaskItem? prompt;
  final List<TaskItem> options;
  final Set<String> correct;
  final bool shuffle;
}

/// Шаги в правильном порядке; приложение показывает их перемешанными.
class SequenceContent extends ExerciseContent {
  const SequenceContent({required this.steps});

  final List<TaskItem> steps;
}

class MatchPair {
  const MatchPair(this.left, this.right);

  final TaskItem left;
  final TaskItem right;
}

class MatchPairsContent extends ExerciseContent {
  const MatchPairsContent({required this.pairs});

  final List<MatchPair> pairs;
}

class GroupedItem {
  const GroupedItem(this.item, this.groupId);

  final TaskItem item;
  final String groupId;
}

/// Сортировка и классификация: разложить предметы по группам.
class GroupContent extends ExerciseContent {
  const GroupContent({required this.groups, required this.items});

  final List<TaskItem> groups;
  final List<GroupedItem> items;
}

/// Занятие вместе со взрослым вне экрана: телефон только подсказывает идею.
class TogetherContent extends ExerciseContent {
  const TogetherContent({required this.steps});

  final List<String> steps;
}

/// Задание в том виде, в каком его использует приложение.
/// Полный формат описан в content/schema/task.schema.json.
class LearningTask {
  const LearningTask({
    required this.id,
    required this.version,
    required this.area,
    required this.ageRange,
    required this.difficulty,
    required this.type,
    required this.instruction,
    required this.content,
    this.hints = const [],
    this.rewardStars = 3,
    this.withParent = false,
  });

  final String id;
  final int version;
  final DevelopmentArea area;
  final AgeRange ageRange;
  final int difficulty;
  final ExerciseType type;
  final String instruction;
  final ExerciseContent content;
  final List<String> hints;
  final int rewardStars;
  final bool withParent;
}
