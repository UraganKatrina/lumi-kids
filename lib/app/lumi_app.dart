import 'package:flutter/material.dart';

import '../features/home/home_screen.dart';
import 'lumi_theme.dart';

/// Корневой виджет приложения LUMI Kids.
class LumiApp extends StatelessWidget {
  const LumiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LUMI Kids',
      debugShowCheckedModeBanner: false,
      theme: LumiTheme.light(),
      home: const HomeScreen(),
    );
  }
}
