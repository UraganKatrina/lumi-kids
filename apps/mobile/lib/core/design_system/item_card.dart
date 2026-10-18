import 'package:flutter/material.dart';

import 'lumi_tokens.dart';

enum ItemCardState { normal, selected, faded, done }

/// Крупная карточка с эмодзи или словом — основной элемент всех упражнений.
class ItemCard extends StatelessWidget {
  const ItemCard({
    super.key,
    required this.label,
    this.onTap,
    this.state = ItemCardState.normal,
    this.size = LumiSizes.answerCard,
  });

  final String label;
  final VoidCallback? onTap;
  final ItemCardState state;
  final double size;

  @override
  Widget build(BuildContext context) {
    final interactive = onTap != null && state != ItemCardState.done;
    return Semantics(
      button: interactive,
      enabled: interactive && state != ItemCardState.faded,
      selected: state == ItemCardState.selected,
      label: label,
      excludeSemantics: true,
      child: AnimatedOpacity(
        duration: LumiDurations.normal,
        opacity: switch (state) {
          ItemCardState.faded => 0.3,
          ItemCardState.done => 0.55,
          _ => 1,
        },
        child: AnimatedContainer(
          duration: LumiDurations.quick,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(LumiSizes.radius),
            border: Border.all(
              width: 4,
              color: switch (state) {
                ItemCardState.selected => LumiColors.primary,
                ItemCardState.done => LumiColors.success,
                _ => Colors.transparent,
              },
            ),
          ),
          child: Material(
            color: Colors.white,
            elevation: state == ItemCardState.normal ? 3 : 0,
            borderRadius: BorderRadius.circular(LumiSizes.radius - 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(LumiSizes.radius - 4),
              onTap: interactive && state != ItemCardState.faded ? onTap : null,
              child: SizedBox.square(
                dimension: size,
                child: Padding(
                  padding: const EdgeInsets.all(LumiSpacing.s),
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 44, height: 1.1),
                      ),
                    ),
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
