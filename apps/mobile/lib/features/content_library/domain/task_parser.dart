import '../../catalog/domain/development_area.dart';
import 'task.dart';

/// Превращает JSON задания в [LearningTask].
///
/// Задание, которое эта версия приложения показать не может (новая схема,
/// неизвестный тип, слишком новая minAppVersion, сломанные ссылки), пропускается,
/// а не ломает каталог. Причина пропуска попадает в [skipped].
class TaskParser {
  TaskParser({required this.appVersion, this.language = 'ru'});

  static const supportedSchemaVersion = 1;

  final String appVersion;

  /// Язык текстов: ru, uz или en.
  final String language;
  final List<String> skipped = [];

  List<LearningTask> parsePack(Map<String, Object?> pack) {
    final tasks = pack['tasks'];
    if (tasks is! List) {
      throw const FormatException('В пакете нет списка tasks');
    }
    final result = <LearningTask>[];
    final seen = <String>{};
    for (final raw in tasks) {
      if (raw is! Map<String, Object?>) {
        skipped.add('элемент пакета не является объектом');
        continue;
      }
      final task = parseTask(raw);
      if (task == null) continue;
      if (!seen.add(task.id)) {
        skipped.add('${task.id}: повторяющийся id');
        continue;
      }
      result.add(task);
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
    if (ExerciseType.fromCode(json['exerciseType']) == null) {
      return 'тип ${json['exerciseType']} пока не поддерживается';
    }
    if (DevelopmentArea.fromCode(json['area'] as String) == null) {
      return 'неизвестное направление ${json['area']}';
    }
    return null;
  }

  LearningTask _build(String id, Map<String, Object?> json) {
    final type = ExerciseType.fromCode(json['exerciseType'])!;
    final content = json['content'] as Map<String, Object?>;
    final age = json['ageRange'] as Map<String, Object?>;
    final ageRange = AgeRange(age['minMonths'] as int, age['maxMonths'] as int);
    if (ageRange.minMonths > ageRange.maxMonths) {
      throw const FormatException('возраст указан наоборот');
    }
    final instruction = json['instruction'] as Map<String, Object?>;
    final reward = json['reward'] as Map<String, Object?>;

    return LearningTask(
      id: id,
      version: json['version'] as int,
      area: DevelopmentArea.fromCode(json['area'] as String)!,
      ageRange: ageRange,
      difficulty: json['difficulty'] as int,
      type: type,
      instruction: _text(instruction['text']),
      content: switch (type) {
        ExerciseType.choice => _choice(content),
        ExerciseType.sequence => _sequence(content),
        ExerciseType.matchPairs => _pairs(content),
        ExerciseType.sort || ExerciseType.classify => _groups(content),
        ExerciseType.together => _together(content),
      },
      hints: ((json['hints'] as List<Object?>?) ?? const [])
          .map(_text)
          .toList(),
      rewardStars: reward['stars'] as int,
      withParent: json['withParent'] as bool? ?? false,
    );
  }

  ChoiceContent _choice(Map<String, Object?> content) {
    final options = _items(content['options']);
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
    return ChoiceContent(
      prompt: prompt is Map<String, Object?> ? _item(prompt) : null,
      options: options,
      correct: correct,
      shuffle: content['shuffle'] as bool? ?? true,
    );
  }

  SequenceContent _sequence(Map<String, Object?> content) {
    final steps = _items(content['steps']);
    if (steps.length < 2) throw const FormatException('нужно минимум 2 шага');
    _requireUniqueIds(steps);
    return SequenceContent(steps: steps);
  }

  MatchPairsContent _pairs(Map<String, Object?> content) {
    final pairs = (content['pairs'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(
          (p) => MatchPair(
            _item(p['left'] as Map<String, Object?>),
            _item(p['right'] as Map<String, Object?>),
          ),
        )
        .toList();
    if (pairs.length < 2) throw const FormatException('нужно минимум 2 пары');
    _requireUniqueIds([
      for (final p in pairs) ...[p.left, p.right],
    ]);
    return MatchPairsContent(pairs: pairs);
  }

  GroupContent _groups(Map<String, Object?> content) {
    final groups = _items(content['groups']);
    final groupIds = groups.map((g) => g.id).toSet();
    final items = (content['items'] as List<Object?>)
        .cast<Map<String, Object?>>()
        .map(
          (e) => GroupedItem(
            _item(e['item'] as Map<String, Object?>),
            e['groupId'] as String,
          ),
        )
        .toList();
    if (groups.length < 2 || items.isEmpty) {
      throw const FormatException('нужны минимум 2 группы и предметы');
    }
    if (!items.every((i) => groupIds.contains(i.groupId))) {
      throw const FormatException('предмет ссылается на неизвестную группу');
    }
    _requireUniqueIds([...groups, ...items.map((i) => i.item)]);
    return GroupContent(groups: groups, items: items);
  }

  TogetherContent _together(Map<String, Object?> content) {
    final steps = (content['steps'] as List<Object?>).map(_text).toList();
    if (steps.isEmpty) throw const FormatException('нет шагов занятия');
    return TogetherContent(steps: steps);
  }

  List<TaskItem> _items(Object? list) =>
      (list as List<Object?>).cast<Map<String, Object?>>().map(_item).toList();

  TaskItem _item(Map<String, Object?> json) {
    final label = json['label'];
    return TaskItem(
      id: json['id'] as String,
      label: label == null ? null : _text(label),
    );
  }

  void _requireUniqueIds(List<TaskItem> items) {
    if (items.map((i) => i.id).toSet().length != items.length) {
      throw const FormatException('повторяющийся id элемента');
    }
  }

  /// Текст на языке приложения; если перевода нет — русский (он обязателен).
  String _text(Object? localized) {
    final texts = localized as Map<String, Object?>;
    return (texts[language] ?? texts['ru']) as String;
  }
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
