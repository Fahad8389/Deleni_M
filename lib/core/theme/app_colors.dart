import 'package:flutter/material.dart';

class AppColors {
  // ── Notion Light Palette ──
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFFFFFFF);
  static const highlight = Color(0xFFF7F6F3);
  static const textPrimary = Color(0xFF37352F);
  static const textSecondary = Color(0xFF787774);
  static const divider = Color(0xFFE3E2DE);
  static const border = Color(0xFFE3E2DE);

  // ── Notion Dark Palette ──
  static const darkBackground = Color(0xFF191919);
  static const darkSurface = Color(0xFF202020);
  static const darkHighlight = Color(0xFF2F2F2F);
  static const darkTextPrimary = Color(0xFFE3E2E0);
  static const darkTextSecondary = Color(0xFF9B9A97);
  static const darkDivider = Color(0xFF363636);
  static const darkBorder = Color(0xFF363636);

  // ── Accent Colors (same in light & dark) ──
  static const blue = Color(0xFF2EAADC);
  static const red = Color(0xFFEB5757);
  static const green = Color(0xFF4DAB9A);
  static const yellow = Color(0xFFCB912F);
  static const orange = Color(0xFFD9730D);
  static const purple = Color(0xFF9065B0);
  static const pink = Color(0xFFE255A1);

  // ── Chip/Tag Backgrounds (light tints) ──
  static const blueBg = Color(0xFFD3E5EF);
  static const redBg = Color(0xFFFFE2DD);
  static const greenBg = Color(0xFFDBEDDB);
  static const yellowBg = Color(0xFFFDECC8);
  static const orangeBg = Color(0xFFFADEC9);
  static const purpleBg = Color(0xFFE8DEEE);
  static const pinkBg = Color(0xFFF5E0E9);

  // ── Dark mode accent (slightly muted) ──
  static const darkBlue = Color(0xFF529CCA);

  // ── Backward-compat aliases (so existing code compiles) ──
  static const deepTeal = blue;
  static const warmSand = background;
  static const alabaster = surface;
  static const terracotta = red;
  static const datePalmGreen = green;
  static const gold = yellow;
  static const midnightIndigo = darkBackground;
  static const textDark = textPrimary;
  static const textLight = darkTextPrimary;
  static const subtitleDark = textSecondary;
  static const subtitleLight = darkTextSecondary;
  static const dividerLight = divider;
  static const dividerDark = darkDivider;
}
