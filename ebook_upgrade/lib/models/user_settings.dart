class UserSettings {
  final bool isDarkMode;
  final double fontSize;

  UserSettings({
    required this.isDarkMode,
    required this.fontSize,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      isDarkMode: map['is_dark_mode'] == 1,
      fontSize: map['font_size'] as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'is_dark_mode': isDarkMode ? 1 : 0,
      'font_size': fontSize,
    };
  }

  // Default settings
  factory UserSettings.defaultSettings() {
    return UserSettings(
      isDarkMode: false,
      fontSize: 18.0,
    );
  }
}
