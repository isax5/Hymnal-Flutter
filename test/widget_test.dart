// This is a basic Flutter widget test.
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hymnal_app/main.dart';
import 'package:hymnal_app/services/locator_service.dart';

void main() {
  setUp(() {
    setupLocator();
  });

  testWidgets('App renders', (WidgetTester tester) async {
    await tester.pumpWidget(const HymnalApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
