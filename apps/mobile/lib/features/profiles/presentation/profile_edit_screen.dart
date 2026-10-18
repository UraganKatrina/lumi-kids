import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/confirm_dialog.dart';
import 'profile_form.dart';
import '../../../l10n/l10n.dart';

/// Добавление и правка профиля из кабинета родителя.
class ProfileEditScreen extends ConsumerWidget {
  const ProfileEditScreen({super.key, this.childId});

  /// null — новый профиль.
  final String? childId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void back() => context.go('/parent');
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(childId == null ? l10n.profileNew : l10n.profileTitle),
        leading: IconButton(
          key: const Key('profile.back'),
          iconSize: 36,
          tooltip: l10n.commonBack,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: back,
        ),
      ),
      body: AsyncView(
        value: ref.watch(profilesProvider),
        builder: (profiles) {
          final initial = profiles.where((p) => p.id == childId).firstOrNull;
          if (childId != null && initial == null) {
            return Center(child: Text(l10n.profileNotFound));
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
                  label: Text(l10n.profileDelete),
                  onPressed: () async {
                    final ok = await confirmAction(
                      context,
                      title: l10n.profileDeleteTitle(initial.name),
                      message: l10n.profileDeleteText,
                      confirmLabel: l10n.commonDelete,
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
