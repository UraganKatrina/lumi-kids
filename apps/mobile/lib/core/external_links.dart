import '../features/subscription/domain/subscription_store.dart';

/// Адреса документов задаются при сборке:
/// `--dart-define=LUMI_PRIVACY_URL=https://... --dart-define=LUMI_TERMS_URL=https://...`.
/// Пусто — ссылка не показывается.
class LegalLinks {
  const LegalLinks({required this.privacy, required this.terms});

  static const fromEnvironment = LegalLinks(
    privacy: String.fromEnvironment('LUMI_PRIVACY_URL'),
    terms: String.fromEnvironment('LUMI_TERMS_URL'),
  );

  final String privacy;
  final String terms;
}

/// Должен совпадать с applicationId в android/app/build.gradle.kts.
const androidPackage = 'com.lumikids.lumi_kids';

/// Страница подписок в магазине: там родитель отменяет или меняет подписку.
Uri manageSubscriptionsUri(StorePlatform platform, {String? productId}) =>
    switch (platform) {
      StorePlatform.android => Uri.https(
        'play.google.com',
        '/store/account/subscriptions',
        {'package': androidPackage, 'sku': ?productId},
      ),
      StorePlatform.ios => Uri.https(
        'apps.apple.com',
        '/account/subscriptions',
      ),
    };
