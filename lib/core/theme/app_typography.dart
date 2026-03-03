import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = GoogleFonts.readexProTextTheme();
    final color = brightness == Brightness.light
        ? AppColors.textPrimary
        : AppColors.darkTextPrimary;
    final secondary = brightness == Brightness.light
        ? AppColors.textSecondary
        : AppColors.darkTextSecondary;

    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 26,
        height: 1.3,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 20,
        height: 1.3,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 17,
        height: 1.3,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 15,
        height: 1.4,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.4,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w400,
        fontSize: 15,
        height: 1.5,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w400,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: secondary,
        fontWeight: FontWeight.w400,
        fontSize: 12,
        height: 1.5,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 14,
        height: 1.4,
      ),
    );
  }
}
