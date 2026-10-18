import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'app_flow_test.dart';

/// Правила доступности Flutter: кнопки не меньше 48×48, у каждой есть
/// подпись для экранного диктора, текст достаточно контрастный.
Future<void> expectAccessible(WidgetTester tester) async {
  final handle = tester.ensureSemantics();
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
  handle.dispose();
}

void main() {
  testWidgets('карта', (tester) async {
    await pumpApp(tester);
    await expectAccessible(tester);
  });

  testWidgets('остров с закрытыми заданиями', (tester) async {
    await pumpApp(tester);
    await tapKey(tester, 'island.math');
    await expectAccessible(tester);
  });

  testWidgets('задание', (tester) async {
    await pumpApp(tester, premium: true);
    await openTask(tester, 'math.shapes.sort.001');
    await expectAccessible(tester);
  });

  testWidgets('родительский барьер', (tester) async {
    await pumpApp(tester);
    await scrollToTop(tester);
    await tapKey(tester, 'map.parent');
    await expectAccessible(tester);
  });

  testWidgets('кабинет родителя', (tester) async {
    await pumpApp(tester);
    await openParentArea(tester);
    await expectAccessible(tester);
  });

  testWidgets('экран подписки', (tester) async {
    await pumpApp(tester);
    await openParentArea(tester);
    await tapKey(tester, 'parent.openSubscription');
    await expectAccessible(tester);
  });

  testWidgets('первый запуск', (tester) async {
    await pumpApp(tester, age: null);
    expect(find.byKey(const Key('welcome.title')), findsOneWidget);
    await expectAccessible(tester);
  });

  // Узбекские строки длиннее русских, а крупный шрифт в настройках телефона
  // увеличивает их ещё сильнее: ничего не должно вылезать за край экрана.
  for (final language in ['ru', 'uz', 'en']) {
    testWidgets('крупный шрифт, язык $language', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 1.6;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await pumpApp(tester, language: language);
      await tapKey(tester, 'island.math');
      await tapKey(tester, 'area.back');
      await openParentArea(tester);
      await tapKey(tester, 'parent.openSubscription');
      expect(tester.takeException(), isNull);
    });
  }
}
