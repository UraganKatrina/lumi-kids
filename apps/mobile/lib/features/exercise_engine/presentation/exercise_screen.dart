import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../content_library/domain/task.dart';
import '../../progress/domain/progress.dart';
import '../domain/choice_session.dart';
import 'result_view.dart';

class ExerciseScreen extends ConsumerWidget {
  const ExerciseScreen({super.key, required this.taskId});

  final String taskId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          key: const Key('exercise.close'),
          iconSize: 36,
          tooltip: 'Закрыть',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: AsyncView(
        value: ref.watch(tasksProvider),
        builder: (tasks) {
          final task = tasks.where((t) => t.id == taskId).firstOrNull;
          if (task == null) {
            return const Center(child: Text('Задание не найдено'));
          }
          // Ключ пересоздаёт состояние при переходе к другому заданию.
          return _ChoiceExercise(
            key: ValueKey(task.id),
            task: task,
            allTasks: tasks,
          );
        },
      ),
    );
  }
}

class _ChoiceExercise extends ConsumerStatefulWidget {
  const _ChoiceExercise({
    super.key,
    required this.task,
    required this.allTasks,
  });

  final LearningTask task;
  final List<LearningTask> allTasks;

  @override
  ConsumerState<_ChoiceExercise> createState() => _ChoiceExerciseState();
}

class _ChoiceExerciseState extends ConsumerState<_ChoiceExercise> {
  late final ChoiceSession _session = ChoiceSession(widget.task);
  late final List<TaskItem> _options = [...widget.task.content.options];

  @override
  void initState() {
    super.initState();
    if (widget.task.content.shuffle) _options.shuffle(Random());
  }

  Future<void> _onAnswer(String optionId) async {
    final outcome = _session.answer(optionId);
    setState(() {});
    if (outcome == AnswerOutcome.correct) await _saveProgress();
  }

  Future<void> _saveProgress() async {
    try {
      await ref
          .read(progressRepositoryProvider)
          .saveAttempt(
            AttemptRecord(
              taskId: widget.task.id,
              taskVersion: widget.task.version,
              startedAt: _session.startedAt,
              finishedAt: DateTime.now(),
              mistakes: _session.mistakes,
              stars: _session.stars,
            ),
          );
      ref.invalidate(bestStarsProvider);
    } catch (error) {
      // Ребёнок всё равно видит результат; прогресс просто не сохранится.
      debugPrint('Не удалось сохранить прогресс: ${error.runtimeType}');
    }
  }

  LearningTask? get _nextTask {
    final sameArea =
        widget.allTasks.where((t) => t.area == widget.task.area).toList()
          ..sort((a, b) => a.difficulty.compareTo(b.difficulty));
    final index = sameArea.indexWhere((t) => t.id == widget.task.id);
    return index >= 0 && index + 1 < sameArea.length
        ? sameArea[index + 1]
        : null;
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isSolved) {
      final next = _nextTask;
      return ResultView(
        stars: _session.stars,
        maxStars: widget.task.rewardStars,
        onNext: next == null ? null : () => context.go('/task/${next.id}'),
        onMap: () => context.go('/area/${widget.task.area.code}'),
      );
    }

    final text = Theme.of(context).textTheme;
    final hint = _session.currentHint;
    final prompt = widget.task.content.prompt;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(LumiSpacing.l),
        child: Column(
          children: [
            Row(
              children: [
                LumiCharacter(
                  size: 72,
                  mood: hint == null ? LumiMood.calm : LumiMood.encouraging,
                ),
                const SizedBox(width: LumiSpacing.m),
                Expanded(
                  child: Text(
                    widget.task.instruction,
                    key: const Key('exercise.instruction'),
                    style: text.headlineMedium,
                  ),
                ),
              ],
            ),
            if (prompt?.label != null) ...[
              const SizedBox(height: LumiSpacing.l),
              Text(
                prompt!.label!,
                key: const Key('exercise.prompt'),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 56),
              ),
            ],
            const SizedBox(height: LumiSpacing.l),
            AnimatedSwitcher(
              duration: LumiDurations.normal,
              child: hint == null
                  ? const SizedBox(height: LumiSpacing.l)
                  : Text(
                      hint,
                      key: const Key('exercise.hint'),
                      textAlign: TextAlign.center,
                      style: text.titleLarge?.copyWith(
                        color: LumiColors.gentleError,
                      ),
                    ),
            ),
            const SizedBox(height: LumiSpacing.m),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: LumiSpacing.m,
              runSpacing: LumiSpacing.m,
              children: [
                for (final option in _options)
                  _AnswerCard(
                    option: option,
                    rejected: _session.rejected.contains(option.id),
                    onTap: () => _onAnswer(option.id),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  const _AnswerCard({
    required this.option,
    required this.rejected,
    required this.onTap,
  });

  final TaskItem option;
  final bool rejected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = option.label ?? option.id;
    return Semantics(
      button: true,
      enabled: !rejected,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: LumiDurations.normal,
        opacity: rejected ? 0.3 : 1,
        child: Material(
          color: Colors.white,
          elevation: rejected ? 0 : 3,
          borderRadius: BorderRadius.circular(LumiSizes.radius),
          child: InkWell(
            key: Key('option.${option.id}'),
            borderRadius: BorderRadius.circular(LumiSizes.radius),
            onTap: rejected ? null : onTap,
            child: SizedBox.square(
              dimension: LumiSizes.answerCard,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(LumiSpacing.s),
                  child: FittedBox(
                    child: Text(label, style: const TextStyle(fontSize: 44)),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
