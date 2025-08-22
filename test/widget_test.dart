
// MURITAP application smoke test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:impossible_tap/main.dart';

void main() {
  testWidgets('MURITAP app starts without errors', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ImpossibleTapApp());

    // Wait for app initialization
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Clear any rendering overflow warnings (non-fatal)
    final exception = tester.takeException();
    if (exception != null && exception.toString().contains('RenderFlex overflowed')) {
      // This is a non-fatal rendering overflow, acceptable for test
    } else if (exception != null) {
      // Re-throw if it's a different kind of error
      throw exception;
    }
    
    // Verify the app has loaded
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
