import 'package:flutter/foundation.dart';
import '../models/reading_state.dart';
import '../models/book.dart';
import '../repositories/book_repository.dart';
import '../repositories/settings_repository.dart';
import '../services/asset_reader_service.dart';

class ReadingStateProvider extends ChangeNotifier {
  final BookRepository _bookRepository = BookRepository();
  final SettingsRepository _settingsRepository = SettingsRepository();
  final AssetReaderService _assetReaderService = AssetReaderService();
  
  ReadingState? _currentState;
  String? _currentBookContent;
  List<String> _pages = [];
  Book? _currentBook;
  bool _isLoading = false;

  ReadingState? get currentState => _currentState;
  String? get currentBookContent => _currentBookContent;
  List<String> get pages => _pages;
  Book? get currentBook => _currentBook;
  bool get isLoading => _isLoading;
  int get currentPage => _currentState?.currentPage ?? 0;
  int get totalPages => _pages.length;

  Future<void> loadBook(Book book, double screenWidth, double screenHeight, double fontSize) async {
    _isLoading = true;
    _currentBook = book;

    try {
      // Load book content
      _currentBookContent = await _bookRepository.getBookContent(book.assetPath);
      
      // Paginate content
      _pages = _assetReaderService.paginateContent(
        content: _currentBookContent!,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        fontSize: fontSize,
        cacheKey: '${book.id}_$fontSize',
      );

      // Load saved reading state
      final savedState = await _settingsRepository.getReadingState(book.id);
      
      if (savedState != null && savedState.currentPage < _pages.length) {
        _currentState = savedState;
      } else {
        // Create new reading state
        _currentState = ReadingState(
          bookId: book.id,
          currentPage: 0,
          totalPages: _pages.length,
          lastReadAt: DateTime.now(),
        );
      }
    } catch (e) {
      print('Error loading book: $e');
      _currentBookContent = null;
      _pages = [];
      _currentState = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void goToPage(int pageNumber) {
    if (_currentState == null || _currentBook == null) return;
    
    // Boundary checks
    if (pageNumber < 0 || pageNumber >= _pages.length) return;

    _currentState = ReadingState(
      bookId: _currentBook!.id,
      currentPage: pageNumber,
      totalPages: _pages.length,
      lastReadAt: DateTime.now(),
    );
    
    notifyListeners();
    _saveCurrentPage();
  }

  void nextPage() {
    if (_currentState == null) return;
    goToPage(_currentState!.currentPage + 1);
  }

  void previousPage() {
    if (_currentState == null) return;
    goToPage(_currentState!.currentPage - 1);
  }

  Future<void> _saveCurrentPage() async {
    if (_currentState == null) return;
    
    try {
      _settingsRepository.saveReadingStateDebounced(_currentState!);
    } catch (e) {
      print('Error saving reading state: $e');
    }
  }

  void repaginate(double screenWidth, double screenHeight, double fontSize) {
    if (_currentBookContent == null || _currentBook == null) return;

    final currentPageContent = _currentState != null && _currentState!.currentPage < _pages.length
        ? _pages[_currentState!.currentPage]
        : null;

    // Repaginate with new font size
    _pages = _assetReaderService.paginateContent(
      content: _currentBookContent!,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      fontSize: fontSize,
      cacheKey: '${_currentBook!.id}_$fontSize',
    );

    // Try to find the same content in new pagination
    int newPageIndex = 0;
    if (currentPageContent != null) {
      for (int i = 0; i < _pages.length; i++) {
        if (_pages[i].startsWith(currentPageContent.substring(0, 50.clamp(0, currentPageContent.length)))) {
          newPageIndex = i;
          break;
        }
      }
    }

    _currentState = ReadingState(
      bookId: _currentBook!.id,
      currentPage: newPageIndex,
      totalPages: _pages.length,
      lastReadAt: DateTime.now(),
    );

    notifyListeners();
    _saveCurrentPage();
  }

  @override
  void dispose() {
    _settingsRepository.dispose();
    super.dispose();
  }
}
