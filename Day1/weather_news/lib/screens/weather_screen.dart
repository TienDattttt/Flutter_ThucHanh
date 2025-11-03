import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather.dart';
import '../services/weather_api.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final TextEditingController _cityController = TextEditingController();
  Future<Weather>? _weatherFuture;

  static const _prefsKeyLastCity = 'last_city';

  @override
  void initState() {
    super.initState();
    _loadLastCityAndFetch();
  }

  Future<void> _loadLastCityAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCity = prefs.getString(_prefsKeyLastCity) ?? 'Ho Chi Minh';
    _cityController.text = lastCity;

    setState(() {
      _weatherFuture = WeatherApi.fetchWeather(lastCity);
    });
  }

  Future<void> _saveLastCity(String city) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyLastCity, city);
  }

  void _search() {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tên thành phố')),
      );
      return;
    }

    setState(() {
      _weatherFuture = WeatherApi.fetchWeather(city);
    });
    _saveLastCity(city);
  }

  IconData _mapIcon(String iconCode) {
    // map sơ sơ theo mã icon OpenWeather
    if (iconCode.contains('d')) {
      // ban ngày
      if (iconCode.startsWith('01')) return Icons.wb_sunny;
      if (iconCode.startsWith('02') || iconCode.startsWith('03')) {
        return Icons.cloud;
      }
    } else {
      // ban đêm
      if (iconCode.startsWith('01')) return Icons.nightlight_round;
    }
    if (iconCode.startsWith('09') || iconCode.startsWith('10')) {
      return Icons.grain; // mưa
    }
    if (iconCode.startsWith('11')) return Icons.flash_on; // giông
    if (iconCode.startsWith('13')) return Icons.ac_unit; // tuyết
    if (iconCode.startsWith('50')) return Icons.blur_on; // sương mù
    return Icons.cloud_queue;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Gradient nền kiểu AccuWeather
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF0B1020),
            Color(0xFF182A4A),
            Color(0xFF274B74),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Tin tức Thời tiết'),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Ô nhập city + nút search
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _cityController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Nhập tên thành phố...',
                          hintStyle: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          prefixIcon: const Icon(Icons.location_city,
                              color: Colors.white),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onSubmitted: (_) => _search(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: _search,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Icon(Icons.search),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // FutureBuilder hiển thị thời tiết / loading / lỗi
                Expanded(
                  child: FutureBuilder<Weather>(
                    future: _weatherFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (snapshot.hasError) {
                        final errorMsg = snapshot.error.toString();

                        // show SnackBar thân thiện
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMsg)),
                          );
                        });

                        return Center(
                          child: Text(
                            errorMsg,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      if (!snapshot.hasData) {
                        return const Center(
                          child: Text(
                            'Hãy nhập tên thành phố để xem thời tiết.',
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      final weather = snapshot.data!;
                      final iconData = _mapIcon(weather.iconCode);

                      return _WeatherInfoCard(
                        weather: weather,
                        iconData: iconData,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WeatherInfoCard extends StatelessWidget {
  final Weather weather;
  final IconData iconData;

  const _WeatherInfoCard({
    required this.weather,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFF8C42),
              Color(0xFFFFC857),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weather.cityName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Icon(
              iconData,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              '${weather.temperature.toStringAsFixed(1)}°C',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cảm giác: ${weather.feelsLike.toStringAsFixed(1)}°C',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              weather.description,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.water_drop, color: Colors.white, size: 20),
                const SizedBox(width: 4),
                Text(
                  'Độ ẩm: ${weather.humidity}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
