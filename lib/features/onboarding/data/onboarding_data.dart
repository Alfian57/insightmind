import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingData {
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;

  const OnboardingData({
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
  });

  static List<OnboardingData> get pages => [
        OnboardingData(
          title: AppStrings.onboardingTitle1,
          description: AppStrings.onboardingDesc1,
          icon: Icons.psychology_outlined,
          gradientColors: [
            AppColors.primary,
            AppColors.tertiary,
          ],
        ),
        OnboardingData(
          title: AppStrings.onboardingTitle2,
          description: AppStrings.onboardingDesc2,
          icon: Icons.quiz_outlined,
          gradientColors: [
            AppColors.secondary,
            AppColors.primary,
          ],
        ),
        OnboardingData(
          title: AppStrings.onboardingTitle3,
          description: AppStrings.onboardingDesc3,
          icon: Icons.sensors_outlined,
          gradientColors: [
            AppColors.tertiary,
            AppColors.error,
          ],
        ),
        OnboardingData(
          title: AppStrings.onboardingTitle4,
          description: AppStrings.onboardingDesc4,
          icon: Icons.security_outlined,
          gradientColors: [
            AppColors.success,
            AppColors.secondary,
          ],
        ),
      ];
}
