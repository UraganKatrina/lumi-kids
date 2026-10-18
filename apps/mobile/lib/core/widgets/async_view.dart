import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../design_system/lumi_character.dart';
import '../design_system/lumi_tokens.dart';
import '../../l10n/l10n.dart';

/// Единое отображение загрузки и ошибки для асинхронных данных.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({super.key, required this.value, required this.builder});

  final AsyncValue<T> value;
  final Widget Function(T data) builder;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: builder,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(LumiSpacing.l),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const LumiCharacter(size: 96),
              const SizedBox(height: LumiSpacing.m),
              Text(
                context.l10n.commonError,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
