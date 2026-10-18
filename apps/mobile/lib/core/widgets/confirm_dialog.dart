import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Подтверждение необратимого действия. true — взрослый согласился.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          key: const Key('confirm.no'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          key: const Key('confirm.yes'),
          style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
