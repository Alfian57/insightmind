/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'InsightMind';
  static const String appVersion = '2.0.0';
  static const String appDescription =
      'Aplikasi kesehatan mental berbasis AI on-device';

  // Storage Keys
  static const String themeKey = 'theme_mode';
  static const String onboardingKey = 'onboarding_completed';
  static const String screeningRecordsBox = 'screening_records';

  // Screening
  static const int totalQuestions = 10;
  static const int minScore = 0;
  static const int maxScore = 30;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Biometric
  static const int ppgSampleCount = 50;
  static const int accelerometerSampleCount = 50;
}
