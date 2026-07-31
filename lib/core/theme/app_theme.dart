import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Soft modern purple / blue / pink palette for a premium kid-friendly look.
abstract final class AppColors {
  static const Color primary = Color(0xFF7C5CFC);
  static const Color primaryDark = Color(0xFF5B3FD4);
  static const Color secondary = Color(0xFF4FC3F7);
  static const Color accent = Color(0xFFFF6BB5);
  static const Color success = Color(0xFF4ADE80);
  static const Color danger = Color(0xFFFF6B6B);
  static const Color warning = Color(0xFFFFD166);
  static const Color gold = Color(0xFFFFD700);
  static const Color silver = Color(0xFFC0C8D8);
  static const Color bronze = Color(0xFFCD7F32);
  static const Color rankBlue = Color(0xFF5B9BD5);

  static const Color tileIdle = Color(0xFFFFFFF8);
  static const Color tileBlink = Color(0xFFFFE066);
  static const Color tileCorrect = Color(0xFF4ADE80);
  static const Color tileWrong = Color(0xFFFF6B6B);
  static const Color tileLocked = Color(0xFFB8B0D0);

  static const Color textPrimary = Color(0xFF2D2463);
  static const Color textSecondary = Color(0xFF6B6394);
  static const Color textOnDark = Color(0xFFFFFFF8);

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF8B6CFF),
      Color(0xFF5B9FFF),
      Color(0xFFFF7EB9),
    ],
    stops: [0.0, 0.5, 1.0],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFFF8),
      Color(0xFFF0EBFF),
    ],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF9B7BFF),
      Color(0xFF6B5AFF),
    ],
  );
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
    );

    return base.copyWith(
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.fredoka(
          fontSize: 42,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnDark,
        ),
        displayMedium: GoogleFonts.fredoka(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.textOnDark,
        ),
        headlineMedium: GoogleFonts.fredoka(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.nunito(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        labelLarge: GoogleFonts.nunito(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: AppColors.textOnDark,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnDark,
          textStyle: GoogleFonts.nunito(
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
