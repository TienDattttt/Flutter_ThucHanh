import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/weather_screen.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tin tức Thời tiết',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const WeatherScreen(),
    );
  }
}
