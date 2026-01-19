import 'package:flutter/material.dart';

/// App color palette with light and dark mode support
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF4F46E5);

  static const Color secondary = Color(0xFF06B6D4); // Cyan
  static const Color secondaryLight = Color(0xFF22D3EE);
  static const Color secondaryDark = Color(0xFF0891B2);

  static const Color tertiary = Color(0xFF8B5CF6); // Violet
  static const Color tertiaryLight = Color(0xFFA78BFA);
  static const Color tertiaryDark = Color(0xFF7C3AED);

  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color successDark = Color(0xFF059669);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color warningDark = Color(0xFFD97706);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color errorDark = Color(0xFFDC2626);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  static const Color infoDark = Color(0xFF2563EB);

  // Light Mode Colors
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  static const Color dividerLight = Color(0xFFE2E8F0);
  static const Color borderLight = Color(0xFFCBD5E1);

  // Dark Mode Colors
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color cardDark = Color(0xFF334155);
  static const Color textPrimaryDark = Color(0xFFF1F5F9);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textTertiaryDark = Color(0xFF64748B);
  static const Color dividerDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF475569);

  // Risk Level Colors
  static const Color riskLow = success;
  static const Color riskMedium = warning;
  static const Color riskHigh = error;

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFF8B5CF6),
  ];

  static const List<Color> darkPrimaryGradient = [
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
  ];

  static const List<Color> successGradient = [
    Color(0xFF10B981),
    Color(0xFF06B6D4),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  // Mood Colors
  static const Color moodExcellent = Color(0xFF10B981);
  static const Color moodGood = Color(0xFF06B6D4);
  static const Color moodNeutral = Color(0xFFF59E0B);
  static const Color moodBad = Color(0xFFF97316);
  static const Color moodTerrible = Color(0xFFEF4444);
}
