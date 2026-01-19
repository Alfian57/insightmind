import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget for displaying a single answer option
class AnswerOptionCard extends StatelessWidget {
  final String label;
  final int score;
  final bool isSelected;
  final VoidCallback onTap;
  final Animation<double>? animation;
  final int index;

  const AnswerOptionCard({
    super.key,
    required this.label,
    required this.score,
    required this.isSelected,
    required this.onTap,
    this.animation,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.outlineVariant,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Radio indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                // Score indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getScoreColor(score).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score',
                    style: TextStyle(
                      color: _getScoreColor(score),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (animation != null) {
      final delay = index * 0.1;
      final start = delay.clamp(0.0, 0.6);
      final end = (delay + 0.4).clamp(0.0, 1.0);

      final curvedAnimation = CurvedAnimation(
        parent: animation!,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );

      content = FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.2, 0),
            end: Offset.zero,
          ).animate(curvedAnimation),
          child: content,
        ),
      );
    }

    return content;
  }

  Color _getScoreColor(int score) {
    switch (score) {
      case 0:
        return AppColors.success;
      case 1:
        return AppColors.info;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }
}
