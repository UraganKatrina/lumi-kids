import '../../catalog/domain/development_area.dart';

/// Типы упражнений, которые эта версия приложения умеет показывать.
enum ExerciseType { choice }

/// Элемент задания: вариант ответа или картинка-вопрос.
class TaskItem {
  const TaskItem({required this.id, this.label});

  final String id;

  /// Подпись на русском. Для прототипа здесь же эмодзи-иллюстрация.
  final String? label;
}

class ChoiceContent {
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

/// Задание в том виде, в каком его использует приложение.
/// Полный формат описан в content/schema/task.schema.json.
class LearningTask {
  const LearningTask({
    required this.id,
    required this.version,
    required this.area,
    required this.difficulty,
    required this.type,
    required this.instruction,
    required this.content,
    required this.hints,
    required this.rewardStars,
  });

  final String id;
  final int version;
  final DevelopmentArea area;
  final int difficulty;
  final ExerciseType type;
  final String instruction;
  final ChoiceContent content;
  final List<String> hints;
  final int rewardStars;
}
