import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../domain/parental_gate.dart';
import '../../../l10n/l10n.dart';

/// Родительский барьер перед кабинетом, настройками, покупками и внешними
/// ссылками. true — ответ верный.
Future<bool> showParentalGate(BuildContext context, WidgetRef ref) async {
  final next = ref.read(gateQuestionProvider);
  final passed = await showDialog<bool>(
    context: context,
    builder: (context) => _GateDialog(nextQuestion: next),
  );
  return passed ?? false;
}

class _GateDialog extends StatefulWidget {
  const _GateDialog({required this.nextQuestion});

  final GateQuestion Function() nextQuestion;

  @override
  State<_GateDialog> createState() => _GateDialogState();
}

class _GateDialogState extends State<_GateDialog> {
  late GateQuestion _question = widget.nextQuestion();
  String _input = '';
  bool _wrong = false;

  void _type(String digit) {
    if (_input.length >= 2) return;
    setState(() {
      _input += digit;
      _wrong = false;
    });
  }

  void _erase() {
    if (_input.isEmpty) return;
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  void _submit() {
    if (_question.check(_input)) {
      Navigator.of(context).pop(true);
      return;
    }
    // Новый вопрос, чтобы ответ нельзя было подобрать перебором.
    setState(() {
      _wrong = true;
      _input = '';
      _question = widget.nextQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    Widget key(String label, VoidCallback onTap, String id, {Widget? icon}) =>
        SizedBox(
          width: LumiSizes.minTapTarget,
          height: LumiSizes.minTapTarget,
          child: OutlinedButton(
            key: Key(id),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              shape: const CircleBorder(),
            ),
            onPressed: onTap,
            child: icon ?? Text(label, style: text.titleLarge),
          ),
        );

    return AlertDialog(
      title: Text(context.l10n.gateTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.gate(_question),
              key: const Key('gate.question'),
              textAlign: TextAlign.center,
              style: text.titleLarge,
            ),
            const SizedBox(height: LumiSpacing.m),
            Container(
              key: const Key('gate.input'),
              width: 120,
              padding: const EdgeInsets.all(LumiSpacing.s),
              decoration: BoxDecoration(
                color: LumiColors.sky,
                borderRadius: BorderRadius.circular(LumiSpacing.s),
              ),
              child: Text(
                _input.isEmpty ? ' ' : _input,
                textAlign: TextAlign.center,
                style: text.headlineMedium,
              ),
            ),
            if (_wrong)
              Padding(
                padding: const EdgeInsets.only(top: LumiSpacing.s),
                child: Text(
                  context.l10n.gateWrong,
                  key: const Key('gate.error'),
                  style: text.bodyLarge?.copyWith(
                    color: LumiColors.gentleError,
                  ),
                ),
              ),
            const SizedBox(height: LumiSpacing.m),
            Wrap(
              spacing: LumiSpacing.s,
              runSpacing: LumiSpacing.s,
              alignment: WrapAlignment.center,
              children: [
                for (var d = 1; d <= 9; d++)
                  key('$d', () => _type('$d'), 'gate.digit.$d'),
                key(
                  '',
                  _erase,
                  'gate.erase',
                  icon: const Icon(Icons.backspace_outlined),
                ),
                key('0', () => _type('0'), 'gate.digit.0'),
                key(
                  '',
                  _submit,
                  'gate.submit',
                  icon: const Icon(Icons.check_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          key: const Key('gate.cancel'),
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.commonCancel),
        ),
      ],
    );
  }
}
