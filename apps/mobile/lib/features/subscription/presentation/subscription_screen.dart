import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/external_links.dart';
import '../../../core/widgets/external_link_button.dart';
import '../../../l10n/l10n.dart';
import '../domain/entitlement.dart';
import '../domain/free_tier.dart';
import '../domain/subscription_service.dart';
import '../domain/subscription_store.dart';

/// Магазин доступен и какие подписки в нём заведены.
final storeOffersProvider = FutureProvider.autoDispose<List<StoreProduct>?>((
  ref,
) async {
  final store = ref.watch(subscriptionStoreProvider);
  if (!await store.isAvailable()) return null;
  final products = await store.products(premiumProductIds);
  // Месяц, потом год, как в списке PremiumPlan.
  return [
    for (final plan in PremiumPlan.values)
      ...products.where((p) => p.id == plan.productId),
  ];
});

/// Экран подписки. Открывается только из кабинета родителя, то есть после
/// родительского барьера; ребёнок сюда не попадает.
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  StreamSubscription<SubscriptionEvent>? _events;
  String? _message;

  @override
  void initState() {
    super.initState();
    _events = ref.read(subscriptionServiceProvider).events.listen((event) {
      if (!mounted) return;
      setState(() => _message = _describe(context.l10n, event));
    });
  }

  @override
  void dispose() {
    _events?.cancel();
    super.dispose();
  }

  static String _describe(AppLocalizations l10n, SubscriptionEvent event) =>
      switch (event) {
        SubscriptionEvent.pending => l10n.subPending,
        SubscriptionEvent.activated => l10n.subActivated,
        SubscriptionEvent.notActive => l10n.subNotActive,
        SubscriptionEvent.canceled => l10n.subCanceled,
        SubscriptionEvent.storeError => l10n.subStoreError,
        SubscriptionEvent.verifyNotConfigured => l10n.subVerifyNotConfigured,
        SubscriptionEvent.verifyOffline => l10n.subVerifyOffline,
        SubscriptionEvent.verifyFailed => l10n.subVerifyFailed,
      };

  Future<void> _buy(String productId) async {
    try {
      await ref.read(subscriptionStoreProvider).buy(productId);
    } catch (_) {
      if (mounted) setState(() => _message = context.l10n.subStoreError);
    }
  }

  Future<void> _restore() async {
    setState(() => _message = context.l10n.subRestoreSent);
    try {
      await ref.read(subscriptionStoreProvider).restore();
    } catch (_) {
      if (mounted) setState(() => _message = context.l10n.subStoreError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final offers = ref.watch(storeOffersProvider);
    final active = ref.watch(premiumActiveProvider).value ?? false;
    final entitlement = ref.watch(entitlementProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.subTitle),
        leading: IconButton(
          key: const Key('sub.back'),
          iconSize: 36,
          tooltip: l10n.commonBack,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/parent'),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(LumiSpacing.m),
        children: [
          SubscriptionStatusText(key: const Key('sub.status')),
          const SizedBox(height: LumiSpacing.m),
          Text(l10n.subBenefits, style: text.bodyLarge),
          const SizedBox(height: LumiSpacing.l),
          if (!active || entitlement == null)
            offers.when(
              loading: () => Text(l10n.subLoading, style: text.bodyLarge),
              error: (_, _) => Text(l10n.subNoProducts, style: text.bodyLarge),
              data: (products) {
                if (products == null) {
                  return Text(
                    l10n.subUnavailable,
                    key: const Key('sub.unavailable'),
                    style: text.bodyLarge,
                  );
                }
                if (products.isEmpty) {
                  return Text(
                    l10n.subNoProducts,
                    key: const Key('sub.noProducts'),
                    style: text.bodyLarge,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final p in products)
                      Padding(
                        padding: const EdgeInsets.only(bottom: LumiSpacing.s),
                        child: FilledButton(
                          key: Key('sub.buy.${p.id}'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, LumiSizes.minTapTarget),
                          ),
                          onPressed: () => _buy(p.id),
                          child: Text(
                            PremiumPlan.fromProductId(p.id) ==
                                    PremiumPlan.yearly
                                ? l10n.subYearly(p.price)
                                : l10n.subMonthly(p.price),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          if (_message != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: LumiSpacing.s),
              child: Text(
                _message!,
                key: const Key('sub.message'),
                style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          OutlinedButton.icon(
            key: const Key('sub.restore'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, LumiSizes.minTapTarget),
            ),
            icon: const Icon(Icons.restore_rounded),
            label: Text(l10n.subRestore),
            onPressed: _restore,
          ),
          if (ref.watch(subscriptionStoreProvider).platform
              case final platform?)
            ExternalLinkButton(
              key: const Key('sub.manage'),
              label: l10n.subManage,
              icon: Icons.manage_accounts_rounded,
              uri: manageSubscriptionsUri(
                platform,
                productId: active ? entitlement?.productId : null,
              ),
            ),
          const SizedBox(height: LumiSpacing.l),
          Text(l10n.subTerms, style: text.bodyMedium),
          const SizedBox(height: LumiSpacing.s),
          Text(l10n.subPrivacy, style: text.bodyMedium),
          const SizedBox(height: LumiSpacing.s),
          // Apple требует ссылки на условия и политику рядом с покупкой.
          const LegalLinksView(),
        ],
      ),
    );
  }
}

/// Строка о текущем состоянии: бесплатная версия или подписка до даты.
class SubscriptionStatusText extends ConsumerWidget {
  const SubscriptionStatusText({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final active = ref.watch(premiumActiveProvider).value ?? false;
    final entitlement = ref.watch(entitlementProvider).value;
    final language = Localizations.localeOf(context).languageCode;
    final status = active && entitlement != null
        ? l10n.subStatusActive(
            DateFormat.yMMMMd(language).format(entitlement.expiresAt.toLocal()),
          )
        : l10n.subStatusFree(l10n.subFreeTasks(freeTasksPerArea));
    return Text(status, style: Theme.of(context).textTheme.bodyLarge);
  }
}
