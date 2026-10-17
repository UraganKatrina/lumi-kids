import 'package:flutter/material.dart';

/// Базовая тема. Полная дизайн-система появится на этапе 2.
abstract final class LumiTheme {
  static const Color seed = Color(0xFF6C5CE7);

  /// Минимальный размер нажимаемой области для детских пальцев.
  static const double minTapTarget = 64;

  static ThemeData light() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: seed),
      useMaterial3: true,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(minTapTarget * 3, minTapTarget),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
