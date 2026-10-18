import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/app/lumi_app.dart';
import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/core/design_system/lumi_tokens.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/progress/data/settings_repository.dart';

import '../support/fakes.dart';

class TestApp {
  TestApp(this.progress, this.settings);

  final InMemoryProgressRepository progress;
  final InMemorySettingsRepository settings;
}

Future<TestApp> pumpApp(
  WidgetTester tester, {
  String? age = 'preschool',
}) async {
  // Как при системной настройке «уменьшить движение»: персонаж не парит,
  // и pumpAndSettle не ждёт бесконечную анимацию.
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.75;
  addTearDown(tester.view.reset);

  final app = TestApp(
    InMemoryProgressRepository(),
    InMemorySettingsRepository({SettingsRepository.ageProgramKey: ?age}),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        contentRepositoryProvider.overrideWithValue(FileContentRepository()),
        progressRepositoryProvider.overrideWithValue(app.progress),
        settingsRepositoryProvider.overrideWithValue(app.settings),
      ],
      child: const LumiApp(),
    ),
  );
  await tester.pumpAndSettle();
  return app;
}

Future<void> tapKey(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  // Сетки строят только видимые элементы: сначала прокручиваем к нужному.
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      finder,
      200,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

LearningTask starterTask(String id) =>
    loadStarterTasks().firstWhere((t) => t.id == id);

Future<LearningTask> openTask(WidgetTester tester, String id) async {
  final task = starterTask(id);
  await tapKey(tester, 'island.${task.area.code}');
  await tapKey(tester, 'task.$id');
  expect(find.text(task.instruction), findsOneWidget);
  return task;
}

void main() {
  testWidgets('при первом запуске взрослый выбирает возраст', (tester) async {
    final app = await pumpApp(tester, age: null);

    expect(find.text('Сколько лет малышу?'), findsOneWidget);
    await tapKey(tester, 'age.preschool');

    expect(app.settings.values[SettingsRepository.ageProgramKey], 'preschool');
    expect(find.byKey(const Key('map.next')), findsOneWidget);
    for (final area in DevelopmentArea.values) {
      await tester.scrollUntilVisible(
        find.byKey(Key('island.${area.code}')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
    }
  });

  testWidgets(
    'выбор ответа: ошибка с подсказкой → верный ответ → результат → прогресс',
    (tester) async {
      final app = await pumpApp(tester);
      await openTask(tester, 'math.count.apples.001');

      await tapKey(tester, 'option.n2');
      expect(find.byKey(const Key('exercise.hint')), findsOneWidget);

      await tapKey(tester, 'option.n3');
      expect(find.text('Молодец!'), findsOneWidget);
      final saved = app.progress.attempts.single;
      expect(saved.taskId, 'math.count.apples.001');
      expect(saved.mistakes, 1);
      expect(saved.stars, 2);

      // «Дальше» ведёт к рекомендованному занятию, а не к тому же самому.
      await tapKey(tester, 'result.next');
      expect(find.byKey(const Key('exercise.instruction')), findsOneWidget);
      expect(find.text('Сколько яблок?'), findsNothing);

      await tapKey(tester, 'exercise.close');
      // Карта помнит прокрутку, поэтому возвращаемся к шапке.
      await tester.scrollUntilVisible(
        find.byKey(const Key('map.stars')),
        -200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('map.stars')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('последовательность собирается по порядку', (tester) async {
    final app = await pumpApp(tester);
    final task = await openTask(tester, 'self_care.wash_hands.001');
    final steps = (task.content as SequenceContent).steps;

    await tapKey(tester, 'step.${steps.last.id}');
    expect(find.byKey(const Key('exercise.hint')), findsOneWidget);
    for (final step in steps) {
      await tapKey(tester, 'step.${step.id}');
    }
    expect(find.byKey(const Key('result.title')), findsOneWidget);
    expect(app.progress.attempts.single.mistakes, 1);
  });

  testWidgets('пары соединяются', (tester) async {
    final app = await pumpApp(tester);
    final task = await openTask(tester, 'world.animal_food.001');

    for (final pair in (task.content as MatchPairsContent).pairs) {
      await tapKey(tester, 'left.${pair.left.id}');
      await tapKey(tester, 'right.${pair.right.id}');
    }
    expect(find.byKey(const Key('result.title')), findsOneWidget);
    expect(app.progress.attempts.single.stars, 3);
  });

  testWidgets('предметы раскладываются по группам', (tester) async {
    final app = await pumpApp(tester);
    final task = await openTask(tester, 'math.shapes.sort.001');
    final content = task.content as GroupContent;

    for (final item in content.items) {
      expect(find.byKey(Key('group.current.${item.item.id}')), findsOneWidget);
      await tapKey(tester, 'group.${item.groupId}');
    }
    expect(find.byKey(const Key('result.title')), findsOneWidget);
    expect(app.progress.attempts.single.mistakes, 0);
  });

  testWidgets('для малыша до года — занятие вместе со взрослым', (
    tester,
  ) async {
    final app = await pumpApp(tester, age: 'infant');

    expect(find.byKey(const Key('map.parentLed')), findsOneWidget);
    await tapKey(tester, 'map.next');
    expect(find.text('Вместе со взрослым'), findsOneWidget);

    await tapKey(tester, 'together.done');
    expect(find.text('Здорово поиграли!'), findsOneWidget);
    expect(app.progress.attempts.single.stars, 1);
  });

  testWidgets('смена возраста меняет набор заданий', (tester) async {
    await pumpApp(tester, age: 'school_prep');
    // Счёт яблок до трёх — для 3–5 лет, в 5–7 его нет.
    await tapKey(tester, 'island.math');
    expect(find.byKey(const Key('task.math.count.apples.001')), findsNothing);
    expect(find.byKey(const Key('task.math.add.apples.001')), findsOneWidget);
  });

  testWidgets('карточки ответа достаточно крупные для детских пальцев', (
    tester,
  ) async {
    await pumpApp(tester);
    await openTask(tester, 'world.animal.moo.001');

    for (final id in ['cow', 'cat', 'dog']) {
      final size = tester.getSize(find.byKey(Key('option.$id')));
      expect(size.shortestSide, greaterThanOrEqualTo(LumiSizes.minTapTarget));
    }
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  });
}
