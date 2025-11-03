class Weather {
  final String cityName;
  final double temperature;   // °C
  final int humidity;         // %
  final String description;   // mô tả
  final String iconCode;      // mã icon từ API
  final double feelsLike;

  Weather({
    required this.cityName,
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.iconCode,
    required this.feelsLike,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final weatherList = json['weather'] as List<dynamic>;
    final weatherMain = json['main'] as Map<String, dynamic>;

    return Weather(
      cityName: json['name'] ?? '',
      temperature: (weatherMain['temp'] as num).toDouble(),
      humidity: (weatherMain['humidity'] as num).toInt(),
      feelsLike: (weatherMain['feels_like'] as num).toDouble(),
      description: weatherList.isNotEmpty
          ? (weatherList[0]['description'] as String)
          : '',
      iconCode: weatherList.isNotEmpty
          ? (weatherList[0]['icon'] as String)
          : '01d',
    );
  }
}
