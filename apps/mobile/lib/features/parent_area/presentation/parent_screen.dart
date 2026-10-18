import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../content_library/data/pack_updater.dart';
import '../../content_library/domain/task.dart';
import '../../profiles/domain/child_profile.dart';
import '../../profiles/presentation/child_avatar_view.dart';
import '../../progress/domain/progress.dart';
import '../domain/progress_summary.dart';

/// Кабинет родителя. Открывается только через родительский барьер.
class ParentScreen extends ConsumerStatefulWidget {
  const ParentScreen({super.key});

  @override
  ConsumerState<ParentScreen> createState() => _ParentScreenState();
}

class _ParentScreenState extends ConsumerState<ParentScreen> {
  /// Чей прогресс смотрим; по умолчанию — того, кто сейчас играет.
  String? _selectedId;

  Future<void> _eraseAll() async {
    final ok = await confirmAction(
      context,
      title: 'Удалить все данные?',
      message:
          'С телефона будут удалены все профили детей, прогресс и настройки. '
          'Вернуть их не получится.',
      confirmLabel: 'Удалить всё',
    );
    if (!ok) return;
    await eraseAllData(ref);
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final profiles = ref.watch(profilesProvider);
    final active = ref.watch(activeChildProvider).value;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Для взрослых'),
        leading: IconButton(
          key: const Key('parent.close'),
          iconSize: 36,
          tooltip: 'Закрыть',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: AsyncView(
        value: profiles,
        builder: (profiles) {
          final selected =
              profiles.where((p) => p.id == _selectedId).firstOrNull ??
              profiles.where((p) => p.id == active?.id).firstOrNull ??
              profiles.firstOrNull;
          return ListView(
            padding: const EdgeInsets.all(LumiSpacing.m),
            children: [
              Text('Дети', style: text.headlineMedium),
              const SizedBox(height: LumiSpacing.s),
              for (final child in profiles)
                _ChildCard(
                  child: child,
                  selected: child.id == selected?.id,
                  onTap: () => setState(() => _selectedId = child.id),
                  onEdit: () => context.go('/parent/child/${child.id}'),
                ),
              OutlinedButton.icon(
                key: const Key('parent.addChild'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, LumiSizes.minTapTarget),
                ),
                icon: const Icon(Icons.add_rounded),
                label: const Text('Добавить ребёнка'),
                onPressed: () => context.go('/parent/child/new'),
              ),
              if (selected != null) ...[
                const SizedBox(height: LumiSpacing.l),
                _ChildProgress(key: ValueKey(selected.id), child: selected),
              ],
              const SizedBox(height: LumiSpacing.l),
              const _ContentSection(),
              const SizedBox(height: LumiSpacing.l),
              Text('Данные', style: text.headlineMedium),
              const SizedBox(height: LumiSpacing.s),
              Text(
                'Профили и прогресс хранятся только на этом телефоне и никуда '
                'не отправляются. Мы не просим фото, голос, фамилию и '
                'точную дату рождения. В приложении нет рекламы и чатов. '
                'При проверке новых заданий приложение скачивает только сам '
                'пакет и ничего не отправляет о ребёнке.',
                style: text.bodyLarge,
              ),
              const SizedBox(height: LumiSpacing.m),
              OutlinedButton.icon(
                key: const Key('parent.deleteAll'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: LumiColors.gentleError,
                  minimumSize: const Size(0, LumiSizes.minTapTarget),
                ),
                icon: const Icon(Icons.delete_forever_rounded),
                label: const Text('Удалить все данные'),
                onPressed: _eraseAll,
              ),
              const SizedBox(height: LumiSpacing.l),
            ],
          );
        },
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  const _ChildCard({
    required this.child,
    required this.selected,
    required this.onTap,
    required this.onEdit,
  });

  final ChildProfile child;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: LumiSpacing.s),
      child: Material(
        color: selected ? LumiColors.glow : Colors.white,
        borderRadius: BorderRadius.circular(LumiSizes.radius),
        child: InkWell(
          key: Key('parent.child.${child.id}'),
          borderRadius: BorderRadius.circular(LumiSizes.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(LumiSpacing.s),
            child: Row(
              children: [
                ChildAvatarView(avatar: child.avatar),
                const SizedBox(width: LumiSpacing.m),
                Expanded(child: Text(child.name, style: text.titleLarge)),
                IconButton(
                  key: Key('parent.edit.${child.id}'),
                  iconSize: 32,
                  tooltip: 'Изменить профиль',
                  icon: const Icon(Icons.edit_rounded),
                  onPressed: onEdit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChildProgress extends ConsumerWidget {
  const _ChildProgress({super.key, required this.child});

  final ChildProfile child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(clockProvider)();
    final program = child.programAt(now);
    final tasks = ref.watch(tasksProvider).value ?? const <LearningTask>[];
    final ageTasks = tasks.where(program.fits).toList();
    final stars = ref.watch(childBestStarsProvider(child.id));
    final history = ref.watch(childHistoryProvider(child.id));
    final text = Theme.of(context).textTheme;

    return AsyncView(
      value: history,
      builder: (history) {
        final summary = summarize(
          tasks: ageTasks,
          bestStars: stars.value ?? const {},
          history: history,
          now: now,
        );
        final byId = {for (final t in tasks) t.id: t};
        final ideas = ageTasks
            .where((t) => t.content is TogetherContent)
            .take(3)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Прогресс: ${child.name}', style: text.headlineMedium),
            const SizedBox(height: LumiSpacing.xs),
            Text('Программа: ${program.title}', style: text.bodyLarge),
            const SizedBox(height: LumiSpacing.m),
            Row(
              children: [
                _Stat(
                  key: const Key('parent.completed'),
                  value: summary.completed,
                  label: 'занятий всего',
                ),
                const SizedBox(width: LumiSpacing.s),
                _Stat(
                  key: const Key('parent.lastWeek'),
                  value: summary.lastWeek,
                  label: 'за 7 дней',
                ),
              ],
            ),
            const SizedBox(height: LumiSpacing.m),
            Text('По направлениям', style: text.titleLarge),
            Text(
              'Это наблюдения по занятиям в приложении, а не оценка развития.',
              style: text.bodyMedium,
            ),
            const SizedBox(height: LumiSpacing.s),
            for (final area in summary.areas)
              ListTile(
                key: Key('parent.area.${area.area.code}'),
                contentPadding: EdgeInsets.zero,
                leading: Icon(area.area.icon, color: area.area.color, size: 32),
                title: Text(area.area.title, style: text.titleMedium),
                subtitle: Text(area.status.label),
                trailing: Text('${area.tried} из ${area.total}'),
              ),
            if (ideas.isNotEmpty) ...[
              const SizedBox(height: LumiSpacing.m),
              Text('Попробуйте вместе', style: text.titleLarge),
              for (final idea in ideas)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(LumiSpacing.m),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(idea.instruction, style: text.titleMedium),
                        for (final step
                            in (idea.content as TogetherContent).steps)
                          Text('• $step', style: text.bodyMedium),
                      ],
                    ),
                  ),
                ),
            ],
            const SizedBox(height: LumiSpacing.m),
            Text('Недавние занятия', style: text.titleLarge),
            if (history.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: LumiSpacing.s),
                child: Text(
                  'Пока пусто. Здесь появятся занятия, которые ребёнок прошёл.',
                  key: const Key('parent.historyEmpty'),
                  style: text.bodyLarge,
                ),
              ),
            for (final (i, attempt) in history.take(20).indexed)
              _HistoryRow(
                key: Key('parent.history.$i'),
                attempt: attempt,
                task: byId[attempt.taskId],
              ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({super.key, required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(LumiSpacing.m),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(LumiSizes.radius),
        ),
        child: Column(
          children: [
            Text('$value', style: text.headlineMedium),
            Text(label, style: text.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({super.key, required this.attempt, required this.task});

  final AttemptRecord attempt;

  /// null, если задание убрали из пакета.
  final LearningTask? task;

  @override
  Widget build(BuildContext context) {
    final d = attempt.finishedAt;
    final date =
        '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}';
    final helped = attempt.mistakes > 0 ? ', с подсказками' : '';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(task?.area.icon ?? Icons.extension_rounded, size: 32),
      title: Text(task?.instruction ?? 'Занятие больше недоступно'),
      subtitle: Text('$date · ★ ${attempt.stars}$helped'),
    );
  }
}

class _ContentSection extends ConsumerStatefulWidget {
  const _ContentSection();

  @override
  ConsumerState<_ContentSection> createState() => _ContentSectionState();
}

class _ContentSectionState extends ConsumerState<_ContentSection> {
  bool _checked = false;

  static String _describe(PackUpdateResult result) => switch (result) {
    PackUpdateResult.updated =>
      'Скачаны новые задания. Они появятся при следующем запуске приложения.',
    PackUpdateResult.upToDate => 'Новых заданий пока нет.',
    PackUpdateResult.notConfigured =>
      'В этой сборке нет адреса сервера: работают встроенные задания.',
    PackUpdateResult.offline =>
      'Не получилось связаться с сервером. Задания работают и без интернета.',
    PackUpdateResult.rejected =>
      'Пакет с сервера пришёл повреждённым и не сохранён. Попробуйте позже.',
  };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final source = ref.watch(contentProvider).value?.source;
    final update = ref.watch(packUpdateProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Задания', style: text.headlineMedium),
        const SizedBox(height: LumiSpacing.s),
        if (source != null)
          Text(
            'Сейчас: ${source.label}',
            key: const Key('parent.contentSource'),
            style: text.bodyLarge,
          ),
        if (_checked)
          Padding(
            padding: const EdgeInsets.only(top: LumiSpacing.s),
            child: update.when(
              data: (result) => Text(
                _describe(result),
                key: const Key('parent.updateResult'),
                style: text.bodyLarge,
              ),
              loading: () => const LinearProgressIndicator(),
              error: (_, _) => Text(
                _describe(PackUpdateResult.offline),
                key: const Key('parent.updateResult'),
                style: text.bodyLarge,
              ),
            ),
          ),
        const SizedBox(height: LumiSpacing.s),
        OutlinedButton.icon(
          key: const Key('parent.checkUpdates'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, LumiSizes.minTapTarget),
          ),
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Проверить новые задания'),
          onPressed: update.isLoading
              ? null
              : () {
                  setState(() => _checked = true);
                  ref.invalidate(packUpdateProvider);
                },
        ),
      ],
    );
  }
}
