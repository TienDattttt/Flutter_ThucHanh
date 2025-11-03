import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherException implements Exception {
  final String message;
  WeatherException(this.message);

  @override
  String toString() => message;
}

class WeatherApi {
  static const String _baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  // Đọc API key từ --dart-define
  static const String _apiKey =
  String.fromEnvironment('OPENWEATHER_API_KEY');


  static Future<Weather> fetchWeather(String cityName) async {
    if (_apiKey.isEmpty) {
      throw WeatherException(
        'Chưa cấu hình API key. Hãy chạy app với --dart-define=OPENWEATHER_API_KEY=...',
      );
    }

    final uri = Uri.parse(
      '$_baseUrl?q=$cityName&appid=$_apiKey&units=metric&lang=vi',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Weather.fromJson(data);
      } else if (response.statusCode == 404) {
        throw WeatherException('Không tìm thấy thành phố "$cityName".');
      } else {
        throw WeatherException(
          'Lỗi server (${response.statusCode}). Vui lòng thử lại.',
        );
      }
    } catch (e) {
      // Lỗi mạng, parse JSON...
      if (e is WeatherException) rethrow;
      throw WeatherException('Không thể kết nối. Kiểm tra mạng và thử lại.');
    }
  }
}
