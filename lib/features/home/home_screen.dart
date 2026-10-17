import 'package:flutter/material.dart';

/// Стартовый экран-заглушка. Карта мира заменит его на этапе 3.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('LUMI Kids', style: textTheme.displayMedium),
                const SizedBox(height: 32),
                FilledButton(
                  key: const Key('home.start'),
                  onPressed: () {},
                  child: const Text('Играть'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
