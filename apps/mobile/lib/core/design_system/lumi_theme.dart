import 'package:flutter/material.dart';

import 'lumi_tokens.dart';

abstract final class LumiTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: LumiColors.primary,
      primary: LumiColors.primary,
      surface: LumiColors.sky,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: LumiColors.sky,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontWeight: FontWeight.w800,
          color: LumiColors.ink,
        ),
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: LumiColors.ink,
        ),
        titleLarge: TextStyle(
          fontWeight: FontWeight.w700,
          color: LumiColors.ink,
        ),
        bodyLarge: TextStyle(fontSize: 20, color: LumiColors.ink),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            LumiSizes.minTapTarget * 3,
            LumiSizes.minTapTarget,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(LumiSizes.radius),
          ),
          textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: LumiColors.ink,
        elevation: 0,
        centerTitle: true,
      ),
    );
  }
}
