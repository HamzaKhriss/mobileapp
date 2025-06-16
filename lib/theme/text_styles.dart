import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  static TextStyle get h1 => GoogleFonts.urbanist(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        // Color will be overridden by components
      );

  static TextStyle get h2 => GoogleFonts.urbanist(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        // Color will be overridden by components
      );

  static TextStyle get h3 => GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        // Color will be overridden by components
      );

  static TextStyle get bodyLarge => GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        // Color will be overridden by components
      );

  static TextStyle get bodyMedium => GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        // Color will be overridden by components
      );

  static TextStyle get bodySmall => GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        // Color will be overridden by components
      );

  static TextStyle get buttonText => GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color:
            Colors.white, // Button text is usually white on colored backgrounds
      );

  // Legacy static getters for backward compatibility (will be deprecated)
  static TextStyle get h1Legacy => GoogleFonts.urbanist(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      );

  static TextStyle get h2Legacy => GoogleFonts.urbanist(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get h3Legacy => GoogleFonts.urbanist(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );

  static TextStyle get bodyLargeLegacy => GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      );

  static TextStyle get bodyMediumLegacy => GoogleFonts.urbanist(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: Colors.white,
      );

  static TextStyle get bodySmallLegacy => GoogleFonts.urbanist(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.grey,
      );

  static TextStyle get buttonTextLegacy => GoogleFonts.urbanist(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      );
}
