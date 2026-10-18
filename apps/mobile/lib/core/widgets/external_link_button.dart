import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../l10n/l10n.dart';
import '../design_system/lumi_tokens.dart';

/// Кнопка внешней ссылки. Ставить только в разделы для взрослых.
class ExternalLinkButton extends ConsumerWidget {
  const ExternalLinkButton({
    super.key,
    required this.label,
    required this.uri,
    this.icon = Icons.open_in_new_rounded,
  });

  final String label;
  final Uri uri;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        minimumSize: const Size(0, LumiSizes.minTapTarget),
        alignment: Alignment.centerLeft,
      ),
      icon: Icon(icon),
      label: Text(label),
      onPressed: () async {
        final messenger = ScaffoldMessenger.of(context);
        final failed = context.l10n.linkOpenFailed;
        var opened = false;
        try {
          opened = await ref.read(linkOpenerProvider)(uri);
        } catch (_) {}
        if (!opened) messenger.showSnackBar(SnackBar(content: Text(failed)));
      },
    );
  }
}

/// Ссылки на политику конфиденциальности и условия, если они заданы.
class LegalLinksView extends ConsumerWidget {
  const LegalLinksView({super.key, this.withTerms = true});

  final bool withTerms;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final links = ref.watch(legalLinksProvider);
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (links.privacy.isNotEmpty)
          ExternalLinkButton(
            key: const Key('link.privacy'),
            label: l10n.linkPrivacy,
            uri: Uri.parse(links.privacy),
          ),
        if (withTerms && links.terms.isNotEmpty)
          ExternalLinkButton(
            key: const Key('link.terms'),
            label: l10n.linkTerms,
            uri: Uri.parse(links.terms),
          ),
      ],
    );
  }
}
