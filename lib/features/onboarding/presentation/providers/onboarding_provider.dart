import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/constants/app_constants.dart';

/// Provider for onboarding completion status
final onboardingCompletedProvider =
    NotifierProvider<OnboardingNotifier, bool>(OnboardingNotifier.new);

class OnboardingNotifier extends Notifier<bool> {
  @override
  bool build() {
    _loadStatus();
    return false;
  }

  Future<void> _loadStatus() async {
    final box = await Hive.openBox('app_settings');
    state = box.get(AppConstants.onboardingKey, defaultValue: false);
  }

  Future<void> completeOnboarding() async {
    final box = await Hive.openBox('app_settings');
    await box.put(AppConstants.onboardingKey, true);
    state = true;
  }

  Future<void> resetOnboarding() async {
    final box = await Hive.openBox('app_settings');
    await box.put(AppConstants.onboardingKey, false);
    state = false;
  }
}
