import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/confirm_dialog.dart';
import 'profile_form.dart';

/// Добавление и правка профиля из кабинета родителя.
class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key, this.childId});

  /// null — новый профиль.
  final String? childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void back() => context.go('/parent');
    return Scaffold(
      appBar: AppBar(
        title: Text(childId == null ? 'Новый ребёнок' : 'Профиль'),
        leading: IconButton(
          key: const Key('profile.back'),
          iconSize: 36,
          tooltip: 'Назад',
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: back,
        ),
      ),
      body: AsyncView(
        value: ref.watch(profilesProvider),
        builder: (profiles) {
          final initial = profiles.where((p) => p.id == childId).firstOrNull;
          if (childId != null && initial == null) {
            return const Center(child: Text('Профиль не найден'));
          }
          return ListView(
            padding: const EdgeInsets.all(LumiSpacing.l),
            children: [
              ProfileForm(initial: initial, onSaved: back),
              if (initial != null) ...[
                const SizedBox(height: LumiSpacing.xl),
                OutlinedButton.icon(
                  key: const Key('profile.delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: LumiColors.gentleError,
                    minimumSize: const Size(0, LumiSizes.minTapTarget),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Удалить профиль'),
                  onPressed: () async {
                    final ok = await confirmAction(
                      context,
                      title: 'Удалить профиль «${initial.name}»?',
                      message:
                          'Профиль и весь прогресс этого ребёнка будут '
                          'удалены с телефона. Вернуть их не получится.',
                      confirmLabel: 'Удалить',
                    );
                    if (!ok) return;
                    await deleteChild(ref, initial.id);
                    if (context.mounted) back();
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
