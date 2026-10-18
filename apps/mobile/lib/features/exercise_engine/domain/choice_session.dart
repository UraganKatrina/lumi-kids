import '../../content_library/domain/task.dart';

enum AnswerOutcome { correct, tryAgain }

/// Состояние одного прохождения задания с выбором ответа.
/// Ошибки не наказываются: неверный вариант гаснет, ребёнок пробует ещё.
class ChoiceSession {
  ChoiceSession(this.task, {DateTime? startedAt})
    : startedAt = startedAt ?? DateTime.now();

  final LearningTask task;
  final DateTime startedAt;
  final Set<String> _rejected = {};
  bool _solved = false;

  int get mistakes => _rejected.length;
  bool get isSolved => _solved;
  Set<String> get rejected => Set.unmodifiable(_rejected);

  /// Подсказка появляется после первой ошибки и усиливается после следующих.
  String? get currentHint {
    if (mistakes == 0 || task.hints.isEmpty) return null;
    return task.hints[(mistakes - 1).clamp(0, task.hints.length - 1)];
  }

  AnswerOutcome answer(String optionId) {
    if (_solved) return AnswerOutcome.correct;
    if (task.content.correct.contains(optionId)) {
      _solved = true;
      return AnswerOutcome.correct;
    }
    _rejected.add(optionId);
    return AnswerOutcome.tryAgain;
  }

  /// Звёзды за решённое задание: максимум из задания минус ошибки,
  /// но не меньше одной — старание тоже засчитывается.
  int get stars {
    if (!_solved || task.rewardStars == 0) return 0;
    return (task.rewardStars - mistakes).clamp(1, task.rewardStars);
  }
}
