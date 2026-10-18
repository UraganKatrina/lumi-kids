import 'package:flutter/material.dart';

import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import 'profile_form.dart';
import '../../../l10n/l10n.dart';

/// Первый запуск: взрослый создаёт профиль ребёнка.
class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(LumiSpacing.l),
      children: [
        const Center(child: LumiCharacter(size: 120)),
        const SizedBox(height: LumiSpacing.m),
        Text(
          context.l10n.welcomeTitle,
          key: const Key('welcome.title'),
          textAlign: TextAlign.center,
          style: text.headlineMedium,
        ),
        const SizedBox(height: LumiSpacing.s),
        Text(
          context.l10n.welcomeText,
          textAlign: TextAlign.center,
          style: text.bodyLarge,
        ),
        const SizedBox(height: LumiSpacing.l),
        // Профиль сохраняется, карта появляется сама.
        ProfileForm(onSaved: () {}),
      ],
    );
  }
}
