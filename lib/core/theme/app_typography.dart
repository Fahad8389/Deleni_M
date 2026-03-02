import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  static TextTheme textTheme(Brightness brightness) {
    final base = GoogleFonts.readexProTextTheme();
    final color = brightness == Brightness.light
        ? const Color(0xFF2D2D2D)
        : const Color(0xFFE8E8E8);

    return base.copyWith(
      headlineLarge: base.headlineLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w700,
        fontSize: 28,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 22,
      ),
      headlineSmall: base.headlineSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
      titleLarge: base.titleLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleMedium: base.titleMedium?.copyWith(
        color: color,
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      bodyLarge: base.bodyLarge?.copyWith(
        color: color,
        fontSize: 16,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        color: color,
        fontSize: 14,
      ),
      bodySmall: base.bodySmall?.copyWith(
        color: color.withOpacity(0.7),
        fontSize: 12,
      ),
      labelLarge: base.labelLarge?.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
    );
  }
}
