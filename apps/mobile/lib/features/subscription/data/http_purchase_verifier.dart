import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/subscription_store.dart';

/// Отправляет на наш сервер только идентификатор подписки и токен покупки.
/// Имя ребёнка, возраст и прогресс не передаются.
class HttpPurchaseVerifier implements PurchaseVerifier {
  HttpPurchaseVerifier({required this.baseUrl, required this.client});

  final String baseUrl;
  final http.Client client;

  @override
  Future<VerificationResult> verify({
    required StorePlatform platform,
    required String productId,
    required String token,
  }) async {
    if (baseUrl.isEmpty) {
      return const VerificationResult(VerificationStatus.notConfigured);
    }
    final http.Response response;
    try {
      response = await client
          .post(
            Uri.parse(baseUrl).resolve('/v1/purchases/verify'),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'platform': platform.code,
              'productId': productId,
              'token': token,
            }),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      return const VerificationResult(VerificationStatus.offline);
    }
    if (response.statusCode == 503) {
      return const VerificationResult(VerificationStatus.notConfigured);
    }
    if (response.statusCode != 200) {
      return const VerificationResult(VerificationStatus.failed);
    }
    try {
      final body = jsonDecode(response.body) as Map<String, Object?>;
      if (body['productId'] != productId) {
        return const VerificationResult(VerificationStatus.failed);
      }
      final expiresAt = DateTime.tryParse('${body['expiresAt']}');
      if (body['active'] == true && expiresAt != null) {
        return VerificationResult(
          VerificationStatus.active,
          expiresAt: expiresAt,
        );
      }
      return const VerificationResult(VerificationStatus.inactive);
    } catch (_) {
      return const VerificationResult(VerificationStatus.failed);
    }
  }
}
