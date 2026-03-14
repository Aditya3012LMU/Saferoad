import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:presence/main.dart';

void main() {
  testWidgets('Presence app smoke test', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: PresenceApp()));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
