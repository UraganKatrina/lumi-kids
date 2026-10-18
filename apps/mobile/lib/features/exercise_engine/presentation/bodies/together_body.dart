import 'package:flutter/material.dart';

import '../../../../core/design_system/lumi_tokens.dart';
import '../../../content_library/domain/task.dart';
import '../../domain/exercise_session.dart';
import '../../../../l10n/l10n.dart';

/// Идея занятия для взрослого. Экран здесь только подсказка, а играют вживую.
class TogetherBody extends StatelessWidget {
  const TogetherBody({
    super.key,
    required this.session,
    required this.onChanged,
  });

  final TogetherSession session;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final steps = (session.task.content as TogetherContent).steps;
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(LumiSpacing.m),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(LumiSizes.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.family_restroom_rounded, size: 32),
                  const SizedBox(width: LumiSpacing.s),
                  Expanded(
                    child: Text(
                      context.l10n.togetherTitle,
                      style: text.titleLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: LumiSpacing.m),
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: LumiSpacing.s),
                  child: Text('${i + 1}. ${steps[i]}', style: text.bodyLarge),
                ),
              const SizedBox(height: LumiSpacing.s),
              Text(context.l10n.togetherHint, style: text.bodyMedium),
            ],
          ),
        ),
        const SizedBox(height: LumiSpacing.l),
        Center(
          child: FilledButton.icon(
            key: const Key('together.done'),
            onPressed: () {
              session.complete();
              onChanged();
            },
            icon: const Icon(Icons.check_rounded),
            label: Text(context.l10n.togetherDone),
          ),
        ),
      ],
    );
  }
}
