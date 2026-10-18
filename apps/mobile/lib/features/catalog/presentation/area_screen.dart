import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../domain/development_area.dart';

/// Остров направления: список заданий с заработанными звёздами.
class AreaScreen extends ConsumerWidget {
  const AreaScreen({super.key, required this.areaCode});

  final String areaCode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final area = DevelopmentArea.fromCode(areaCode);
    final stars = ref.watch(bestStarsProvider).value ?? const {};

    return Scaffold(
      appBar: AppBar(
        title: Text(area?.title ?? ''),
        leading: IconButton(
          key: const Key('area.back'),
          iconSize: 36,
          tooltip: 'На карту',
          icon: const Icon(Icons.map_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: AsyncView(
        value: ref.watch(ageTasksProvider),
        builder: (all) {
          final tasks = all.where((t) => t.area == area).toList()
            ..sort((a, b) => a.difficulty.compareTo(b.difficulty));
          return GridView.builder(
            padding: const EdgeInsets.all(LumiSpacing.l),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 160,
              mainAxisSpacing: LumiSpacing.m,
              crossAxisSpacing: LumiSpacing.m,
            ),
            itemCount: tasks.length,
            itemBuilder: (context, i) {
              final task = tasks[i];
              final earned = stars[task.id] ?? 0;
              return Semantics(
                button: true,
                label: 'Задание ${i + 1}, звёзд $earned',
                excludeSemantics: true,
                child: Material(
                  color: area!.color,
                  borderRadius: BorderRadius.circular(LumiSizes.radius),
                  child: InkWell(
                    key: Key('task.${task.id}'),
                    borderRadius: BorderRadius.circular(LumiSizes.radius),
                    onTap: () => context.go('/task/${task.id}'),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${i + 1}',
                          style: Theme.of(context).textTheme.displaySmall
                              ?.copyWith(color: Colors.white),
                        ),
                        _Stars(earned: earned, max: task.rewardStars),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.earned, required this.max});

  final int earned;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < max; i++)
          Icon(
            i < earned ? Icons.star_rounded : Icons.star_outline_rounded,
            color: i < earned ? LumiColors.glow : Colors.white70,
            size: 28,
          ),
      ],
    );
  }
}
