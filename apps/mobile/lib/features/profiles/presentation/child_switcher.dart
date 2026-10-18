import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../domain/child_profile.dart';
import 'child_avatar_view.dart';

/// «Кто играет?» — переключение без барьера: это безопасное действие.
Future<void> showChildSwitcher(BuildContext context, WidgetRef ref) async {
  final profiles = await ref.read(profilesProvider.future);
  final active = await ref.read(activeChildProvider.future);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(LumiSpacing.m),
        children: [
          Text(
            'Кто играет?',
            textAlign: TextAlign.center,
            style: Theme.of(sheetContext).textTheme.headlineMedium,
          ),
          const SizedBox(height: LumiSpacing.m),
          for (final child in profiles)
            _ChildTile(
              child: child,
              selected: child.id == active?.id,
              onTap: () async {
                await switchChild(ref, child.id);
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
            ),
          const SizedBox(height: LumiSpacing.s),
          Text(
            'Добавить ребёнка можно в разделе «Для взрослых».',
            textAlign: TextAlign.center,
            style: Theme.of(sheetContext).textTheme.bodyMedium,
          ),
        ],
      ),
    ),
  );
}

class _ChildTile extends StatelessWidget {
  const _ChildTile({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final ChildProfile child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: LumiSpacing.s),
      child: Material(
        color: selected ? LumiColors.glow : LumiColors.sky,
        borderRadius: BorderRadius.circular(LumiSizes.radius),
        child: InkWell(
          key: Key('switch.${child.id}'),
          borderRadius: BorderRadius.circular(LumiSizes.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(LumiSpacing.s),
            child: Row(
              children: [
                ChildAvatarView(avatar: child.avatar),
                const SizedBox(width: LumiSpacing.m),
                Text(child.name, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
