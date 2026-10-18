import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/exercise_engine/domain/choice_session.dart';

LearningTask task({
  int rewardStars = 3,
  List<String> hints = const ['h1', 'h2'],
}) => LearningTask(
  id: 't',
  version: 1,
  area: DevelopmentArea.math,
  difficulty: 1,
  type: ExerciseType.choice,
  instruction: 'i',
  content: const ChoiceContent(
    options: [
      TaskItem(id: 'a'),
      TaskItem(id: 'b'),
      TaskItem(id: 'c'),
    ],
    correct: {'b'},
  ),
  hints: hints,
  rewardStars: rewardStars,
);

void main() {
  test('правильный ответ с первого раза даёт все звёзды', () {
    final s = ChoiceSession(task());
    expect(s.answer('b'), AnswerOutcome.correct);
    expect(s.isSolved, isTrue);
    expect(s.stars, 3);
    expect(s.currentHint, isNull);
  });

  test('ошибки уменьшают звёзды, но не ниже одной', () {
    final s = ChoiceSession(task());
    expect(s.answer('a'), AnswerOutcome.tryAgain);
    expect(s.answer('c'), AnswerOutcome.tryAgain);
    expect(s.answer('b'), AnswerOutcome.correct);
    expect(s.mistakes, 2);
    expect(s.stars, 1);
  });

  test(
    'повторное нажатие на тот же неверный вариант не считается новой ошибкой',
    () {
      final s = ChoiceSession(task());
      s.answer('a');
      s.answer('a');
      expect(s.mistakes, 1);
    },
  );

  test('подсказки появляются после ошибок и не выходят за список', () {
    final s = ChoiceSession(task());
    s.answer('a');
    expect(s.currentHint, 'h1');
    s.answer('c');
    expect(s.currentHint, 'h2');
    expect((ChoiceSession(task(hints: []))..answer('a')).currentHint, isNull);
  });

  test('нерешённое задание и задание без награды дают 0 звёзд', () {
    expect(ChoiceSession(task()).stars, 0);
    final noReward = ChoiceSession(task(rewardStars: 0))..answer('b');
    expect(noReward.stars, 0);
  });
}
