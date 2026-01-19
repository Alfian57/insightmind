import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_button.dart';
import '../../data/onboarding_data.dart';
import '../providers/onboarding_provider.dart';
import '../widgets/onboarding_dots.dart';
import '../widgets/onboarding_page_content.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final VoidCallback onComplete;

  const OnboardingPage({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _animations;
  int _currentPage = 0;

  final List<OnboardingData> _pages = OnboardingData.pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // Create animation controllers for each page
    _animationControllers = List.generate(
      _pages.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      ),
    );

    _animations = _animationControllers.map((controller) {
      return CurvedAnimation(
        parent: controller,
        curve: Curves.easeOutCubic,
      );
    }).toList();

    // Start first page animation
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int page) {
    // Reset previous page animation
    _animationControllers[_currentPage].reset();

    setState(() {
      _currentPage = page;
    });

    // Start new page animation
    _animationControllers[page].forward();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).completeOnboarding();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLastPage = _currentPage == _pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: isLastPage ? 0 : 1,
                  child: TextButton(
                    onPressed: isLastPage ? null : _skipOnboarding,
                    child: Text(
                      AppStrings.skip,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return OnboardingPageContent(
                    title: page.title,
                    description: page.description,
                    icon: page.icon,
                    gradientColors: page.gradientColors,
                    animation: _animations[index],
                  );
                },
              ),
            ),

            // Bottom section
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Dots indicator
                  OnboardingDots(
                    currentPage: _currentPage,
                    totalPages: _pages.length,
                  ),
                  const SizedBox(height: 32),

                  // Action button
                  AppButton(
                    text: isLastPage
                        ? AppStrings.getStarted
                        : AppStrings.continueText,
                    onPressed: _nextPage,
                    useGradient: isLastPage,
                    icon: isLastPage ? Icons.arrow_forward : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
