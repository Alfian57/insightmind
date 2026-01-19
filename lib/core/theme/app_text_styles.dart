import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App typography system
class AppTextStyles {
  AppTextStyles._();

  static const String _fontFamily = 'Poppins';

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  static const TextStyle displayMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  static const TextStyle displaySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );

  static const TextStyle titleMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.5,
  );

  static const TextStyle titleSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  static const TextStyle bodySmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  static const TextStyle labelMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  static const TextStyle labelSmall = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // Light Mode Text Theme
  static TextTheme get lightTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryLight),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryLight),
        displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryLight),
        headlineLarge: headlineLarge.copyWith(color: AppColors.textPrimaryLight),
        headlineMedium:
            headlineMedium.copyWith(color: AppColors.textPrimaryLight),
        headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryLight),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryLight),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryLight),
        titleSmall: titleSmall.copyWith(color: AppColors.textPrimaryLight),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryLight),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryLight),
        bodySmall: bodySmall.copyWith(color: AppColors.textTertiaryLight),
        labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryLight),
        labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryLight),
        labelSmall: labelSmall.copyWith(color: AppColors.textTertiaryLight),
      );

  // Dark Mode Text Theme
  static TextTheme get darkTextTheme => TextTheme(
        displayLarge: displayLarge.copyWith(color: AppColors.textPrimaryDark),
        displayMedium: displayMedium.copyWith(color: AppColors.textPrimaryDark),
        displaySmall: displaySmall.copyWith(color: AppColors.textPrimaryDark),
        headlineLarge: headlineLarge.copyWith(color: AppColors.textPrimaryDark),
        headlineMedium: headlineMedium.copyWith(color: AppColors.textPrimaryDark),
        headlineSmall: headlineSmall.copyWith(color: AppColors.textPrimaryDark),
        titleLarge: titleLarge.copyWith(color: AppColors.textPrimaryDark),
        titleMedium: titleMedium.copyWith(color: AppColors.textPrimaryDark),
        titleSmall: titleSmall.copyWith(color: AppColors.textPrimaryDark),
        bodyLarge: bodyLarge.copyWith(color: AppColors.textPrimaryDark),
        bodyMedium: bodyMedium.copyWith(color: AppColors.textSecondaryDark),
        bodySmall: bodySmall.copyWith(color: AppColors.textTertiaryDark),
        labelLarge: labelLarge.copyWith(color: AppColors.textPrimaryDark),
        labelMedium: labelMedium.copyWith(color: AppColors.textSecondaryDark),
        labelSmall: labelSmall.copyWith(color: AppColors.textTertiaryDark),
      );
}
