import 'package:flutter/foundation.dart';
import '../models/user_settings.dart';
import '../repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();
  
  UserSettings _currentSettings = UserSettings.defaultSettings();
  bool _isLoading = false;

  UserSettings get currentSettings => _currentSettings;
  bool get isLoading => _isLoading;
  bool get isDarkMode => _currentSettings.isDarkMode;
  double get fontSize => _currentSettings.fontSize;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentSettings = await _repository.getSettings();
    } catch (e) {
      print('Error loading settings: $e');
      _currentSettings = UserSettings.defaultSettings();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTheme() {
    _currentSettings = UserSettings(
      isDarkMode: !_currentSettings.isDarkMode,
      fontSize: _currentSettings.fontSize,
    );
    notifyListeners();
    _saveSettings();
  }

  void setFontSize(double size) {
    _currentSettings = UserSettings(
      isDarkMode: _currentSettings.isDarkMode,
      fontSize: size,
    );
    notifyListeners();
    _saveSettings();
  }

  Future<void> _saveSettings() async {
    try {
      _repository.saveSettingsDebounced(_currentSettings);
    } catch (e) {
      print('Error saving settings: $e');
    }
  }

  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}
