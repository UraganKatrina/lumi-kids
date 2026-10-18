import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/parent_area/domain/parental_gate.dart';

void main() {
  test('вопрос записан словами, без цифр', () {
    const q = GateQuestion(6, 7);
    expect(q.text, 'Сколько будет шесть умножить на семь?');
    expect(q.text, isNot(matches(RegExp(r'\d'))));
    expect(q.answer, 42);
  });

  test('проверка ответа', () {
    const q = GateQuestion(3, 4);
    expect(q.check('12'), isTrue);
    expect(q.check('7'), isFalse);
    expect(q.check(''), isFalse);
  });

  test('случайные вопросы в диапазоне 3–9 и разные', () {
    final random = Random(1);
    final questions = [
      for (var i = 0; i < 200; i++) GateQuestion.random(random),
    ];
    for (final q in questions) {
      expect(q.a, inInclusiveRange(3, 9));
      expect(q.b, inInclusiveRange(3, 9));
      expect(q.text, isNot(contains('null')));
    }
    expect(questions.map((q) => q.answer).toSet().length, greaterThan(10));
  });
}
