import 'package:flutter/material.dart';

import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../l10n/l10n.dart';

/// Что видит ребёнок у закрытого задания. Здесь нет цен и кнопок покупки:
/// оформить подписку может только взрослый в своём кабинете.
class LockedTaskView extends StatelessWidget {
  const LockedTaskView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.all(LumiSpacing.l),
      child: Column(
        key: const Key('locked.view'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const LumiCharacter(size: 96),
          const SizedBox(height: LumiSpacing.m),
          Text(
            context.l10n.lockedTitle,
            style: text.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: LumiSpacing.s),
          Text(
            context.l10n.lockedText,
            style: text.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

Future<void> showLockedTaskDialog(BuildContext context) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    content: const LockedTaskView(),
    actions: [
      TextButton(
        key: const Key('locked.close'),
        onPressed: () => Navigator.of(context).pop(),
        child: Text(context.l10n.commonClose),
      ),
    ],
  ),
);
