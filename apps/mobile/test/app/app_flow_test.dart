import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/app/lumi_app.dart';
import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/core/design_system/lumi_tokens.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';

import '../support/fakes.dart';

Future<InMemoryProgressRepository> pumpApp(WidgetTester tester) async {
  // Как при системной настройке «уменьшить движение»: персонаж не парит,
  // и pumpAndSettle не ждёт бесконечную анимацию.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);

  final progress = InMemoryProgressRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contentRepositoryProvider.overrideWithValue(FileContentRepository()),
        progressRepositoryProvider.overrideWithValue(progress),
      ],
      child: const LumiApp(),
    ),
  );
  await tester.pumpAndSettle();
  return progress;
}

void main() {
  testWidgets('на карте 12 островов, пустые помечены «скоро»', (tester) async {
    await pumpApp(tester);

    expect(find.text('Привет! Я Люми.'), findsOneWidget);
    for (final area in DevelopmentArea.values) {
      await tester.scrollUntilVisible(
        find.byKey(Key('island.${area.code}')),
        100,
      );
      expect(find.byKey(Key('island.${area.code}')), findsOneWidget);
    }
    expect(find.text('скоро'), findsWidgets);
  });

  testWidgets(
    'путь ребёнка: остров → задание → ошибка с подсказкой → верный ответ → '
    'результат → прогресс сохранён',
    (tester) async {
      final progress = await pumpApp(tester);

      await tester.tap(find.byKey(const Key('island.math')));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const Key('task.math.count.apples.001')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const Key('task.math.count.apples.001')));
      await tester.pumpAndSettle();
      expect(find.text('Сколько яблок?'), findsOneWidget);

      // Ошибка: вариант гаснет, Люми подсказывает.
      await tester.tap(find.byKey(const Key('option.n2')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('exercise.hint')), findsOneWidget);

      await tester.tap(find.byKey(const Key('option.n3')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('result.title')), findsOneWidget);
      expect(find.byKey(const Key('result.next')), findsOneWidget);

      expect(progress.attempts, hasLength(1));
      final saved = progress.attempts.single;
      expect(saved.taskId, 'math.count.apples.001');
      expect(saved.mistakes, 1);
      expect(saved.stars, 2);

      // «Дальше» открывает следующее задание острова.
      await tester.tap(find.byKey(const Key('result.next')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('exercise.instruction')), findsOneWidget);
      expect(find.text('Сколько яблок?'), findsNothing);

      // Возврат на карту показывает заработанные звёзды.
      await tester.tap(find.byKey(const Key('exercise.close')));
      await tester.pumpAndSettle();
      expect(
        find.descendant(
          of: find.byKey(const Key('map.stars')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('варианты ответа достаточно крупные для детских пальцев', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.ensureVisible(find.byKey(const Key('island.world')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('island.world')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('task.world.animal.moo.001')));
    await tester.pumpAndSettle();

    for (final id in ['cow', 'cat', 'dog']) {
      final size = tester.getSize(find.byKey(Key('option.$id')));
      expect(size.shortestSide, greaterThanOrEqualTo(LumiSizes.minTapTarget));
    }
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
