import 'package:flutter/material.dart';
import '../constants/ws_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: WsColors.bgPrimary,
      colorScheme: const ColorScheme.dark(
        primary: WsColors.darkBlue,
        secondary: WsColors.accentBlue,
        surface: WsColors.bgPanel,
        onPrimary: WsColors.white,
        onSecondary: WsColors.white,
        onSurface: WsColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: WsColors.bgPanel,
        foregroundColor: WsColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: WsColors.bgPanel,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: WsColors.textSecondary.withAlpha(30),
          ),
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
          backgroundColor: WsColors.accentBlue,
          foregroundColor: WsColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
