import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../domain/subscription_store.dart';

/// Google Play Billing и App Store через официальный плагин Flutter.
class InAppPurchaseStore implements SubscriptionStore {
  InAppPurchaseStore([InAppPurchase? plugin]) : _pluginOverride = plugin;

  final InAppPurchase? _pluginOverride;

  // Плагин создаётся лениво: на неподдерживаемых платформах сам вызов
  // InAppPurchase.instance бросает исключение.
  InAppPurchase get _plugin => _pluginOverride ?? InAppPurchase.instance;

  final Map<String, ProductDetails> _details = {};

  @override
  StorePlatform? get platform => switch (defaultTargetPlatform) {
    _ when kIsWeb => null,
    TargetPlatform.android => StorePlatform.android,
    TargetPlatform.iOS => StorePlatform.ios,
    _ => null,
  };

  @override
  Future<bool> isAvailable() async {
    if (platform == null) return false;
    try {
      return await _plugin.isAvailable();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<StoreProduct>> products(Set<String> ids) async {
    final response = await _plugin.queryProductDetails(ids);
    for (final d in response.productDetails) {
      _details[d.id] = d;
    }
    return [
      for (final d in response.productDetails)
        StoreProduct(id: d.id, price: d.price),
    ];
  }

  @override
  Stream<List<StorePurchase>> get purchases {
    if (platform == null) return const Stream.empty();
    return _plugin.purchaseStream.map(
      (batch) => [for (final p in batch) _convert(p)],
    );
  }

  StorePurchase _convert(PurchaseDetails p) => StorePurchase(
    productId: p.productID,
    status: switch (p.status) {
      PurchaseStatus.pending => StorePurchaseStatus.pending,
      PurchaseStatus.purchased => StorePurchaseStatus.purchased,
      PurchaseStatus.restored => StorePurchaseStatus.restored,
      PurchaseStatus.canceled => StorePurchaseStatus.canceled,
      PurchaseStatus.error => StorePurchaseStatus.error,
    },
    // Google Play проверяется по purchaseToken, App Store (StoreKit 2)
    // по идентификатору транзакции.
    token: platform == StorePlatform.ios
        ? p.purchaseID
        : p.verificationData.serverVerificationData,
    needsCompletion: p.pendingCompletePurchase,
    handle: p,
  );

  @override
  Future<void> buy(String productId) async {
    final details = _details[productId];
    if (details == null) {
      throw StateError('Подписка $productId не загружена из магазина');
    }
    // Плагин оформляет подписки тем же методом, что и разовые покупки.
    await _plugin.buyNonConsumable(
      purchaseParam: PurchaseParam(productDetails: details),
    );
  }

  @override
  Future<void> restore() => _plugin.restorePurchases();

  @override
  Future<void> complete(StorePurchase purchase) async {
    final handle = purchase.handle;
    if (handle is PurchaseDetails) await _plugin.completePurchase(handle);
  }
}
