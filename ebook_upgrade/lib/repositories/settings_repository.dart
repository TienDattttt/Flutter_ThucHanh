import 'dart:async';
import '../models/user_settings.dart';
import '../models/reading_state.dart';
import '../services/database_service.dart';

class SettingsRepository {
  final DatabaseService _databaseService = DatabaseService();
  Timer? _saveTimer;

  Future<UserSettings> getSettings() async {
    try {
      final settingsData = await _databaseService.getSettings();
      return UserSettings.fromMap(settingsData);
    } catch (e) {
      // Return default settings if error occurs
      return UserSettings.defaultSettings();
    }
  }

  Future<void> saveSettings(UserSettings settings) async {
    try {
      await _databaseService.saveSettings(settings.toMap());
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }

  void saveSettingsDebounced(UserSettings settings, {Duration delay = const Duration(seconds: 2)}) {
    _saveTimer?.cancel();
    _saveTimer = Timer(delay, () {
      saveSettings(settings);
    });
  }

  Future<ReadingState?> getReadingState(String bookId) async {
    try {
      final stateData = await _databaseService.getReadingState(bookId);
      if (stateData == null) return null;
      return ReadingState.fromMap(stateData);
    } catch (e) {
      return null;
    }
  }

  Future<void> saveReadingState(ReadingState state) async {
    try {
      await _databaseService.saveReadingState(state.toMap());
    } catch (e) {
      throw Exception('Failed to save reading state: $e');
    }
  }

  void saveReadingStateDebounced(ReadingState state, {Duration delay = const Duration(seconds: 2)}) {
    _saveTimer?.cancel();
    _saveTimer = Timer(delay, () {
      saveReadingState(state);
    });
  }

  void dispose() {
    _saveTimer?.cancel();
  }
}
