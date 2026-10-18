import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/app/lumi_app.dart';
import 'package:lumi_kids/app/providers.dart';
import 'package:lumi_kids/core/design_system/lumi_tokens.dart';
import 'package:lumi_kids/features/content_library/data/pack_updater.dart';
import 'package:lumi_kids/features/catalog/domain/development_area.dart';
import 'package:lumi_kids/features/content_library/domain/task.dart';
import 'package:lumi_kids/features/parent_area/domain/parental_gate.dart';
import 'package:lumi_kids/features/profiles/domain/child_profile.dart';

import '../support/fakes.dart';

final testNow = DateTime(2026, 10, 18, 12);

/// Год и месяц рождения, при которых на [testNow] ребёнок попадает в программу.
const _birthByProgram = {
  'infant': (2026, 4),
  'toddler': (2025, 4),
  'early': (2024, 4),
  'preschool': (2022, 10),
  'school_prep': (2020, 4),
};

class TestApp {
  TestApp(this.progress, this.profiles);

  final InMemoryProgressRepository progress;
  final InMemoryProfileRepository profiles;
}

/// [age] — возрастная программа ребёнка «Маша»; null — первый запуск без профилей.
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

  final progress = InMemoryProgressRepository();
  final birth = _birthByProgram[age];
  final app = TestApp(
    progress,
    InMemoryProfileRepository(progress, [
      if (birth != null)
        ChildProfile(
          id: 'kid',
          name: 'Маша',
          birthYear: birth.$1,
          birthMonth: birth.$2,
          avatar: ChildAvatar.bee,
        ),
    ]),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        clockProvider.overrideWithValue(() => testNow),
        gateQuestionProvider.overrideWithValue(() => const GateQuestion(6, 7)),
        contentRepositoryProvider.overrideWithValue(FileContentRepository()),
        packUpdateProvider.overrideWith(
          (ref) async => PackUpdateResult.notConfigured,
        ),
        progressRepositoryProvider.overrideWithValue(app.progress),
        profileRepositoryProvider.overrideWithValue(app.profiles),
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

Future<void> answerGate(WidgetTester tester, String answer) async {
  for (final digit in answer.split('')) {
    await tester.tap(find.byKey(Key('gate.digit.$digit')));
  }
  await tester.tap(find.byKey(const Key('gate.submit')));
  await tester.pumpAndSettle();
}

Future<void> openParentArea(WidgetTester tester) async {
  await scrollToTop(tester);
  await tapKey(tester, 'map.parent');
  await answerGate(tester, '42');
  expect(find.byKey(const Key('parent.close')), findsOneWidget);
}

Future<void> scrollToTop(WidgetTester tester) async {
  final top = find.byKey(const Key('map.parent'));
  if (top.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      top,
      -200,
      scrollable: find.byType(Scrollable).first,
    );
  }
}

void main() {
  testWidgets('при первом запуске взрослый создаёт профиль ребёнка', (
    tester,
  ) async {
    final app = await pumpApp(tester, age: null);

    expect(find.byKey(const Key('welcome.title')), findsOneWidget);
    await tapKey(tester, 'profile.save');
    expect(find.byKey(const Key('profile.error')), findsOneWidget);
    expect(app.profiles.profiles, isEmpty);

    await tester.enterText(find.byKey(const Key('profile.name')), '  Маша ');
    await tapKey(tester, 'profile.avatar.star');
    await tapKey(tester, 'profile.year.2022');
    await tapKey(tester, 'profile.month.10');
    await tapKey(tester, 'profile.save');

    final saved = app.profiles.profiles.single;
    expect(saved.name, 'Маша');
    expect(saved.avatar, ChildAvatar.star);
    expect((saved.birthYear, saved.birthMonth), (2022, 10));
    expect(app.profiles.activeId, saved.id);
    expect(find.byKey(const Key('map.next')), findsOneWidget);
    expect(find.text('Маша'), findsOneWidget);
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
      expect(saved.childId, 'kid');
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

  testWidgets('возраст ребёнка задаёт набор заданий', (tester) async {
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

  testWidgets('кабинет родителя закрыт барьером', (tester) async {
    await pumpApp(tester);

    await tapKey(tester, 'map.parent');
    expect(find.text('Сколько будет шесть умножить на семь?'), findsOneWidget);
    await answerGate(tester, '41');
    expect(find.byKey(const Key('gate.error')), findsOneWidget);
    expect(find.byKey(const Key('parent.close')), findsNothing);

    await tapKey(tester, 'gate.cancel');
    expect(find.byKey(const Key('gate.question')), findsNothing);
    expect(find.byKey(const Key('parent.close')), findsNothing);

    await openParentArea(tester);
    expect(find.byKey(const Key('parent.historyEmpty')), findsOneWidget);
  });

  testWidgets('кабинет показывает историю и наблюдения по направлениям', (
    tester,
  ) async {
    await pumpApp(tester);
    await openTask(tester, 'math.count.apples.001');
    await tapKey(tester, 'option.n2');
    await tapKey(tester, 'option.n3');
    await tapKey(tester, 'result.map');
    await tapKey(tester, 'area.back');

    await openParentArea(tester);
    expect(
      find.descendant(
        of: find.byKey(const Key('parent.completed')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.byKey(const Key('parent.history.0')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(
      find.descendant(
        of: find.byKey(const Key('parent.history.0')),
        matching: find.text('Сколько яблок?'),
      ),
      findsOneWidget,
    );
    expect(find.textContaining('с подсказками'), findsOneWidget);
  });

  testWidgets('второй ребёнок: свой профиль, свой возраст, свой прогресс', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await openTask(tester, 'math.count.apples.001');
    await tapKey(tester, 'option.n3');
    await tapKey(tester, 'result.map');
    await tapKey(tester, 'area.back');

    await openParentArea(tester);
    await tapKey(tester, 'parent.addChild');
    await tester.enterText(find.byKey(const Key('profile.name')), 'Петя');
    await tapKey(tester, 'profile.year.2020');
    await tapKey(tester, 'profile.month.4');
    await tapKey(tester, 'profile.save');

    expect(app.profiles.profiles.map((p) => p.name), ['Маша', 'Петя']);
    final petya = app.profiles.profiles.last;
    expect(app.profiles.activeId, petya.id);

    await tapKey(tester, 'parent.close');
    expect(find.text('Петя'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('map.stars')),
        matching: find.text('0'),
      ),
      findsOneWidget,
    );
    await tapKey(tester, 'island.math');
    expect(find.byKey(const Key('task.math.add.apples.001')), findsOneWidget);
    await tapKey(tester, 'area.back');

    await scrollToTop(tester);
    await tapKey(tester, 'map.child');
    await tapKey(tester, 'switch.kid');
    expect(find.text('Маша'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byKey(const Key('map.stars')),
        matching: find.text('3'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('удаление профиля и всех данных — с подтверждением', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    await openParentArea(tester);

    await tapKey(tester, 'parent.edit.kid');
    await tapKey(tester, 'profile.delete');
    await tapKey(tester, 'confirm.no');
    expect(app.profiles.profiles, hasLength(1));

    await tapKey(tester, 'profile.back');
    await tapKey(tester, 'parent.deleteAll');
    await tapKey(tester, 'confirm.yes');
    expect(app.profiles.profiles, isEmpty);
    expect(find.byKey(const Key('welcome.title')), findsOneWidget);
  });

  testWidgets('кабинет показывает источник заданий и проверяет обновления', (
    tester,
  ) async {
    await pumpApp(tester);
    await openParentArea(tester);
    await tester.scrollUntilVisible(
      find.byKey(const Key('parent.checkUpdates')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('встроенный пакет'), findsOneWidget);
    await tapKey(tester, 'parent.checkUpdates');
    expect(find.textContaining('нет адреса сервера'), findsOneWidget);
  });

  testWidgets('правка профиля меняет возраст', (tester) async {
    final app = await pumpApp(tester, age: 'infant');
    expect(find.byKey(const Key('map.parentLed')), findsOneWidget);

    await openParentArea(tester);
    await tapKey(tester, 'parent.edit.kid');
    await tapKey(tester, 'profile.year.2022');
    await tapKey(tester, 'profile.month.10');
    await tapKey(tester, 'profile.save');
    await tapKey(tester, 'parent.close');

    expect(app.profiles.profiles.single.birthYear, 2022);
    expect(find.byKey(const Key('map.parentLed')), findsNothing);
  });
}
