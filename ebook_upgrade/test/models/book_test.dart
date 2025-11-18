import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_upgrade/models/book.dart';

void main() {
  group('Book Model Tests', () {
    test('Book fromJson should create valid Book object', () {
      final json = {
        'id': '1',
        'title': 'Test Book',
        'author': 'Test Author',
        'description': 'Test Description',
        'coverImageUrl': 'http://example.com/cover.jpg',
        'assetPath': 'assets/books/test.txt',
      };

      final book = Book.fromJson(json);

      expect(book.id, '1');
      expect(book.title, 'Test Book');
      expect(book.author, 'Test Author');
      expect(book.description, 'Test Description');
      expect(book.coverImageUrl, 'http://example.com/cover.jpg');
      expect(book.assetPath, 'assets/books/test.txt');
    });

    test('Book toJson should create valid JSON', () {
      final book = Book(
        id: '1',
        title: 'Test Book',
        author: 'Test Author',
        description: 'Test Description',
        coverImageUrl: 'http://example.com/cover.jpg',
        assetPath: 'assets/books/test.txt',
      );

      final json = book.toJson();

      expect(json['id'], '1');
      expect(json['title'], 'Test Book');
      expect(json['author'], 'Test Author');
      expect(json['description'], 'Test Description');
      expect(json['coverImageUrl'], 'http://example.com/cover.jpg');
      expect(json['assetPath'], 'assets/books/test.txt');
    });

    test('Book fromJson with null coverImageUrl', () {
      final json = {
        'id': '1',
        'title': 'Test Book',
        'author': 'Test Author',
        'description': 'Test Description',
        'coverImageUrl': null,
        'assetPath': 'assets/books/test.txt',
      };

      final book = Book.fromJson(json);

      expect(book.coverImageUrl, null);
    });
  });
}
