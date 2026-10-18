/// Подписка в магазине с ценой в валюте покупателя.
class StoreProduct {
  const StoreProduct({required this.id, required this.price});

  final String id;

  /// Цена строкой от магазина, например «49 900 сўм».
  final String price;
}

enum StorePurchaseStatus { pending, purchased, restored, canceled, error }

class StorePurchase {
  const StorePurchase({
    required this.productId,
    required this.status,
    this.token,
    this.needsCompletion = false,
    this.handle,
  });

  final String productId;
  final StorePurchaseStatus status;

  /// То, что сервер проверяет у магазина: purchaseToken в Google Play,
  /// transactionId в App Store.
  final String? token;

  /// Магазин ждёт подтверждения, что покупка обработана.
  final bool needsCompletion;

  /// Объект магазина, нужен адаптеру для подтверждения.
  final Object? handle;
}

/// Платформа магазина, как её понимает сервер.
enum StorePlatform {
  android('android'),
  ios('ios');

  const StorePlatform(this.code);

  final String code;
}

/// Магазин приложений. В тестах подменяется.
abstract interface class SubscriptionStore {
  StorePlatform? get platform;

  Future<bool> isAvailable();

  Future<List<StoreProduct>> products(Set<String> ids);

  Stream<List<StorePurchase>> get purchases;

  Future<void> buy(String productId);

  Future<void> restore();

  Future<void> complete(StorePurchase purchase);
}

enum VerificationStatus { active, inactive, notConfigured, offline, failed }

class VerificationResult {
  const VerificationResult(this.status, {this.expiresAt});

  final VerificationStatus status;
  final DateTime? expiresAt;
}

/// Проверка покупки на нашем сервере. В приложении нет ключей магазинов.
abstract interface class PurchaseVerifier {
  Future<VerificationResult> verify({
    required StorePlatform platform,
    required String productId,
    required String token,
  });
}
