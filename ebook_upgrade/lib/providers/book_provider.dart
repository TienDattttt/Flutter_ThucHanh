import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';

class BookProvider extends ChangeNotifier {
  final BookRepository _repository = BookRepository();
  
  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _books = await _repository.fetchBooks();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Không thể tải danh sách sách: ${e.toString()}';
      print('Error loading books: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLoadBooks() async {
    await loadBooks();
  }
}
