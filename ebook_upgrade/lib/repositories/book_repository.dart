import '../models/book.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';
import '../services/asset_reader_service.dart';

class BookRepository {
  final ApiService _apiService = ApiService();
  final DatabaseService _databaseService = DatabaseService();
  final AssetReaderService _assetReaderService = AssetReaderService();

  Future<List<Book>> fetchBooks() async {
    try {
      // Try to fetch from API first
      final booksData = await _apiService.fetchBooks();
      final books = booksData.map((data) => Book.fromJson(data)).toList();
      
      // Cache the books
      await cacheBooks(books);
      
      return books;
    } catch (e) {
      // If API fails, fallback to cached books
      try {
        final cachedBooksData = await _databaseService.getCachedBooks();
        if (cachedBooksData.isEmpty) {
          throw Exception('No cached books available');
        }
        return cachedBooksData.map((data) {
          return Book(
            id: data['id'] as String,
            title: data['title'] as String,
            author: data['author'] as String,
            description: data['description'] as String? ?? '',
            coverImageUrl: data['cover_image_url'] as String?,
            assetPath: data['asset_path'] as String,
          );
        }).toList();
      } catch (cacheError) {
        throw Exception('Failed to fetch books: $e. Cache error: $cacheError');
      }
    }
  }

  Future<String> getBookContent(String assetPath) async {
    try {
      return await _assetReaderService.loadBookContent(assetPath);
    } catch (e) {
      throw Exception('Failed to load book content: $e');
    }
  }

  Future<void> cacheBooks(List<Book> books) async {
    try {
      final booksData = books.map((book) {
        return {
          'id': book.id,
          'title': book.title,
          'author': book.author,
          'description': book.description,
          'cover_image_url': book.coverImageUrl,
          'asset_path': book.assetPath,
          'cached_at': DateTime.now().toIso8601String(),
        };
      }).toList();
      
      await _databaseService.cacheBooks(booksData);
    } catch (e) {
      // Log error but don't throw - caching failure shouldn't break the app
      print('Failed to cache books: $e');
    }
  }
}
