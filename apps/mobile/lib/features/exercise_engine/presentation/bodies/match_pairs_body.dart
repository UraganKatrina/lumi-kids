import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/design_system/item_card.dart';
import '../../../../core/design_system/lumi_tokens.dart';
import '../../../content_library/domain/task.dart';
import '../../domain/exercise_session.dart';

/// Две колонки: выбери карточку слева и её пару справа.
class MatchPairsBody extends StatefulWidget {
  const MatchPairsBody({
    super.key,
    required this.session,
    required this.onChanged,
  });

  final MatchPairsSession session;
  final VoidCallback onChanged;

  @override
  State<MatchPairsBody> createState() => _MatchPairsBodyState();
}

class _MatchPairsBodyState extends State<MatchPairsBody> {
  late final List<MatchPair> _pairs =
      (widget.session.task.content as MatchPairsContent).pairs;
  late final List<TaskItem> _left = [for (final p in _pairs) p.left]
    ..shuffle(Random());
  late final List<TaskItem> _right = [for (final p in _pairs) p.right]
    ..shuffle(Random());

  ItemCardState _state(String id, String? selected) {
    if (widget.session.isMatched(id)) return ItemCardState.done;
    return id == selected ? ItemCardState.selected : ItemCardState.normal;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.session;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: [
            for (final item in _left)
              Padding(
                padding: const EdgeInsets.all(LumiSpacing.s),
                child: ItemCard(
                  key: Key('left.${item.id}'),
                  label: item.display,
                  size: 104,
                  state: _state(item.id, s.selectedLeft),
                  onTap: () {
                    s.tapLeft(item.id);
                    widget.onChanged();
                  },
                ),
              ),
          ],
        ),
        const SizedBox(width: LumiSpacing.xl),
        Column(
          children: [
            for (final item in _right)
              Padding(
                padding: const EdgeInsets.all(LumiSpacing.s),
                child: ItemCard(
                  key: Key('right.${item.id}'),
                  label: item.display,
                  size: 104,
                  state: _state(item.id, s.selectedRight),
                  onTap: () {
                    s.tapRight(item.id);
                    widget.onChanged();
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}
