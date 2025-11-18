import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_upgrade/widgets/control_panel.dart';

void main() {
  group('ControlPanel Widget Tests', () {
    testWidgets('ControlPanel displays page progress', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ControlPanel(
                  isVisible: true,
                  currentPage: 5,
                  totalPages: 100,
                  onSettingsTap: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('Trang 6 / 100'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('ControlPanel animates visibility', (WidgetTester tester) async {
      bool isVisible = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Stack(
                  children: [
                    ControlPanel(
                      isVisible: isVisible,
                      currentPage: 0,
                      totalPages: 10,
                      onSettingsTap: () {},
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      
      // Panel should be hidden initially
      final initialPosition = tester.getBottomLeft(find.byType(ControlPanel));
      expect(initialPosition.dy, greaterThan(600));
    });

    testWidgets('ControlPanel settings button triggers callback', (WidgetTester tester) async {
      bool settingsTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                ControlPanel(
                  isVisible: true,
                  currentPage: 0,
                  totalPages: 10,
                  onSettingsTap: () {
                    settingsTapped = true;
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(settingsTapped, true);
    });
  });
}
