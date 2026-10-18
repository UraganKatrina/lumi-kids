import 'package:flutter/material.dart';

import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import 'profile_form.dart';

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
          'Здравствуйте!',
          key: const Key('welcome.title'),
          textAlign: TextAlign.center,
          style: text.headlineMedium,
        ),
        const SizedBox(height: LumiSpacing.s),
        Text(
          'Расскажите немного о ребёнке, чтобы Люми подобрал занятия '
          'по возрасту. Всё хранится только на этом телефоне.',
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
