import '../../content_library/domain/task.dart';

enum AnswerOutcome { correct, tryAgain }

/// Общее состояние прохождения любого задания.
///
/// Ошибки не наказываются: они только уменьшают звёзды (но не ниже одной)
/// и открывают подсказки.
abstract class ExerciseSession {
  ExerciseSession(this.task, {DateTime? startedAt})
    : startedAt = startedAt ?? DateTime.now();

  final LearningTask task;
  final DateTime startedAt;

  int _mistakes = 0;
  bool _solved = false;

  int get mistakes => _mistakes;
  bool get isSolved => _solved;

  /// Подсказка появляется после первой ошибки и усиливается после следующих.
  String? get currentHint {
    if (_mistakes == 0 || task.hints.isEmpty) return null;
    return task.hints[(_mistakes - 1).clamp(0, task.hints.length - 1)];
  }

  int get stars {
    if (!_solved || task.rewardStars == 0) return 0;
    return (task.rewardStars - _mistakes).clamp(1, task.rewardStars);
  }

  AnswerOutcome registerMistake() {
    _mistakes++;
    return AnswerOutcome.tryAgain;
  }

  void markSolved() => _solved = true;
}

class ChoiceSession extends ExerciseSession {
  ChoiceSession(super.task, {super.startedAt});

  ChoiceContent get _content => task.content as ChoiceContent;
  final Set<String> _rejected = {};

  Set<String> get rejected => Set.unmodifiable(_rejected);

  AnswerOutcome answer(String optionId) {
    if (isSolved) return AnswerOutcome.correct;
    if (_content.correct.contains(optionId)) {
      markSolved();
      return AnswerOutcome.correct;
    }
    // Повторное нажатие на погасший вариант — не новая ошибка.
    if (!_rejected.add(optionId)) return AnswerOutcome.tryAgain;
    return registerMistake();
  }
}

/// Ребёнок нажимает шаги по порядку; верный шаг встаёт в линию.
class SequenceSession extends ExerciseSession {
  SequenceSession(super.task, {super.startedAt});

  List<TaskItem> get _steps => (task.content as SequenceContent).steps;
  final List<TaskItem> _placed = [];

  List<TaskItem> get placed => List.unmodifiable(_placed);
  bool isPlaced(String stepId) => _placed.any((s) => s.id == stepId);

  AnswerOutcome tap(String stepId) {
    if (isSolved || isPlaced(stepId)) return AnswerOutcome.correct;
    if (_steps[_placed.length].id != stepId) return registerMistake();
    _placed.add(_steps[_placed.length]);
    if (_placed.length == _steps.length) markSolved();
    return AnswerOutcome.correct;
  }
}

/// Найди пару: выбери карточку слева и справа в любом порядке.
class MatchPairsSession extends ExerciseSession {
  MatchPairsSession(super.task, {super.startedAt});

  List<MatchPair> get _pairs => (task.content as MatchPairsContent).pairs;
  final Set<String> _matched = {};
  String? selectedLeft;
  String? selectedRight;

  bool isMatched(String itemId) => _matched.contains(itemId);

  /// Возвращает null, пока выбрана только одна сторона.
  AnswerOutcome? tapLeft(String id) {
    if (isMatched(id)) return null;
    selectedLeft = id;
    return _check();
  }

  AnswerOutcome? tapRight(String id) {
    if (isMatched(id)) return null;
    selectedRight = id;
    return _check();
  }

  AnswerOutcome? _check() {
    final left = selectedLeft;
    final right = selectedRight;
    if (left == null || right == null) return null;
    selectedLeft = null;
    selectedRight = null;
    final isPair = _pairs.any((p) => p.left.id == left && p.right.id == right);
    if (!isPair) return registerMistake();
    _matched.addAll([left, right]);
    if (_matched.length == _pairs.length * 2) markSolved();
    return AnswerOutcome.correct;
  }
}

/// Разложи по группам: предметы появляются по одному.
class GroupSession extends ExerciseSession {
  GroupSession(super.task, {super.startedAt});

  GroupContent get content => task.content as GroupContent;
  int _index = 0;

  GroupedItem? get current =>
      _index < content.items.length ? content.items[_index] : null;
  int get placedCount => _index;

  AnswerOutcome place(String groupId) {
    final item = current;
    if (isSolved || item == null) return AnswerOutcome.correct;
    if (item.groupId != groupId) return registerMistake();
    _index++;
    if (_index == content.items.length) markSolved();
    return AnswerOutcome.correct;
  }
}

/// Занятие со взрослым: засчитывается, когда родитель отмечает, что сделали.
class TogetherSession extends ExerciseSession {
  TogetherSession(super.task, {super.startedAt});

  void complete() => markSolved();
}

ExerciseSession createSession(LearningTask task) => switch (task.type) {
  ExerciseType.choice => ChoiceSession(task),
  ExerciseType.sequence => SequenceSession(task),
  ExerciseType.matchPairs => MatchPairsSession(task),
  ExerciseType.sort || ExerciseType.classify => GroupSession(task),
  ExerciseType.together => TogetherSession(task),
};
