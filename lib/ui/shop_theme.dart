import 'package:flutter/material.dart';

class ShopTheme {
  ShopTheme._();

  static const paper = Color(0xFFFAF3E8);
  static const ink = Color(0xFF2E1B0E);
  static const accent = Color(0xFFC45B28);
  static const cardBackground = Color(0xFFF0E6D3);
  static const subtle = Color(0xFFA89278);
  static const errorColor = Color(0xFFB3261E);

  static ThemeData get theme {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        primary: accent,
        onPrimary: Colors.white,
        surface: paper,
        onSurface: ink,
        error: errorColor,
      ),
      scaffoldBackgroundColor: paper,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'monospace',
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: ink,
          letterSpacing: 1.5,
        ),
      ),
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontFamily: 'monospace',
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        titleLarge: TextStyle(
          fontFamily: 'monospace',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleMedium: TextStyle(
          fontFamily: 'monospace',
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        bodyLarge: TextStyle(fontFamily: 'monospace', fontSize: 16, color: ink),
        bodyMedium: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          color: ink,
        ),
        labelLarge: TextStyle(
          fontFamily: 'monospace',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        labelMedium: TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: subtle,
        ),
      ),
    );
  }
}
