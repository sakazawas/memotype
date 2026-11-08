import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const backgroundColor = Color(0xFF1E1C19);
    const surfaceColor = Color(0xFF2B2823);
    const inputColor = Color(0xFF363129);
    const beigeColor = Color(0xFFD8C9AA);
    const accentColor = Color(0xFF9DB2A5);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: beigeColor,
        secondary: accentColor,
        surface: surfaceColor,
        error: Color(0xFFD28C83),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: beigeColor,
        centerTitle: true,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF4A4339),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputColor,
        labelStyle: const TextStyle(
          color: Color(0xFFC1B69F),
        ),
        hintStyle: const TextStyle(
          color: Color(0xFF918878),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFF4A4339),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: beigeColor,
            width: 1.5,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: beigeColor,
          foregroundColor: const Color(0xFF25211C),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: beigeColor,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(
            color: Color(0xFF6B6253),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Color(0xFF494137),
        contentTextStyle: TextStyle(
          color: Color(0xFFF1E7D3),
        ),
      ),
    );
  }
}