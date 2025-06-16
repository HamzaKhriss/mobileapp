import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/colors.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark);

  void toggleTheme() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setTheme(ThemeMode mode) {
    state = mode;
  }

  bool get isDark => state == ThemeMode.dark;
}

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class AppThemes {
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.kBrandDark,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.kAccentMint,
          secondary: AppColors.kAccentMint,
          surface: AppColors.kBrandDark,
          error: AppColors.kAlertRed,
        ),
        textTheme: GoogleFonts.urbanistTextTheme(ThemeData.dark().textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.kBrandDark,
          elevation: 0,
          titleTextStyle: GoogleFonts.urbanist(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.kBrandDark,
          selectedItemColor: AppColors.kAccentMint,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
        ),
        cardTheme:
            const CardThemeData(color: AppColors.kCardDark, elevation: 2),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.kBrandLight,
        colorScheme: const ColorScheme.light(
          primary: AppColors.kAccentMint,
          secondary: AppColors.kAccentMint,
          surface: AppColors.kSurfaceLight,
          error: AppColors.kAlertRed,
          onSurface: AppColors.kTextLight,
          background: AppColors.kBrandLight,
        ),
        textTheme: GoogleFonts.urbanistTextTheme(
          ThemeData.light().textTheme,
        ).copyWith(
          bodyLarge: GoogleFonts.urbanist(
            color: AppColors.kTextLight,
            fontWeight: FontWeight.w500,
          ),
          bodyMedium: GoogleFonts.urbanist(
            color: AppColors.kTextLight,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: GoogleFonts.urbanist(
            color: AppColors.kTextSecondaryLight,
            fontWeight: FontWeight.w400,
          ),
          headlineLarge: GoogleFonts.urbanist(
            color: AppColors.kTextLight,
            fontWeight: FontWeight.bold,
          ),
          headlineMedium: GoogleFonts.urbanist(
            color: AppColors.kTextLight,
            fontWeight: FontWeight.w600,
          ),
          headlineSmall: GoogleFonts.urbanist(
            color: AppColors.kTextLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.kSurfaceLight,
          elevation: 0,
          titleTextStyle: GoogleFonts.urbanist(
            color: AppColors.kTextLight,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: const IconThemeData(color: AppColors.kTextLight),
          surfaceTintColor: Colors.transparent,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.kSurfaceLight,
          selectedItemColor: AppColors.kAccentMint,
          unselectedItemColor: AppColors.kTextSecondaryLight,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        cardTheme: CardThemeData(
          color: AppColors.kCardLight,
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppColors.kBorderLight, width: 1),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.kSurfaceLight,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.kBorderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.kBorderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.kAccentMint, width: 2),
          ),
          hintStyle: const TextStyle(color: AppColors.kTextSecondaryLight),
        ),
      );
}
