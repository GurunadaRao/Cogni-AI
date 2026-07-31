import 'package:flutter/material.dart';

class AppTheme {
  // Light Theme Palette
  static const Color iceBlue = Color(0xFFE3F2FD);       // Background cards / subtle fill
  static const Color softBlue = Color(0xFF90CAF9);      // Borders & muted elements
  static const Color vividBlue = Color(0xFF2196F3);     // Primary action / accent
  static const Color royalDarkBlue = Color(0xFF0D47A1); // Deep text & primary title
  static const Color background = Color(0xFFF8FAFC);    // Main background

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: vividBlue,
      colorScheme: ColorScheme.light(
        primary: vividBlue,
        secondary: softBlue,
        surface: iceBlue,
        onPrimary: Colors.white,
        onSurface: royalDarkBlue,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: royalDarkBlue,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          color: royalDarkBlue,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: TextStyle(
          color: royalDarkBlue,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: Color(0xFF1E3A8A),
          fontSize: 14,
        ),
      ),
    );
  }
}
