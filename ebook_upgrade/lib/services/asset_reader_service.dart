import 'package:flutter/services.dart';

class AssetReaderService {
  final Map<String, List<String>> _paginationCache = {};

  Future<String> loadBookContent(String assetPath) async {
    try {
      final content = await rootBundle.loadString(assetPath);
      return content;
    } catch (e) {
      if (e.toString().contains('Unable to load asset')) {
        throw AssetNotFoundException('Asset not found: $assetPath - $e');
      }
      throw AssetLoadException('Failed to load asset: $assetPath - $e');
    }
  }

  List<String> paginateContent({
    required String content,
    required double screenWidth,
    required double screenHeight,
    required double fontSize,
    String? cacheKey,
  }) {
    // Check cache first
    if (cacheKey != null && _paginationCache.containsKey(cacheKey)) {
      return _paginationCache[cacheKey]!;
    }

    // Calculate approximate characters per page
    // This is a simplified calculation - in production you'd want more accurate text measurement
    final lineHeight = fontSize * 1.5;
    final linesPerPage = (screenHeight * 0.7) ~/ lineHeight; // 70% of screen for content
    final charsPerLine = (screenWidth * 0.9) ~/ (fontSize * 0.6); // Approximate char width
    final charsPerPage = linesPerPage * charsPerLine;

    // Split content into pages
    final pages = <String>[];
    final words = content.split(' ');
    StringBuffer currentPage = StringBuffer();
    int currentLength = 0;

    for (var word in words) {
      final wordLength = word.length + 1; // +1 for space
      
      if (currentLength + wordLength > charsPerPage && currentPage.isNotEmpty) {
        pages.add(currentPage.toString().trim());
        currentPage = StringBuffer();
        currentLength = 0;
      }
      
      currentPage.write('$word ');
      currentLength += wordLength;
    }

    // Add last page if not empty
    if (currentPage.isNotEmpty) {
      pages.add(currentPage.toString().trim());
    }

    // Cache the result
    if (cacheKey != null) {
      _paginationCache[cacheKey] = pages;
    }

    return pages;
  }

  void clearCache() {
    _paginationCache.clear();
  }
}

class AssetNotFoundException implements Exception {
  final String message;
  AssetNotFoundException(this.message);
  
  @override
  String toString() => message;
}

class AssetLoadException implements Exception {
  final String message;
  AssetLoadException(this.message);
  
  @override
  String toString() => message;
}
