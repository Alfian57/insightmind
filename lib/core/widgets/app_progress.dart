import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Animated progress indicator
class AppProgressIndicator extends StatelessWidget {
  final double value;
  final double height;
  final Color? backgroundColor;
  final Color? progressColor;
  final List<Color>? gradientColors;
  final bool showPercentage;
  final BorderRadius? borderRadius;

  const AppProgressIndicator({
    super.key,
    required this.value,
    this.height = 8,
    this.backgroundColor,
    this.progressColor,
    this.gradientColors,
    this.showPercentage = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = borderRadius ?? BorderRadius.circular(height / 2);
    final clampedValue = value.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showPercentage) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(clampedValue * 100).toInt()}%',
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Container(
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.colorScheme.outlineVariant,
            borderRadius: radius,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    width: constraints.maxWidth * clampedValue,
                    decoration: BoxDecoration(
                      color: gradientColors == null ? progressColor : null,
                      gradient: gradientColors != null
                          ? LinearGradient(colors: gradientColors!)
                          : (progressColor == null
                              ? LinearGradient(colors: AppColors.primaryGradient)
                              : null),
                      borderRadius: radius,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Circular progress with label
class AppCircularProgress extends StatelessWidget {
  final double value;
  final double size;
  final double strokeWidth;
  final Color? backgroundColor;
  final Color? progressColor;
  final Widget? child;

  const AppCircularProgress({
    super.key,
    required this.value,
    this.size = 80,
    this.strokeWidth = 8,
    this.backgroundColor,
    this.progressColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: value.clamp(0.0, 1.0),
            strokeWidth: strokeWidth,
            backgroundColor:
                backgroundColor ?? theme.colorScheme.outlineVariant,
            color: progressColor ?? theme.colorScheme.primary,
            strokeCap: StrokeCap.round,
          ),
          if (child != null) Center(child: child),
        ],
      ),
    );
  }
}

/// Step indicator for multi-step flows
class AppStepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final List<String>? labels;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? completedColor;

  const AppStepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.labels,
    this.activeColor,
    this.inactiveColor,
    this.completedColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = activeColor ?? theme.colorScheme.primary;
    final inactive = inactiveColor ?? theme.colorScheme.outlineVariant;
    final completed = completedColor ?? AppColors.success;

    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        if (index.isOdd) {
          // Connector line
          final stepIndex = index ~/ 2;
          return Expanded(
            child: Container(
              height: 2,
              color: stepIndex < currentStep ? completed : inactive,
            ),
          );
        }

        // Step circle
        final stepIndex = index ~/ 2;
        final isCompleted = stepIndex < currentStep;
        final isActive = stepIndex == currentStep;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? completed
                : isActive
                    ? active
                    : Colors.transparent,
            border: Border.all(
              color: isCompleted
                  ? completed
                  : isActive
                      ? active
                      : inactive,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : Text(
                    '${stepIndex + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}
