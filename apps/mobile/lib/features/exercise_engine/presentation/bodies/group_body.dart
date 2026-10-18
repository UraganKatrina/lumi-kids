import 'package:flutter/material.dart';

import '../../../../core/design_system/item_card.dart';
import '../../../../core/design_system/lumi_tokens.dart';
import '../../domain/exercise_session.dart';
import '../../../../l10n/l10n.dart';

/// Предмет в центре, внизу «корзинки»-группы: нажми нужную.
class GroupBody extends StatelessWidget {
  const GroupBody({super.key, required this.session, required this.onChanged});

  final GroupSession session;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final current = session.current;
    final total = session.content.items.length;
    return Column(
      children: [
        Text(
          context.l10n.groupProgress(session.placedCount, total),
          key: const Key('group.progress'),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: LumiSpacing.m),
        if (current != null)
          ItemCard(
            key: Key('group.current.${current.item.id}'),
            label: current.item.display,
            size: 140,
            state: ItemCardState.selected,
          ),
        const SizedBox(height: LumiSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: LumiSpacing.m,
          runSpacing: LumiSpacing.m,
          children: [
            for (final group in session.content.groups)
              _Basket(
                key: Key('group.${group.id}'),
                label: group.display,
                onTap: () {
                  session.place(group.id);
                  onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _Basket extends StatelessWidget {
  const _Basket({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: LumiColors.sand,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(LumiSizes.radius / 2),
          bottom: Radius.circular(LumiSizes.radius * 2),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.vertical(
            bottom: Radius.circular(LumiSizes.radius * 2),
          ),
          child: SizedBox(
            width: 150,
            height: 120,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(LumiSpacing.s),
                child: FittedBox(
                  child: Text(label, style: const TextStyle(fontSize: 36)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
