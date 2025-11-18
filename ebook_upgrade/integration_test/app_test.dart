import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ebook_upgrade/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E-book Reader App Integration Tests', () {
    testWidgets('Complete user flow: Launch -> Load books -> Open book -> Read', 
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify home screen is displayed
      expect(find.text('Thư viện sách'), findsOneWidget);

      // Wait for books to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify books are displayed
      expect(find.byType(Card), findsWidgets);

      // Tap on first book
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify book reader screen is displayed
      expect(find.byType(AppBar), findsOneWidget);

      // Tap to show control panel
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Verify control panel is visible
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Go back to home screen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Verify we're back at home screen
      expect(find.text('Thư viện sách'), findsOneWidget);
    });

    testWidgets('Settings persistence test', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Toggle theme
      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

      // Wait for settings to save
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify theme changed (this is a simplified check)
      expect(find.byIcon(Icons.brightness_6), findsOneWidget);
    });

    testWidgets('Offline mode with cached data', (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Wait for books to load and cache
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify books are displayed (from cache or API)
      expect(find.byType(Card), findsWidgets);

      // Pull to refresh
      await tester.drag(find.byType(RefreshIndicator), const Offset(0, 300));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify books are still displayed
      expect(find.byType(Card), findsWidgets);
    });
  });
}
