import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../content_library/domain/task.dart';
import '../../progress/domain/progress.dart';
import '../domain/exercise_session.dart';
import 'bodies/choice_body.dart';
import 'bodies/group_body.dart';
import 'bodies/match_pairs_body.dart';
import 'bodies/sequence_body.dart';
import 'bodies/together_body.dart';
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
          return _ExerciseHost(key: ValueKey(task.id), task: task);
        },
      ),
    );
  }
}

/// Общая рамка любого упражнения: инструкция, подсказка, тело по типу,
/// сохранение результата и экран похвалы.
class _ExerciseHost extends ConsumerStatefulWidget {
  const _ExerciseHost({super.key, required this.task});

  final LearningTask task;

  @override
  ConsumerState<_ExerciseHost> createState() => _ExerciseHostState();
}

class _ExerciseHostState extends ConsumerState<_ExerciseHost> {
  late final ExerciseSession _session = createSession(widget.task);
  Future<void>? _saving;

  void _onChanged() {
    setState(() {});
    if (_session.isSolved) _saving ??= _saveProgress();
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

  Future<void> _goNext() async {
    // Рекомендация должна учитывать только что сохранённый результат.
    await _saving;
    final next = await ref.read(recommendedTaskProvider.future);
    if (!mounted) return;
    context.go(next == null ? '/' : '/task/${next.id}');
  }

  @override
  Widget build(BuildContext context) {
    if (_session.isSolved) {
      return ResultView(
        stars: _session.stars,
        maxStars: widget.task.rewardStars,
        together: widget.task.type == ExerciseType.together,
        onNext: _goNext,
        onMap: () => context.go('/area/${widget.task.area.code}'),
      );
    }

    final text = Theme.of(context).textTheme;
    final hint = _session.currentHint;

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
            const SizedBox(height: LumiSpacing.m),
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
            _body(),
          ],
        ),
      ),
    );
  }

  Widget _body() => switch (_session) {
    final ChoiceSession s => ChoiceBody(session: s, onChanged: _onChanged),
    final SequenceSession s => SequenceBody(session: s, onChanged: _onChanged),
    final MatchPairsSession s => MatchPairsBody(
      session: s,
      onChanged: _onChanged,
    ),
    final GroupSession s => GroupBody(session: s, onChanged: _onChanged),
    final TogetherSession s => TogetherBody(session: s, onChanged: _onChanged),
    _ => const SizedBox.shrink(),
  };
}
