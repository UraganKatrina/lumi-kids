import '../../catalog/domain/development_area.dart';
import 'task.dart';

/// Превращает JSON задания в [LearningTask].
///
/// Задание, которое эта версия приложения показать не может (новая схема,
/// неизвестный тип, слишком новая minAppVersion), пропускается, а не ломает
/// каталог. Причина пропуска попадает в [skipped].
class TaskParser {
  TaskParser({required this.appVersion});

  static const supportedSchemaVersion = 1;

  final String appVersion;
  final List<String> skipped = [];

  List<LearningTask> parsePack(Map<String, Object?> pack) {
    final tasks = pack['tasks'];
    if (tasks is! List) {
      throw const FormatException('В пакете нет списка tasks');
    }
    final result = <LearningTask>[];
    for (final raw in tasks) {
      if (raw is! Map<String, Object?>) {
        skipped.add('элемент пакета не является объектом');
        continue;
      }
      final task = parseTask(raw);
      if (task != null) result.add(task);
    }
    return result;
  }

  LearningTask? parseTask(Map<String, Object?> json) {
    final id = json['id'];
    if (id is! String) {
      skipped.add('задание без id');
      return null;
    }
    String? reason;
    LearningTask? task;
    try {
      reason = _incompatibility(json);
      if (reason == null) task = _build(id, json);
    } on FormatException catch (e) {
      reason = 'ошибка формата: ${e.message}';
    } on TypeError {
      reason = 'неверный тип поля';
    }
    if (reason != null) skipped.add('$id: $reason');
    return task;
  }

  String? _incompatibility(Map<String, Object?> json) {
    if (json['schemaVersion'] != supportedSchemaVersion) {
      return 'неподдерживаемая версия схемы ${json['schemaVersion']}';
    }
    final minApp = json['minAppVersion'];
    if (minApp is String && compareVersions(minApp, appVersion) > 0) {
      return 'нужна версия приложения $minApp';
    }
    if (json['exerciseType'] != 'choice') {
      return 'тип ${json['exerciseType']} пока не поддерживается';
    }
    if (DevelopmentArea.fromCode(json['area'] as String) == null) {
      return 'неизвестное направление ${json['area']}';
    }
    return null;
  }

  LearningTask _build(String id, Map<String, Object?> json) {
    final content = json['content'] as Map<String, Object?>;
    final options = (content['options'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(_item)
        .toList();
    final correct = (content['correct'] as List<Object?>)
        .cast<String>()
        .toSet();
    final optionIds = options.map((o) => o.id).toSet();
    if (options.length < 2 ||
        correct.isEmpty ||
        !optionIds.containsAll(correct)) {
      throw const FormatException(
        'варианты не сходятся с правильными ответами',
      );
    }
    final prompt = content['prompt'];
    final instruction = json['instruction'] as Map<String, Object?>;
    final reward = json['reward'] as Map<String, Object?>;

    return LearningTask(
      id: id,
      version: json['version'] as int,
      area: DevelopmentArea.fromCode(json['area'] as String)!,
      difficulty: json['difficulty'] as int,
      type: ExerciseType.choice,
      instruction: _ru(instruction['text']),
      content: ChoiceContent(
        prompt: prompt is Map<String, Object?> ? _item(prompt) : null,
        options: options,
        correct: correct,
        shuffle: content['shuffle'] as bool? ?? true,
      ),
      hints: ((json['hints'] as List<Object?>?) ?? const []).map(_ru).toList(),
      rewardStars: reward['stars'] as int,
    );
  }

  TaskItem _item(Map<String, Object?> json) {
    final label = json['label'];
    return TaskItem(
      id: json['id'] as String,
      label: label == null ? null : _ru(label),
    );
  }

  String _ru(Object? localized) =>
      (localized as Map<String, Object?>)['ru'] as String;
}

/// Сравнивает версии вида 1.2.3. Отрицательное число — [a] старше [b].
int compareVersions(String a, String b) {
  final pa = a.split('.').map(int.parse).toList();
  final pb = b.split('.').map(int.parse).toList();
  for (var i = 0; i < 3; i++) {
    final diff = pa[i].compareTo(pb[i]);
    if (diff != 0) return diff;
  }
  return 0;
}
