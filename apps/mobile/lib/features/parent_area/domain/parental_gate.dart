import 'dart:math';

/// Вопрос родительского барьера: умножение, которое показывается словами.
/// Дошкольник не прочитает и не посчитает его, взрослый ответит за секунды.
class GateQuestion {
  const GateQuestion(this.a, this.b)
    : assert(a >= 3 && a <= 9 && b >= 3 && b <= 9);

  final int a;
  final int b;

  int get answer => a * b;

  bool check(String input) => int.tryParse(input) == answer;

  static GateQuestion random(Random random) =>
      GateQuestion(3 + random.nextInt(7), 3 + random.nextInt(7));
}
