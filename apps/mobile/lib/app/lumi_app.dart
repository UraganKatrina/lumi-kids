import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/lumi_theme.dart';
import 'router.dart';

/// Корневой виджет приложения LUMI Kids.
class LumiApp extends StatefulWidget {
  const LumiApp({super.key});

  @override
  State<LumiApp> createState() => _LumiAppState();
}

class _LumiAppState extends State<LumiApp> {
  final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'LUMI Kids',
      debugShowCheckedModeBanner: false,
      theme: LumiTheme.light(),
      routerConfig: _router,
    );
  }
}
