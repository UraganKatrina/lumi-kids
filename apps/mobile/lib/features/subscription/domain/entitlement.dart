/// Подписки, которые продаёт приложение. Те же идентификаторы заводятся в
/// Google Play Console и App Store Connect и перечисляются на сервере.
enum PremiumPlan {
  monthly('lumi_premium_monthly'),
  yearly('lumi_premium_yearly');

  const PremiumPlan(this.productId);

  final String productId;

  static PremiumPlan? fromProductId(String id) {
    for (final plan in values) {
      if (plan.productId == id) return plan;
    }
    return null;
  }
}

final premiumProductIds = {for (final p in PremiumPlan.values) p.productId};

/// Подтверждённая сервером подписка. Хранится на телефоне, чтобы платная
/// часть работала без интернета до даты окончания.
class Entitlement {
  const Entitlement({
    required this.productId,
    required this.expiresAt,
    required this.verifiedAt,
  });

  final String productId;
  final DateTime expiresAt;
  final DateTime verifiedAt;

  bool activeAt(DateTime now) => now.isBefore(expiresAt);

  Map<String, Object?> toJson() => {
    'productId': productId,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
    'verifiedAt': verifiedAt.toUtc().toIso8601String(),
  };

  static Entitlement? fromJson(Object? json) {
    if (json is! Map) return null;
    final productId = json['productId'];
    final expiresAt = DateTime.tryParse('${json['expiresAt']}');
    final verifiedAt = DateTime.tryParse('${json['verifiedAt']}');
    if (productId is! String || expiresAt == null || verifiedAt == null) {
      return null;
    }
    return Entitlement(
      productId: productId,
      expiresAt: expiresAt,
      verifiedAt: verifiedAt,
    );
  }
}

abstract interface class EntitlementRepository {
  Future<Entitlement?> load();

  Future<void> save(Entitlement entitlement);

  Future<void> clear();
}
