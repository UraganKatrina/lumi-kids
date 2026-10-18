import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/lumi_theme.dart';
import 'providers.dart';
import 'router.dart';

/// Корневой виджет приложения LUMI Kids.
class LumiApp extends ConsumerStatefulWidget {
  const LumiApp({super.key});

  @override
  ConsumerState<LumiApp> createState() => _LumiAppState();
}

class _LumiAppState extends ConsumerState<LumiApp> {
  final GoRouter _router = createRouter();

  @override
  void initState() {
    super.initState();
    // Тихо проверяем новые задания в фоне; без сети ничего не случится.
    ref.read(packUpdateProvider.future).ignore();
  }

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
