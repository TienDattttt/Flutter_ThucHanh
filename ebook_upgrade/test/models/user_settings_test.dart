import 'package:flutter_test/flutter_test.dart';
import 'package:ebook_upgrade/models/user_settings.dart';

void main() {
  group('UserSettings Model Tests', () {
    test('UserSettings fromMap should create valid object', () {
      final map = {
        'is_dark_mode': 1,
        'font_size': 18.0,
      };

      final settings = UserSettings.fromMap(map);

      expect(settings.isDarkMode, true);
      expect(settings.fontSize, 18.0);
    });

    test('UserSettings toMap should create valid map', () {
      final settings = UserSettings(
        isDarkMode: true,
        fontSize: 18.0,
      );

      final map = settings.toMap();

      expect(map['is_dark_mode'], 1);
      expect(map['font_size'], 18.0);
    });

    test('UserSettings defaultSettings should return default values', () {
      final settings = UserSettings.defaultSettings();

      expect(settings.isDarkMode, false);
      expect(settings.fontSize, 18.0);
    });

    test('UserSettings fromMap with dark mode false', () {
      final map = {
        'is_dark_mode': 0,
        'font_size': 22.0,
      };

      final settings = UserSettings.fromMap(map);

      expect(settings.isDarkMode, false);
      expect(settings.fontSize, 22.0);
    });
  });
}
