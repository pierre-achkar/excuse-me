import 'package:flutter/material.dart';

class ShopTheme {
  ShopTheme._();

  // Pixel layer: shop scene and collectible cards.
  static const pixelViolet = Color(0xFF7F5BD6);
  static const pixelVioletDark = Color(0xFF6144B8);
  static const pixelTeal = Color(0xFF3FB6A0);
  static const pixelGlow = Color(0xFFFCDE5A);
  static const pixelEmber = Color(0xFFE8593C);
  static const pixelOutline = Color(0xFF1A1622);

  // Paper surfaces: card body and illustration panel.
  static const paperBody = Color(0xFFFAEEDA);
  static const paperPanel = Color(0xFFEDEAE2);
  static const paperDivider = Color(0xFFDCD2B8);
  static const paperMeta = Color(0xFF8A7B5E);
  static const paperSkin = Color(0xFFF0C08A);

  // Clean layer: app chrome outside the shop and cards.
  static const uiCanvas = Color(0xFFFBFAF7);
  static const uiSurface = Color(0xFFFFFFFF);
  static const uiHairline = Color(0xFFE7E4DD);
  static const uiTextPrimary = Color(0xFF241F2E);
  static const uiTextSecondary = Color(0xFF6B6558);
  static const uiAccent = pixelViolet;

  // Compatibility aliases for the existing shop implementation.
  static const paper = uiCanvas;
  static const ink = uiTextPrimary;
  static const accent = uiAccent;
  static const cardBackground = paperBody;
  static const subtle = uiTextSecondary;
  static const errorColor = Color(0xFFB3261E);

  static ThemeData get theme => _buildTheme(
    canvas: uiCanvas,
    surface: uiSurface,
    hairline: uiHairline,
    primaryText: uiTextPrimary,
    secondaryText: uiTextSecondary,
  );

  static ThemeData get darkTheme => _buildTheme(
    canvas: const Color(0xFF161320),
    surface: const Color(0xFF1F1B2A),
    hairline: const Color(0xFF2E2939),
    primaryText: const Color(0xFFF4F1F6),
    secondaryText: const Color(0xFFA09AAF),
  );

  static ThemeData _buildTheme({
    required Color canvas,
    required Color surface,
    required Color hairline,
    required Color primaryText,
    required Color secondaryText,
  }) {
    final colorScheme = ColorScheme(
      brightness: canvas == uiCanvas ? Brightness.light : Brightness.dark,
      primary: uiAccent,
      onPrimary: Colors.white,
      secondary: pixelTeal,
      onSecondary: pixelOutline,
      error: errorColor,
      onError: Colors.white,
      surface: surface,
      onSurface: primaryText,
      outline: hairline,
    );

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: canvas,
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: primaryText,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
      ),
      textTheme: TextTheme(
        headlineSmall: TextStyle(
          fontSize: 27,
          height: 1.2,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          height: 1.3,
          fontWeight: FontWeight.w500,
          color: primaryText,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          height: 1.45,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          height: 1.5,
          fontWeight: FontWeight.w400,
          color: primaryText,
        ),
        labelLarge: const TextStyle(
          fontSize: 14,
          height: 1.3,
          fontWeight: FontWeight.w500,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w400,
          color: secondaryText,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: hairline),
        ),
      ),
      dividerTheme: DividerThemeData(color: hairline, thickness: 1),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: uiAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryText,
          minimumSize: const Size(44, 44),
          side: BorderSide(color: hairline),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
        ),
      ),
    );
  }
}
