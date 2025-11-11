import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  final String _key = "themeMode";
  late SharedPreferences _prefs;

  ThemeProvider() {
    _loadFromPrefs();
  }

  // Đọc cài đặt từ SharedPreferences khi khởi động
  _loadFromPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    bool isDarkMode = _prefs.getBool(_key) ?? false;
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // Lưu cài đặt vào SharedPreferences khi thay đổi
  _saveToPrefs(bool isDarkMode) {
    _prefs.setBool(_key, isDarkMode);
  }

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    _saveToPrefs(isDarkMode);
    notifyListeners();
  }
}