import 'package:flutter/material.dart';
import '../constants/ws_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: WsColors.white,
      colorScheme: const ColorScheme.light(
        primary: WsColors.accentCyan,
        secondary: WsColors.secondaryMint,
        surface: WsColors.surface,
        onPrimary: WsColors.white,
        onSecondary: WsColors.darkBlue,
        onSurface: WsColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: WsColors.surface,
        foregroundColor: WsColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: WsColors.surface,
        elevation: 2,
        shadowColor: Colors.black.withAlpha(15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: WsColors.border),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: WsColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: WsColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: WsColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: WsColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: WsColors.textPrimary,
        ),
        titleSmall: TextStyle(
          color: WsColors.textSecondary,
        ),
        bodyLarge: TextStyle(
          color: WsColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          color: WsColors.textSecondary,
        ),
        labelSmall: TextStyle(
          color: WsColors.textSecondary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: WsColors.accentCyan,
          foregroundColor: WsColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: WsColors.surface,
        titleTextStyle: TextStyle(
          color: WsColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
