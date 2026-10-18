import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/exercise_engine/domain/exercise_session.dart';

import '../../support/builders.dart';

void main() {
  group('выбор ответа', () {
    test('правильный ответ с первого раза даёт все звёзды', () {
      final s = ChoiceSession(buildTask());
      expect(s.answer('b'), AnswerOutcome.correct);
      expect(s.isSolved, isTrue);
      expect(s.stars, 3);
      expect(s.currentHint, isNull);
    });

    test('ошибки уменьшают звёзды, но не ниже одной', () {
      final s = ChoiceSession(buildTask());
      s
        ..answer('a')
        ..answer('c')
        ..answer('b');
      expect(s.mistakes, 2);
      expect(s.stars, 1);
    });

    test('повторное нажатие на погасший вариант не считается ошибкой', () {
      final s = ChoiceSession(buildTask())
        ..answer('a')
        ..answer('a');
      expect(s.mistakes, 1);
    });

    test('подсказки появляются после ошибок и не выходят за список', () {
      final s = ChoiceSession(buildTask())..answer('a');
      expect(s.currentHint, 'h1');
      s.answer('c');
      expect(s.currentHint, 'h2');
      expect(
        (ChoiceSession(buildTask(hints: []))..answer('a')).currentHint,
        isNull,
      );
    });

    test('нерешённое задание и задание без награды дают 0 звёзд', () {
      expect(ChoiceSession(buildTask()).stars, 0);
      expect((ChoiceSession(buildTask(rewardStars: 0))..answer('b')).stars, 0);
    });
  });

  group('последовательность', () {
    final task = buildTask(
      type: ExerciseType.sequence,
      content: SequenceContent(steps: items(['one', 'two', 'three'])),
    );

    test('шаги принимаются только по порядку', () {
      final s = SequenceSession(task);
      expect(s.tap('two'), AnswerOutcome.tryAgain);
      expect(s.tap('one'), AnswerOutcome.correct);
      expect(s.placed.map((i) => i.id), ['one']);
      s
        ..tap('two')
        ..tap('three');
      expect(s.isSolved, isTrue);
      expect(s.stars, 2);
    });

    test('повторное нажатие на уже поставленный шаг не ошибка', () {
      final s = SequenceSession(task)
        ..tap('one')
        ..tap('one');
      expect(s.mistakes, 0);
    });
  });

  group('пары', () {
    final task = buildTask(
      type: ExerciseType.matchPairs,
      content: const MatchPairsContent(
        pairs: [
          MatchPair(TaskItem(id: 'cat'), TaskItem(id: 'w_cat')),
          MatchPair(TaskItem(id: 'dog'), TaskItem(id: 'w_dog')),
        ],
      ),
    );

    test('пара засчитывается в любом порядке нажатий', () {
      final s = MatchPairsSession(task);
      expect(s.tapRight('w_dog'), isNull);
      expect(s.tapLeft('dog'), AnswerOutcome.correct);
      expect(s.isMatched('dog'), isTrue);
      expect(s.tapLeft('cat'), isNull);
      expect(s.tapRight('w_cat'), AnswerOutcome.correct);
      expect(s.isSolved, isTrue);
      expect(s.stars, 3);
    });

    test('неверная пара — ошибка, выбор сбрасывается', () {
      final s = MatchPairsSession(task)..tapLeft('cat');
      expect(s.tapRight('w_dog'), AnswerOutcome.tryAgain);
      expect(s.selectedLeft, isNull);
      expect(s.selectedRight, isNull);
      expect(s.mistakes, 1);
    });
  });

  group('сортировка', () {
    final task = buildTask(
      type: ExerciseType.sort,
      content: const GroupContent(
        groups: [
          TaskItem(id: 'red'),
          TaskItem(id: 'yellow'),
        ],
        items: [
          GroupedItem(TaskItem(id: 'strawberry'), 'red'),
          GroupedItem(TaskItem(id: 'banana'), 'yellow'),
        ],
      ),
    );

    test('предметы раскладываются по одному', () {
      final s = GroupSession(task);
      expect(s.current!.item.id, 'strawberry');
      expect(s.place('yellow'), AnswerOutcome.tryAgain);
      expect(s.place('red'), AnswerOutcome.correct);
      expect(s.current!.item.id, 'banana');
      s.place('yellow');
      expect(s.isSolved, isTrue);
      expect(s.current, isNull);
      expect(s.stars, 2);
    });
  });

  test('занятие со взрослым засчитывается по кнопке', () {
    final s = TogetherSession(
      buildTask(
        type: ExerciseType.together,
        content: const TogetherContent(steps: ['шаг']),
        rewardStars: 1,
      ),
    );
    expect(s.isSolved, isFalse);
    s.complete();
    expect(s.stars, 1);
  });

  test('для каждого типа создаётся своя сессия', () {
    expect(createSession(buildTask()), isA<ChoiceSession>());
    expect(
      createSession(
        buildTask(
          type: ExerciseType.classify,
          content: const GroupContent(groups: [], items: []),
        ),
      ),
      isA<GroupSession>(),
    );
  });
}
