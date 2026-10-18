import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/features/subscription/domain/subscription_store.dart';

import 'app_flow_test.dart';

/// Задание дошкольной программы, которое без подписки закрыто.
const lockedTask = 'math.shapes.sort.001';

Future<void> openSubscription(WidgetTester tester) async {
  await openParentArea(tester);
  await tapKey(tester, 'parent.openSubscription');
  expect(find.byKey(const Key('sub.restore')), findsOneWidget);
}

Future<void> backToMap(WidgetTester tester) async {
  await tapKey(tester, 'sub.back');
  await tapKey(tester, 'parent.close');
}

void main() {
  testWidgets('ребёнок видит замок, а не покупку', (tester) async {
    await pumpApp(tester);
    final task = starterTask(lockedTask);
    await tapKey(tester, 'island.${task.area.code}');
    await tapKey(tester, 'task.$lockedTask');

    expect(find.byKey(const Key('locked.view')), findsOneWidget);
    expect(find.text(task.instruction), findsNothing);
    expect(find.textContaining('UZS'), findsNothing);
    await tapKey(tester, 'locked.close');
    expect(find.byKey(const Key('locked.view')), findsNothing);
  });

  testWidgets('родитель оформляет подписку, сервер её подтверждает', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    app.store.onBuy = (id) => StorePurchase(
      productId: id,
      status: StorePurchaseStatus.purchased,
      token: 'play-token',
      needsCompletion: true,
    );
    app.verifier.result = VerificationResult(
      VerificationStatus.active,
      expiresAt: testNow.add(const Duration(days: 30)),
    );

    await openSubscription(tester);
    expect(find.textContaining('бесплатная версия'), findsOneWidget);
    expect(find.text('Месяц: 49 000 UZS'), findsOneWidget);
    expect(find.text('Год: 399 000 UZS'), findsOneWidget);

    await tapKey(tester, 'sub.buy.lumi_premium_monthly');

    expect(app.verifier.calls.single, (
      StorePlatform.android,
      'lumi_premium_monthly',
      'play-token',
    ));
    expect(app.store.completed, hasLength(1));
    expect(app.entitlements.entitlement?.productId, 'lumi_premium_monthly');
    expect(find.text('Готово! Подписка активна.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const Key('sub.status')),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('Подписка активна до'), findsOneWidget);
    expect(find.byKey(const Key('sub.buy.lumi_premium_monthly')), findsNothing);

    await backToMap(tester);
    await openTask(tester, lockedTask);
  });

  testWidgets('без проверки на сервере подписка не открывается', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    app.store.onBuy = (id) => StorePurchase(
      productId: id,
      status: StorePurchaseStatus.purchased,
      token: 'play-token',
      needsCompletion: true,
    );

    await openSubscription(tester);
    await tapKey(tester, 'sub.buy.lumi_premium_yearly');

    expect(find.byKey(const Key('sub.message')), findsOneWidget);
    expect(find.textContaining('проверка покупок ещё не подключена'), findsOne);
    // Покупка не подтверждена магазину: он пришлёт её снова при запуске.
    expect(app.store.completed, isEmpty);
    expect(app.entitlements.entitlement, isNull);

    await backToMap(tester);
    final task = starterTask(lockedTask);
    await tapKey(tester, 'island.${task.area.code}');
    await tapKey(tester, 'task.$lockedTask');
    expect(find.byKey(const Key('locked.view')), findsOneWidget);
  });

  testWidgets('восстановление покупок и магазин без подписок', (tester) async {
    final app = await pumpApp(tester);
    app.store.offered.clear();
    await openSubscription(tester);
    expect(find.byKey(const Key('sub.noProducts')), findsOneWidget);

    await tapKey(tester, 'sub.restore');
    expect(app.store.restores, 1);
    expect(find.text('Ищем ваши покупки в магазине…'), findsOneWidget);

    app.verifier.result = const VerificationResult(VerificationStatus.inactive);
    app.store.emit([
      const StorePurchase(
        productId: 'lumi_premium_yearly',
        status: StorePurchaseStatus.restored,
        token: 'old-token',
        needsCompletion: true,
      ),
    ]);
    await tester.pumpAndSettle();
    expect(
      find.text('Покупка найдена, но срок подписки закончился.'),
      findsOne,
    );
    expect(app.store.completed, hasLength(1));
  });

  testWidgets('ссылки на документы и управление подпиской', (tester) async {
    final app = await pumpApp(tester, premium: true);
    await openParentArea(tester);
    await tapKey(tester, 'parent.openSubscription');
    await tapKey(tester, 'link.terms');
    expect(app.openedLinks.last, Uri.parse('https://lumi.test/terms'));
    await tapKey(tester, 'sub.manage');
    expect(
      app.openedLinks.last,
      Uri.parse(
        'https://play.google.com/store/account/subscriptions'
        '?package=com.lumikids.lumi_kids&sku=lumi_premium_yearly',
      ),
    );

    await tapKey(tester, 'sub.back');
    await tapKey(tester, 'link.privacy');
    expect(app.openedLinks.last, Uri.parse('https://lumi.test/privacy'));
  });
}
