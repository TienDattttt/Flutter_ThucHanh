import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_upgrade/widgets/book_card.dart';
import 'package:ebook_upgrade/models/book.dart';

void main() {
  group('BookCard Widget Tests', () {
    testWidgets('BookCard displays book information', (WidgetTester tester) async {
      final book = Book(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'Test Description',
        assetPath: 'assets/books/test.txt',
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BookCard(
              book: book,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Test Book'), findsOneWidget);
      expect(find.text('Test Author'), findsOneWidget);
      expect(find.text('Test Description'), findsOneWidget);
      expect(find.byIcon(Icons.book), findsOneWidget);

      await tester.tap(find.byType(BookCard));
      await tester.pumpAndSettle();

      expect(tapped, true);
    });
  });
}
