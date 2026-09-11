// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:appespacial/main.dart';

void main() {
  testWidgets('exibe mais planetas no mapa espacial e permite ampliar', (WidgetTester tester) async {
    await tester.pumpWidget(const SpaceApp());

    expect(find.text('Mercúrio'), findsOneWidget);
    expect(find.text('Vênus'), findsOneWidget);
    expect(find.text('Terra'), findsWidgets);
    expect(find.text('100%'), findsOneWidget);

    await tester.tap(find.byTooltip('Aumentar zoom'));
    await tester.pump();

    expect(find.text('115%'), findsOneWidget);
  });
}
