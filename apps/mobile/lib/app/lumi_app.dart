import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/design_system/lumi_theme.dart';
import '../features/subscription/domain/subscription_service.dart';
import '../l10n/l10n.dart';
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
  StreamSubscription<SubscriptionEvent>? _events;

  @override
  void initState() {
    super.initState();
    // Тихо проверяем новые задания в фоне; без сети ничего не случится.
    ref.read(packUpdateProvider.future).ignore();
    // Магазин досылает незавершённые покупки при каждом запуске.
    final subscriptions = ref.read(subscriptionServiceProvider);
    _events = subscriptions.events.listen((event) {
      if (event == SubscriptionEvent.activated) {
        ref.invalidate(entitlementProvider);
      }
    });
    subscriptions.start();
  }

  @override
  void dispose() {
    _events?.cancel();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final language = ref.watch(languageProvider).value ?? 'ru';
    return MaterialApp.router(
      title: 'LUMI Kids',
      locale: Locale(language),
      supportedLocales: [for (final l in supportedLanguages) Locale(l)],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: LumiTheme.light(),
      routerConfig: _router,
    );
  }
}
