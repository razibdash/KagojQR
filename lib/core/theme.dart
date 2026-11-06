import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// KagojQR design tokens (see PROJECT.md "UI & Color Plan").
class AppColors {
  AppColors._();

  static const primary = Color(0xFF0B6E4F);
  static const primaryDark = Color(0xFF084C38);
  static const accent = Color(0xFFF4A300);
  static const background = Color(0xFFF6F8F7);
  static const surface = Colors.white;
  static const textPrimary = Color(0xFF1B2420);
  static const textSecondary = Color(0xFF6B7873);
  static const success = Color(0xFF2E9E5B);
  static const danger = Color(0xFFD64545);

  // Dark mode (optional, later).
  static const darkBackground = Color(0xFF0F1A16);
  static const darkSurface = Color(0xFF17241F);
  static const darkPrimary = Color(0xFF3DBE8B);
}

/// 8px spacing grid.
class Gap {
  Gap._();
  static const double s = 8;
  static const double m = 16;
  static const double l = 24;
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
    error: AppColors.danger,
    surface: AppColors.surface,
  );
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
  );
  final text = GoogleFonts.hindSiliguriTextTheme(base.textTheme).apply(
    bodyColor: AppColors.textPrimary,
    displayColor: AppColors.textPrimary,
  );

  return base.copyWith(
    textTheme: text,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: text.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 1,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: text.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: AppColors.primary,
        side: const BorderSide(color: AppColors.primary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: text.labelLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ),
  );
}
