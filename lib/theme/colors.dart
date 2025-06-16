import 'package:flutter/material.dart';

class AppColors {
  // Brand colors (consistent across themes)
  static const Color kAccentMint = Color(0xFF1ABC9C);
  static const Color kAccentMintLight = Color(0xFF68D8C5);
  static const Color kAlertRed = Color(0xFFD64541);

  // Dark theme colors
  static const Color kBrandDark = Color(0xFF282B2B);
  static const Color kSurfaceDark = Color(0xFF1E1E1E);
  static const Color kCardDark = Color(0xFF2A2A2A);

  // Light theme colors
  static const Color kBrandLight = Color(0xFFF3F3F3);
  static const Color kSurfaceLight = Color(0xFFFFFFFF);
  static const Color kCardLight = Color(0xFFFFFFFF);
  static const Color kTextLight = Color(0xFF1A202C);
  static const Color kTextSecondaryLight = Color(0xFF4A5568);

  // Neutral colors
  static const Color kSurfaceGray = Color(0xFFF3F3F3);
  static const Color kBorderLight = Color(0xFFE2E8F0);
  static const Color kBorderDark = Color(0xFF4A5568);

  // Gradient colors
  static const LinearGradient mintGradient = LinearGradient(
    colors: [kAccentMint, kAccentMintLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Theme-aware colors
  static Color backgroundColor(bool isDark) =>
      isDark ? kBrandDark : kBrandLight;

  static Color surfaceColor(bool isDark) =>
      isDark ? kSurfaceDark : kSurfaceLight;

  static Color cardColor(bool isDark) => isDark ? kCardDark : kCardLight;

  static Color textColor(bool isDark) => isDark ? Colors.white : kTextLight;

  static Color textSecondaryColor(bool isDark) =>
      isDark ? Colors.grey : kTextSecondaryLight;

  static Color borderColor(bool isDark) => isDark ? kBorderDark : kBorderLight;
}
