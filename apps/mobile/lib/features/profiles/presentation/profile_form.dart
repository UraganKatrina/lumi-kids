import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../domain/child_profile.dart';
import 'child_avatar_view.dart';
import '../../../l10n/l10n.dart';

/// Форма профиля для взрослого: прозвище, аватар, год и месяц рождения.
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key, this.initial, required this.onSaved});

  /// null — создаём новый профиль.
  final ChildProfile? initial;
  final VoidCallback onSaved;

  @override
  ConsumerState<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  static const _uuid = Uuid();

  late final _name = TextEditingController(text: widget.initial?.name);
  late ChildAvatar _avatar = widget.initial?.avatar ?? ChildAvatar.bunny;
  late int? _year = widget.initial?.birthYear;
  late int? _month = widget.initial?.birthMonth;
  ProfileError? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final now = ref.read(clockProvider)();
    final error = validateProfile(
      name: _name.text,
      birthYear: _year,
      birthMonth: _month,
      now: now,
    );
    setState(() => _error = error);
    if (error != null || _saving) return;
    _saving = true;
    final initial = widget.initial;
    final profile = ChildProfile(
      id: initial?.id ?? _uuid.v4(),
      name: _name.text.trim(),
      birthYear: _year!,
      birthMonth: _month!,
      avatar: _avatar,
    );
    try {
      await saveChild(ref, profile, isNew: initial == null);
      if (mounted) widget.onSaved();
    } finally {
      _saving = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.profileNameQuestion, style: text.titleLarge),
        const SizedBox(height: LumiSpacing.s),
        TextField(
          key: const Key('profile.name'),
          controller: _name,
          maxLength: ChildProfile.maxNameLength,
          textCapitalization: TextCapitalization.words,
          style: text.bodyLarge,
          decoration: InputDecoration(
            hintText: l10n.profileNameHint,
            helperText: l10n.profileNameHelper,
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: LumiSpacing.m),
        Text(l10n.profileAvatar, style: text.titleLarge),
        const SizedBox(height: LumiSpacing.s),
        Wrap(
          spacing: LumiSpacing.s,
          runSpacing: LumiSpacing.s,
          children: [
            for (final avatar in ChildAvatar.values)
              Semantics(
                button: true,
                selected: avatar == _avatar,
                label: l10n.avatar(avatar),
                excludeSemantics: true,
                child: InkWell(
                  key: Key('profile.avatar.${avatar.code}'),
                  customBorder: const CircleBorder(),
                  onTap: () => setState(() => _avatar = avatar),
                  child: Container(
                    padding: const EdgeInsets.all(LumiSpacing.xs),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 4,
                        color: avatar == _avatar
                            ? LumiColors.primary
                            : Colors.transparent,
                      ),
                    ),
                    child: ChildAvatarView(avatar: avatar),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: LumiSpacing.m),
        Text(l10n.profileBirthYear, style: text.titleLarge),
        const SizedBox(height: LumiSpacing.s),
        Wrap(
          spacing: LumiSpacing.s,
          runSpacing: LumiSpacing.s,
          children: [
            for (var y = now.year; y >= now.year - 7; y--)
              ChoiceChip(
                key: Key('profile.year.$y'),
                label: Text('$y', style: text.bodyLarge),
                selected: _year == y,
                onSelected: (_) => setState(() => _year = y),
              ),
          ],
        ),
        const SizedBox(height: LumiSpacing.m),
        Text(l10n.profileBirthMonth, style: text.titleLarge),
        const SizedBox(height: LumiSpacing.s),
        Wrap(
          spacing: LumiSpacing.s,
          runSpacing: LumiSpacing.s,
          children: [
            for (var m = 1; m <= 12; m++)
              ChoiceChip(
                key: Key('profile.month.$m'),
                label: Text(l10n.month(m), style: text.bodyLarge),
                selected: _month == m,
                onSelected: (_) => setState(() => _month = m),
              ),
          ],
        ),
        const SizedBox(height: LumiSpacing.s),
        Text(l10n.profileMonthNote, style: text.bodyMedium),
        if (_error case final error?)
          Padding(
            padding: const EdgeInsets.only(top: LumiSpacing.m),
            child: Text(
              l10n.profileError(error),
              key: const Key('profile.error'),
              style: text.bodyLarge?.copyWith(color: LumiColors.gentleError),
            ),
          ),
        const SizedBox(height: LumiSpacing.l),
        FilledButton(
          key: const Key('profile.save'),
          onPressed: _save,
          child: Text(l10n.commonSave),
        ),
      ],
    );
  }
}
