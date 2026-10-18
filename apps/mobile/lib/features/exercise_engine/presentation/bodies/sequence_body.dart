import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/design_system/item_card.dart';
import '../../../../core/design_system/lumi_tokens.dart';
import '../../../content_library/domain/task.dart';
import '../../domain/exercise_session.dart';

/// Сверху — линия из пустых мест, снизу — перемешанные шаги.
class SequenceBody extends StatefulWidget {
  const SequenceBody({
    super.key,
    required this.session,
    required this.onChanged,
  });

  final SequenceSession session;
  final VoidCallback onChanged;

  @override
  State<SequenceBody> createState() => _SequenceBodyState();
}

class _SequenceBodyState extends State<SequenceBody> {
  late final List<TaskItem> _steps =
      (widget.session.task.content as SequenceContent).steps;
  late final List<TaskItem> _shuffled = [..._steps]..shuffle(Random());

  @override
  Widget build(BuildContext context) {
    final placed = widget.session.placed;
    return Column(
      children: [
        Wrap(
          key: const Key('sequence.line'),
          alignment: WrapAlignment.center,
          spacing: LumiSpacing.s,
          runSpacing: LumiSpacing.s,
          children: [
            for (var i = 0; i < _steps.length; i++)
              i < placed.length
                  ? ItemCard(
                      key: Key('sequence.slot.$i'),
                      label: placed[i].display,
                      state: ItemCardState.done,
                      size: 88,
                    )
                  : _EmptySlot(number: i + 1),
          ],
        ),
        const SizedBox(height: LumiSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: LumiSpacing.m,
          runSpacing: LumiSpacing.m,
          children: [
            for (final step in _shuffled)
              if (!widget.session.isPlaced(step.id))
                ItemCard(
                  key: Key('step.${step.id}'),
                  label: step.display,
                  onTap: () {
                    widget.session.tap(step.id);
                    widget.onChanged();
                  },
                ),
          ],
        ),
      ],
    );
  }
}

class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.number});

  final int number;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 88,
      height: 88,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(LumiSizes.radius),
        border: Border.all(
          color: LumiColors.primary.withValues(alpha: 0.4),
          width: 3,
        ),
      ),
      child: Text(
        '$number',
        style: Theme.of(context).textTheme.headlineMedium
            ?.copyWith(color: LumiColors.primary.withValues(alpha: 0.5)),
      ),
    );
  }
}
