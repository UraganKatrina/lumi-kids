import 'package:flutter/material.dart';

/// Цвета бренда. Яркие, но не кислотные; текст на них проходит контраст 4.5:1.
abstract final class LumiColors {
  static const Color primary = Color(0xFF5B4BDB);
  static const Color sky = Color(0xFFE8F4FF);
  static const Color sea = Color(0xFF8FD3F4);
  static const Color sand = Color(0xFFFFE8B8);
  static const Color glow = Color(0xFFFFD447);
  static const Color success = Color(0xFF2E9E5B);
  static const Color gentleError = Color(0xFFE5793B);
  static const Color ink = Color(0xFF1E1B3A);
}

/// Шкала отступов, кратная 4.
abstract final class LumiSpacing {
  static const double xs = 4;
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
  static const double xl = 32;
}

/// Размеры для детских пальцев: больше стандартных 48 dp.
abstract final class LumiSizes {
  static const double minTapTarget = 64;
  static const double answerCard = 120;
  static const double radius = 24;
}

/// Длительности анимаций: короткие, чтобы ребёнок не ждал.
abstract final class LumiDurations {
  static const Duration quick = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
}
