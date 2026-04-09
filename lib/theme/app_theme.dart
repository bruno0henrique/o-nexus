import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF121212);
  static const Color primaryTeal = Color(0xFF00FFFF);
  static const Color teal10 = Color(0x1A00FFFF);
  static const Color teal20 = Color(0x3300FFFF);
  static const Color warningOrange = Color(0xFFFFD700);
  static const Color criticalRed = Color(0xFFFF0000);
  static const Color darkPanel = Color(0xFF1A1A1A);
  static const Color darkerPanel = Color(0xFF161616);
  static const Color accentGray = Color(0xFF333333);
  static const Color textWhite = Color(0xFFE0E0E0);
  static const Color textGray = Color(0xFFA0A0A0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primaryTeal,
      fontFamily: 'Roboto', // Fallback modern font
      colorScheme: ColorScheme.dark(
        primary: primaryTeal,
        secondary: warningOrange,
        error: criticalRed,
        surface: darkPanel,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryTeal,
          foregroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textWhite, fontWeight: FontWeight.w600),
        displayMedium: TextStyle(color: textWhite, fontWeight: FontWeight.normal),
        bodyLarge: TextStyle(color: textWhite),
        bodyMedium: TextStyle(color: textGray),
        labelLarge: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold),
      ),
      dividerColor: accentGray,
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        iconTheme: IconThemeData(color: textWhite),
      ),
    );
  }
}
