import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../domain/age_program.dart';

/// Выбор возраста. Экран для взрослого: от возраста зависит стартовый набор
/// заданий, дальше сложность подстраивается сама.
class AgeSelectionView extends ConsumerWidget {
  const AgeSelectionView({super.key, this.closeOnSelect = false});

  /// true, когда экран открыт с карты для смены возраста.
  final bool closeOnSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final current = ref.watch(ageProgramProvider).value;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(LumiSpacing.l),
        children: [
          const Center(child: LumiCharacter(size: 120)),
          const SizedBox(height: LumiSpacing.m),
          Text(
            'Сколько лет малышу?',
            textAlign: TextAlign.center,
            style: text.headlineMedium,
          ),
          const SizedBox(height: LumiSpacing.s),
          Text(
            'Для взрослых: так мы подберём первые занятия. '
            'Дальше сложность будет меняться по успехам ребёнка.',
            textAlign: TextAlign.center,
            style: text.bodyLarge,
          ),
          const SizedBox(height: LumiSpacing.l),
          for (final program in AgeProgram.values)
            Padding(
              padding: const EdgeInsets.only(bottom: LumiSpacing.m),
              child: Material(
                color: program == current ? LumiColors.glow : Colors.white,
                borderRadius: BorderRadius.circular(LumiSizes.radius),
                child: InkWell(
                  key: Key('age.${program.code}'),
                  borderRadius: BorderRadius.circular(LumiSizes.radius),
                  onTap: () async {
                    await chooseAgeProgram(ref, program);
                    if (closeOnSelect && context.mounted) context.go('/');
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: LumiSizes.minTapTarget + LumiSpacing.m,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(LumiSpacing.m),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(program.title, style: text.titleLarge),
                          ),
                          Expanded(
                            child: Text(
                              program.subtitle,
                              style: text.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AgeSelectionScreen extends StatelessWidget {
  const AgeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          iconSize: 36,
          tooltip: 'Назад',
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: const AgeSelectionView(closeOnSelect: true),
    );
  }
}
