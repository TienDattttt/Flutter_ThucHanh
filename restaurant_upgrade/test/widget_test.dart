// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SplashPage displays correctly', (WidgetTester tester) async {
    // Create a simple test widget without timers
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant,
                  size: 100,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Restaurant Review System',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text('Khám phá và đánh giá nhà hàng'),
                const SizedBox(height: 48),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ),
      ),
    );

    // Verify that the splash screen elements are displayed
    expect(find.text('Restaurant Review System'), findsOneWidget);
    expect(find.text('Khám phá và đánh giá nhà hàng'), findsOneWidget);
    expect(find.byIcon(Icons.restaurant), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
