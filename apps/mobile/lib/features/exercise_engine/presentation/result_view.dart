import 'package:flutter/material.dart';

import '../../../core/design_system/lumi_character.dart';
import '../../../core/design_system/lumi_tokens.dart';
import '../../../l10n/l10n.dart';

/// Экран результата: только похвала, без оценок и сравнений.
class ResultView extends StatelessWidget {
  const ResultView({
    super.key,
    required this.stars,
    required this.maxStars,
    required this.onMap,
    this.onNext,
    this.together = false,
  });

  final int stars;
  final int maxStars;
  final VoidCallback onMap;
  final VoidCallback? onNext;

  /// Занятие со взрослым: хвалим обоих.
  final bool together;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final l10n = context.l10n;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(LumiSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LumiCharacter(size: 160, mood: LumiMood.happy),
              const SizedBox(height: LumiSpacing.m),
              Text(
                together ? l10n.resultPlayedTogether : l10n.resultGreat,
                key: const Key('result.title'),
                style: text.displaySmall,
              ),
              const SizedBox(height: LumiSpacing.m),
              Semantics(
                label: l10n.mapStarsLabel(stars),
                excludeSemantics: true,
                child: Row(
                  key: const Key('result.stars'),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (var i = 0; i < maxStars; i++)
                      Icon(
                        i < stars
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: LumiColors.glow,
                        size: 64,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: LumiSpacing.xl),
              if (onNext != null) ...[
                FilledButton.icon(
                  key: const Key('result.next'),
                  onPressed: onNext,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text(l10n.resultNext),
                ),
                const SizedBox(height: LumiSpacing.m),
              ],
              OutlinedButton.icon(
                key: const Key('result.map'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(
                    LumiSizes.minTapTarget * 3,
                    LumiSizes.minTapTarget,
                  ),
                ),
                onPressed: onMap,
                icon: const Icon(Icons.grid_view_rounded),
                label: Text(l10n.resultToIsland),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
