import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/biometric_providers.dart';

/// Card widget untuk menampilkan status kelengkapan data
class DataStatusCard extends ConsumerWidget {
  const DataStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completeness = ref.watch(dataCompletenessProvider);
    final theme = Theme.of(context);

    return AppCard(
      backgroundColor: completeness.isComplete
          ? AppColors.success.withOpacity(0.05)
          : null,
      borderColor: completeness.isComplete
          ? AppColors.success.withOpacity(0.3)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (completeness.isComplete
                          ? AppColors.success
                          : AppColors.warning)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  completeness.isComplete
                      ? Icons.check_circle
                      : Icons.pending_actions,
                  color: completeness.isComplete
                      ? AppColors.success
                      : AppColors.warning,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Data',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      completeness.isComplete
                          ? 'Semua data lengkap'
                          : 'Data belum lengkap',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: completeness.isComplete
                            ? AppColors.success
                            : AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
              // Percentage badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: (completeness.isComplete
                          ? AppColors.success
                          : theme.colorScheme.primary)
                      .withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(completeness.completenessPercentage * 100).toStringAsFixed(0)}%',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: completeness.isComplete
                        ? AppColors.success
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: completeness.completenessPercentage,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation(
                completeness.isComplete
                    ? AppColors.success
                    : theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Checklist items
          _ChecklistItem(
            label: 'Data Screening',
            description: 'Jawaban kuesioner DASS-21',
            isComplete: completeness.hasScreeningData,
          ),
          const SizedBox(height: 10),
          _ChecklistItem(
            label: 'Data Aktivitas',
            description: 'Pengukuran accelerometer',
            isComplete: completeness.hasActivityData,
          ),
          const SizedBox(height: 10),
          _ChecklistItem(
            label: 'Data PPG',
            description: 'Pengukuran via kamera',
            isComplete: completeness.hasPPGData,
          ),
          const SizedBox(height: 16),

          // Status message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: theme.hintColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    completeness.statusDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Checklist item widget
class _ChecklistItem extends StatelessWidget {
  final String label;
  final String description;
  final bool isComplete;

  const _ChecklistItem({
    required this.label,
    required this.description,
    required this.isComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete
            ? AppColors.success.withOpacity(0.05)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isComplete
              ? AppColors.success.withOpacity(0.3)
              : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isComplete
                  ? AppColors.success
                  : theme.colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              isComplete ? Icons.check : Icons.radio_button_unchecked,
              size: 16,
              color: isComplete ? Colors.white : theme.hintColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isComplete ? AppColors.success : null,
                    decoration: isComplete ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ],
            ),
          ),
          if (isComplete)
            const Icon(
              Icons.verified,
              color: AppColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }
}
