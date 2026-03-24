import 'package:flutter/material.dart';

class AppColors {
  static const primaryOrange = Color(0xFFF13A28);
  static const yellowAccent = Color(0xFFFFDE4D);
  static const creamBackground = Color(0xFFFFF9E8);
  static const darkText = Color(0xFF2A160D);
  static const brownAccent = Color(0xFFB63A1E);
  static const white = Color(0xFFFFFFFF);
  static const cardSurface = Color(0xFFFFFDF4);
  static const peachSurface = Color(0xFFFFEFB3);
  static const mutedText = Color(0xFF8F654B);
  static const success = Color(0xFF2E8B57);
  static const danger = Color(0xFFC44D34);
  static const shadow = Color(0x221C0D05);
}

class AppTheme {
  static ThemeData get theme {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryOrange,
        primary: AppColors.primaryOrange,
        secondary: AppColors.yellowAccent,
        surface: AppColors.creamBackground,
        onPrimary: AppColors.white,
        onSecondary: AppColors.darkText,
        onSurface: AppColors.darkText,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.creamBackground,
      fontFamily: 'sans-serif',
    );

    return base.copyWith(
      textTheme: base.textTheme.copyWith(
        displaySmall: const TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
          height: 1.05,
        ),
        headlineLarge: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w800,
          color: AppColors.darkText,
        ),
        titleLarge: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        titleMedium: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.darkText,
        ),
        bodyLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.darkText,
          height: 1.4,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.mutedText,
          height: 1.5,
        ),
        labelLarge: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.darkText,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        hintStyle: const TextStyle(
          color: AppColors.mutedText,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: AppColors.primaryOrange,
            width: 1.4,
          ),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }

  static List<BoxShadow> get softShadow => const [
    BoxShadow(color: AppColors.shadow, blurRadius: 24, offset: Offset(0, 12)),
  ];
}
