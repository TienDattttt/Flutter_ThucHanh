import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Using a mock API endpoint - you can replace this with a real API
  static const String baseUrl = 'https://my-json-server.typicode.com/typicode/demo';
  static const Duration timeout = Duration(seconds: 10);
  static const int maxRetries = 3;

  Future<List<Map<String, dynamic>>> fetchBooks() async {
    // For demo purposes, return mock data directly
    // In production, this would make actual HTTP requests
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    return _getMockBooks();
  }

  List<Map<String, dynamic>> _getMockBooks() {
    return [
      {
        'id': '1',
        'title': 'Truyện Kiều',
        'author': 'Nguyễn Du',
        'description': 'Tác phẩm văn học kinh điển của Việt Nam, kể về số phận của Thúy Kiều.',
        'coverImageUrl': null,
        'assetPath': 'assets/books/truyen_kieu.txt',
      },
      {
        'id': '2',
        'title': 'Số Đỏ',
        'author': 'Vũ Trọng Phụng',
        'description': 'Tiểu thuyết châm biếm xã hội Việt Nam thời thuộc địa.',
        'coverImageUrl': null,
        'assetPath': 'assets/books/so_do.txt',
      },
      {
        'id': '3',
        'title': 'Chí Phèo',
        'author': 'Nam Cao',
        'description': 'Truyện ngắn nổi tiếng về số phận bi thảm của người nông dân.',
        'coverImageUrl': null,
        'assetPath': 'assets/books/chi_pheo.txt',
      },
    ];
  }

  Future<List<Map<String, dynamic>>> _fetchBooksFromApi() async {
    int retryCount = 0;
    
    while (retryCount < maxRetries) {
      try {
        final response = await http
            .get(
              Uri.parse('$baseUrl/books'),
            )
            .timeout(timeout);

        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.cast<Map<String, dynamic>>();
        } else if (response.statusCode >= 500) {
          // Server error - retry
          retryCount++;
          if (retryCount < maxRetries) {
            await _exponentialBackoff(retryCount);
            continue;
          }
          throw ServerException('Server error: ${response.statusCode}');
        } else {
          // Client error - don't retry
          throw ClientException('Client error: ${response.statusCode}');
        }
      } on http.ClientException catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await _exponentialBackoff(retryCount);
          continue;
        }
        throw NetworkException('Network error: $e');
      } catch (e) {
        retryCount++;
        if (retryCount < maxRetries) {
          await _exponentialBackoff(retryCount);
          continue;
        }
        throw Exception('Failed to fetch books: $e');
      }
    }
    
    throw Exception('Max retries exceeded');
  }

  Future<void> _exponentialBackoff(int retryCount) async {
    final delay = Duration(milliseconds: 100 * (1 << retryCount));
    await Future.delayed(delay);
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => message;
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
  
  @override
  String toString() => message;
}

class ClientException implements Exception {
  final String message;
  ClientException(this.message);
  
  @override
  String toString() => message;
}
