import 'dart:math';

/// Вопрос родительского барьера: умножение, записанное словами.
/// Дошкольник не прочитает и не посчитает его, взрослый ответит за секунды.
class GateQuestion {
  const GateQuestion(this.a, this.b)
    : assert(a >= 3 && a <= 9 && b >= 3 && b <= 9);

  final int a;
  final int b;

  static const _words = {
    3: 'три',
    4: 'четыре',
    5: 'пять',
    6: 'шесть',
    7: 'семь',
    8: 'восемь',
    9: 'девять',
  };

  int get answer => a * b;

  String get text => 'Сколько будет ${_words[a]} умножить на ${_words[b]}?';

  bool check(String input) => int.tryParse(input) == answer;

  static GateQuestion random(Random random) =>
      GateQuestion(3 + random.nextInt(7), 3 + random.nextInt(7));
}
