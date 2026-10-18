import 'dart:async';

import 'entitlement.dart';
import 'subscription_store.dart';

/// Что сообщить родителю после события магазина.
enum SubscriptionEvent {
  pending,
  activated,
  notActive,
  canceled,
  storeError,
  verifyNotConfigured,
  verifyOffline,
  verifyFailed,
}

/// Слушает магазин, проверяет каждую покупку на сервере и сохраняет
/// подписку. Платная часть открывается только после ответа сервера.
class SubscriptionService {
  SubscriptionService({
    required this.store,
    required this.verifier,
    required this.entitlements,
    required this.clock,
  });

  final SubscriptionStore store;
  final PurchaseVerifier verifier;
  final EntitlementRepository entitlements;
  final DateTime Function() clock;

  final _events = StreamController<SubscriptionEvent>.broadcast();
  StreamSubscription<List<StorePurchase>>? _subscription;

  Stream<SubscriptionEvent> get events => _events.stream;

  /// Вызывается при запуске: магазин присылает и незавершённые покупки.
  void start() {
    _subscription ??= store.purchases.listen((batch) async {
      for (final purchase in batch) {
        await handle(purchase);
      }
    }, onError: (Object _) => _events.add(SubscriptionEvent.storeError));
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _events.close();
  }

  Future<void> handle(StorePurchase purchase) async {
    switch (purchase.status) {
      case StorePurchaseStatus.pending:
        _emit(SubscriptionEvent.pending);
      case StorePurchaseStatus.canceled:
        _emit(SubscriptionEvent.canceled);
        await _complete(purchase);
      case StorePurchaseStatus.error:
        _emit(SubscriptionEvent.storeError);
        await _complete(purchase);
      case StorePurchaseStatus.purchased || StorePurchaseStatus.restored:
        await _verify(purchase);
    }
  }

  Future<void> _verify(StorePurchase purchase) async {
    final platform = store.platform;
    final token = purchase.token;
    if (platform == null ||
        token == null ||
        !premiumProductIds.contains(purchase.productId)) {
      _emit(SubscriptionEvent.verifyFailed);
      return;
    }
    final result = await verifier.verify(
      platform: platform,
      productId: purchase.productId,
      token: token,
    );
    final expiresAt = result.expiresAt;
    switch (result.status) {
      case VerificationStatus.active when expiresAt != null:
        await entitlements.save(
          Entitlement(
            productId: purchase.productId,
            expiresAt: expiresAt,
            verifiedAt: clock(),
          ),
        );
        // Подтверждаем магазину только проверенную покупку. Google Play
        // вернёт деньги за неподтверждённую через три дня.
        await _complete(purchase);
        _emit(SubscriptionEvent.activated);
      case VerificationStatus.active || VerificationStatus.inactive:
        // Истекшая подписка при восстановлении: обработана, но не активна.
        await _complete(purchase);
        _emit(SubscriptionEvent.notActive);
      case VerificationStatus.notConfigured:
        _emit(SubscriptionEvent.verifyNotConfigured);
      case VerificationStatus.offline:
        _emit(SubscriptionEvent.verifyOffline);
      case VerificationStatus.failed:
        _emit(SubscriptionEvent.verifyFailed);
    }
  }

  Future<void> _complete(StorePurchase purchase) async {
    if (purchase.needsCompletion) await store.complete(purchase);
  }

  void _emit(SubscriptionEvent event) {
    if (!_events.isClosed) _events.add(event);
  }
}
