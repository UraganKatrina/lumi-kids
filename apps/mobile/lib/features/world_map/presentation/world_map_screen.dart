import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../age_routes/domain/age_program.dart';
import '../../age_routes/presentation/age_selection.dart';
import '../../catalog/domain/development_area.dart';
import '../../content_library/domain/task.dart';

/// Главная карта: острова — это 12 направлений развития.
class WorldMapScreen extends ConsumerWidget {
  const WorldMapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final program = ref.watch(ageProgramProvider);
    final tasks = ref.watch(ageTasksProvider);
    final stars = ref.watch(bestStarsProvider).value ?? const {};
    final next = ref.watch(recommendedTaskProvider).value;

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [LumiColors.sky, LumiColors.sea],
          ),
        ),
        child: SafeArea(
          child: AsyncView(
            value: program,
            builder: (program) => program == null
                ? const AgeSelectionView()
                : AsyncView(
                    value: tasks,
                    builder: (tasks) => _MapBody(
                      program: program,
                      tasks: tasks,
                      stars: stars,
                      next: next,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _MapBody extends StatelessWidget {
  const _MapBody({
    required this.program,
    required this.tasks,
    required this.stars,
    required this.next,
  });

  final AgeProgram program;
  final List<LearningTask> tasks;
  final Map<String, int> stars;
  final LearningTask? next;

  @override
  Widget build(BuildContext context) {
    final byArea = <DevelopmentArea, List<LearningTask>>{};
    for (final task in tasks) {
      byArea.putIfAbsent(task.area, () => []).add(task);
    }
    final totalStars = stars.values.fold(0, (a, b) => a + b);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: _Greeting(totalStars: totalStars, program: program),
        ),
        SliverToBoxAdapter(
          child: _NextActivity(task: next, program: program),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(LumiSpacing.m),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 180,
              mainAxisSpacing: LumiSpacing.m,
              crossAxisSpacing: LumiSpacing.m,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildListDelegate([
              for (final area in DevelopmentArea.values)
                _Island(
                  area: area,
                  taskCount: byArea[area]?.length ?? 0,
                  stars: [
                    for (final t in byArea[area] ?? const <LearningTask>[])
                      stars[t.id] ?? 0,
                  ].fold(0, (a, b) => a + b),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.totalStars, required this.program});

  final int totalStars;
  final AgeProgram program;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LumiSpacing.l,
        LumiSpacing.l,
        LumiSpacing.l,
        0,
      ),
      child: Row(
        children: [
          const LumiCharacter(size: 96),
          const SizedBox(width: LumiSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Привет! Я Люми.', style: text.headlineMedium),
                TextButton.icon(
                  key: const Key('map.age'),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, LumiSizes.minTapTarget),
                  ),
                  onPressed: () => context.go('/age'),
                  icon: const Icon(Icons.cake_rounded),
                  label: Text(program.title, style: text.bodyLarge),
                ),
              ],
            ),
          ),
          _StarCounter(stars: totalStars),
        ],
      ),
    );
  }
}

class _StarCounter extends StatelessWidget {
  const _StarCounter({required this.stars});

  final int stars;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Звёзд: $stars',
      excludeSemantics: true,
      child: Container(
        key: const Key('map.stars'),
        padding: const EdgeInsets.symmetric(
          horizontal: LumiSpacing.m,
          vertical: LumiSpacing.s,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LumiSizes.radius),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: LumiColors.glow, size: 32),
            const SizedBox(width: LumiSpacing.xs),
            Text('$stars', style: Theme.of(context).textTheme.titleLarge),
          ],
        ),
      ),
    );
  }
}

class _Island extends StatelessWidget {
  const _Island({
    required this.area,
    required this.taskCount,
    required this.stars,
  });

  final DevelopmentArea area;
  final int taskCount;
  final int stars;

  bool get _isOpen => taskCount > 0;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: _isOpen,
      label: _isOpen ? 'Остров ${area.title}' : 'Остров ${area.title}, скоро',
      excludeSemantics: true,
      child: Opacity(
        opacity: _isOpen ? 1 : 0.45,
        child: InkWell(
          key: Key('island.${area.code}'),
          borderRadius: BorderRadius.circular(LumiSizes.radius),
          onTap: _isOpen ? () => context.go('/area/${area.code}') : null,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Песчаный берег и «трава» острова.
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        color: LumiColors.sand,
                        shape: BoxShape.circle,
                      ),
                      child: SizedBox.expand(),
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.72,
                      heightFactor: 0.72,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: area.color,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(area.icon, color: Colors.white, size: 44),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LumiSpacing.xs),
              Text(
                area.title,
                style: text.titleLarge,
                textAlign: TextAlign.center,
              ),
              Text(_isOpen ? '★ $stars' : 'скоро', style: text.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

/// Кнопка «Следующее занятие»: рекомендация по возрасту и успехам.
class _NextActivity extends StatelessWidget {
  const _NextActivity({required this.task, required this.program});

  final LearningTask? task;
  final AgeProgram program;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final next = task;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LumiSpacing.m,
        LumiSpacing.m,
        LumiSpacing.m,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (program.parentLed)
            Padding(
              padding: const EdgeInsets.only(bottom: LumiSpacing.s),
              child: Text(
                'Для малышей до года все занятия проходят вместе со взрослым, '
                'экран только подсказывает идею.',
                key: const Key('map.parentLed'),
                textAlign: TextAlign.center,
                style: text.bodyLarge,
              ),
            ),
          if (next == null)
            Text(
              'Все занятия пройдены! Скоро появятся новые.',
              key: const Key('map.allDone'),
              textAlign: TextAlign.center,
              style: text.titleLarge,
            )
          else
            FilledButton.icon(
              key: const Key('map.next'),
              onPressed: () => context.go('/task/${next.id}'),
              icon: Icon(next.area.icon),
              label: Text('Следующее занятие: ${next.area.title}'),
            ),
        ],
      ),
    );
  }
}
