import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../core/design_system/item_card.dart';
import '../../../../core/design_system/lumi_tokens.dart';
import '../../../content_library/domain/task.dart';
import '../../domain/exercise_session.dart';

class ChoiceBody extends StatefulWidget {
  const ChoiceBody({super.key, required this.session, required this.onChanged});

  final ChoiceSession session;
  final VoidCallback onChanged;

  @override
  State<ChoiceBody> createState() => _ChoiceBodyState();
}

class _ChoiceBodyState extends State<ChoiceBody> {
  late final ChoiceContent _content =
      widget.session.task.content as ChoiceContent;
  late final List<TaskItem> _options = [..._content.options];

  @override
  void initState() {
    super.initState();
    if (_content.shuffle) _options.shuffle(Random());
  }

  @override
  Widget build(BuildContext context) {
    final prompt = _content.prompt?.label;
    return Column(
      children: [
        if (prompt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: LumiSpacing.l),
            child: Text(
              prompt,
              key: const Key('exercise.prompt'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 56),
            ),
          ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: LumiSpacing.m,
          runSpacing: LumiSpacing.m,
          children: [
            for (final option in _options)
              ItemCard(
                key: Key('option.${option.id}'),
                label: option.display,
                state: widget.session.rejected.contains(option.id)
                    ? ItemCardState.faded
                    : ItemCardState.normal,
                onTap: () {
                  widget.session.answer(option.id);
                  widget.onChanged();
                },
              ),
          ],
        ),
      ],
    );
  }
}
