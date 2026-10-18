import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:lumi_kids/features/age_routes/domain/age_program.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/progress/data/progress_database.dart';
import 'package:lumi_kids/features/subscription/data/drift_entitlement_repository.dart';
import 'package:lumi_kids/features/subscription/data/http_purchase_verifier.dart';
import 'package:lumi_kids/features/subscription/domain/entitlement.dart';
import 'package:lumi_kids/features/subscription/domain/free_tier.dart';
import 'package:lumi_kids/features/subscription/domain/subscription_service.dart';
import 'package:lumi_kids/features/subscription/domain/subscription_store.dart';

import '../../support/fakes.dart';

final now = DateTime.utc(2026, 10, 18, 12);

void main() {
  group('бесплатная часть', () {
    final tasks = loadStarterTasks();
    final free = freeTaskIds(tasks);

    test('в каждом направлении каждого возраста открыты первые три', () {
      for (final program in AgeProgram.values) {
        for (final area in DevelopmentArea.values) {
          final inArea =
              tasks.where((t) => t.area == area && program.fits(t)).toList()
                ..sort(
                  (a, b) => a.difficulty != b.difficulty
                      ? a.difficulty.compareTo(b.difficulty)
                      : a.id.compareTo(b.id),
                );
          // Задание на стыке двух возрастов может быть открыто в соседней
          // программе, поэтому открытых бывает и больше трёх.
          for (final t in inArea.take(freeTasksPerArea)) {
            expect(free, contains(t.id));
          }
        }
      }
    });

    test('закрыто не всё и открыто не всё', () {
      expect(free, isNotEmpty);
      expect(free.length, lessThan(tasks.length));
    });
  });

  group('SubscriptionService', () {
    late FakeSubscriptionStore store;
    late FakePurchaseVerifier verifier;
    late InMemoryEntitlementRepository entitlements;
    late SubscriptionService service;
    late List<SubscriptionEvent> events;

    setUp(() {
      store = FakeSubscriptionStore();
      verifier = FakePurchaseVerifier();
      entitlements = InMemoryEntitlementRepository();
      service = SubscriptionService(
        store: store,
        verifier: verifier,
        entitlements: entitlements,
        clock: () => now,
      );
      events = [];
      service.events.listen(events.add);
    });

    tearDown(() => service.dispose());

    StorePurchase purchase(
      StorePurchaseStatus status, {
      String product = 'lumi_premium_monthly',
    }) => StorePurchase(
      productId: product,
      status: status,
      token: 't',
      needsCompletion: true,
    );

    test('ожидающая покупка не подтверждается и не проверяется', () async {
      await service.handle(purchase(StorePurchaseStatus.pending));
      await pumpEventQueue();
      expect(events, [SubscriptionEvent.pending]);
      expect(verifier.calls, isEmpty);
      expect(store.completed, isEmpty);
    });

    test('без сети покупка остаётся у магазина до следующего раза', () async {
      verifier.result = const VerificationResult(VerificationStatus.offline);
      await service.handle(purchase(StorePurchaseStatus.purchased));
      await pumpEventQueue();
      expect(events, [SubscriptionEvent.verifyOffline]);
      expect(store.completed, isEmpty);
      expect(entitlements.entitlement, isNull);
    });

    test('чужой товар не проверяется', () async {
      await service.handle(
        purchase(StorePurchaseStatus.purchased, product: 'other'),
      );
      await pumpEventQueue();
      expect(events, [SubscriptionEvent.verifyFailed]);
      expect(verifier.calls, isEmpty);
    });

    test('отмена закрывает транзакцию', () async {
      await service.handle(purchase(StorePurchaseStatus.canceled));
      await pumpEventQueue();
      expect(events, [SubscriptionEvent.canceled]);
      expect(store.completed, hasLength(1));
    });

    test('покупки из потока магазина обрабатываются после start', () async {
      verifier.result = VerificationResult(
        VerificationStatus.active,
        expiresAt: now.add(const Duration(days: 365)),
      );
      service.start();
      store.emit([purchase(StorePurchaseStatus.restored)]);
      await pumpEventQueue();
      expect(events, [SubscriptionEvent.activated]);
      expect(entitlements.entitlement?.verifiedAt, now);
    });
  });

  group('HttpPurchaseVerifier', () {
    Future<VerificationResult> verify(
      MockClientHandler handler, {
      String baseUrl = 'https://api.test',
    }) => HttpPurchaseVerifier(baseUrl: baseUrl, client: MockClient(handler))
        .verify(
          platform: StorePlatform.ios,
          productId: 'lumi_premium_yearly',
          token: '2000000123',
        );

    test('отправляет только товар и токен', () async {
      late Map<String, Object?> sent;
      final result = await verify((request) async {
        expect(request.url.toString(), 'https://api.test/v1/purchases/verify');
        sent = jsonDecode(request.body) as Map<String, Object?>;
        return http.Response(
          jsonEncode({
            'active': true,
            'productId': 'lumi_premium_yearly',
            'expiresAt': '2027-10-18T12:00:00.000Z',
          }),
          200,
        );
      });
      expect(sent, {
        'platform': 'ios',
        'productId': 'lumi_premium_yearly',
        'token': '2000000123',
      });
      expect(result.status, VerificationStatus.active);
      expect(result.expiresAt, DateTime.utc(2027, 10, 18, 12));
    });

    test('ответы сервера', () async {
      expect(
        (await verify((_) async => http.Response('{}', 503))).status,
        VerificationStatus.notConfigured,
      );
      expect(
        (await verify((_) async => http.Response('{}', 502))).status,
        VerificationStatus.failed,
      );
      expect(
        (await verify(
          (_) async => http.Response(
            jsonEncode({
              'active': true,
              'productId': 'lumi_premium_monthly',
              'expiresAt': '2027-10-18T12:00:00.000Z',
            }),
            200,
          ),
        )).status,
        VerificationStatus.failed,
        reason: 'сервер подтвердил другой товар',
      );
      expect(
        (await verify(
          (_) async => http.Response(
            jsonEncode({'active': false, 'productId': 'lumi_premium_yearly'}),
            200,
          ),
        )).status,
        VerificationStatus.inactive,
      );
      expect(
        (await verify((_) async => throw http.ClientException('нет сети')))
            .status,
        VerificationStatus.offline,
      );
      expect(
        (await verify(
          (_) async => fail('запроса быть не должно'),
          baseUrl: '',
        )).status,
        VerificationStatus.notConfigured,
      );
    });
  });

  test('подписка хранится на телефоне и действует до даты окончания', () async {
    final db = ProgressDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final repo = DriftEntitlementRepository(db);
    expect(await repo.load(), isNull);

    final entitlement = Entitlement(
      productId: 'lumi_premium_yearly',
      expiresAt: now.add(const Duration(days: 1)),
      verifiedAt: now,
    );
    await repo.save(entitlement);
    final loaded = await repo.load();
    expect(loaded?.productId, 'lumi_premium_yearly');
    expect(loaded!.activeAt(now), isTrue);
    expect(loaded.activeAt(now.add(const Duration(days: 2))), isFalse);

    await repo.clear();
    expect(await repo.load(), isNull);
  });
}
