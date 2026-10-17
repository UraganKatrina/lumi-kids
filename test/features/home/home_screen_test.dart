import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_kids/app/lumi_app.dart';
import 'package:lumi_kids/app/lumi_theme.dart';

void main() {
  testWidgets('стартовый экран показывает название и кнопку', (tester) async {
    await tester.pumpWidget(const LumiApp());

    expect(find.text('LUMI Kids'), findsOneWidget);
    expect(find.byKey(const Key('home.start')), findsOneWidget);
  });

  testWidgets('кнопка достаточно крупная для ребёнка', (tester) async {
    await tester.pumpWidget(const LumiApp());

    final size = tester.getSize(find.byKey(const Key('home.start')));
    expect(size.height, greaterThanOrEqualTo(LumiTheme.minTapTarget));
  });
}
