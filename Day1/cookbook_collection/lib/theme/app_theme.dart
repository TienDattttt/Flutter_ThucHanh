// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: Color(0xFFFF6B6B),
        secondary: Color(0xFFFFC93C),
        tertiary: Color(0xFF6C5CE7),
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    );
  }
}
