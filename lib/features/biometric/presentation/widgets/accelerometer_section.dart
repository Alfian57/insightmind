import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/biometric_providers.dart';

/// Widget section untuk accelerometer dengan UI modern
class AccelerometerSection extends ConsumerWidget {
  const AccelerometerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accelerometerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (state.isActive
                          ? AppColors.primary
                          : theme.colorScheme.surfaceContainerHighest)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.directions_walk,
                  color: state.isActive
                      ? AppColors.primary
                      : theme.hintColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Accelerometer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pengukuran aktivitas gerakan',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusBadge(isActive: state.isActive),
            ],
          ),
          const SizedBox(height: 20),

          // Progress indicator when active
          if (state.isActive) ...[
            _CollectionProgress(
              progress: state.collectionProgress,
              sampleCount: state.sampleCount,
              maxSamples: kAccelerometerWindowSize,
            ),
            const SizedBox(height: 20),
          ],

          // Raw Values Card
          _DataCard(
            title: 'Nilai Raw',
            children: [
              _DataRow(label: 'X', value: state.x.toStringAsFixed(4)),
              _DataRow(label: 'Y', value: state.y.toStringAsFixed(4)),
              _DataRow(label: 'Z', value: state.z.toStringAsFixed(4)),
            ],
          ),
          const SizedBox(height: 12),

          // Computed Values Card
          _DataCard(
            title: 'Nilai Analisis',
            highlight: state.hasEnoughData,
            children: [
              _DataRow(
                label: 'Magnitude',
                value: '${state.currentMagnitude.toStringAsFixed(4)} m/s²',
                highlight: true,
              ),
              _DataRow(
                label: 'Mean',
                value: state.mean.toStringAsFixed(4),
                highlight: true,
              ),
              _DataRow(
                label: 'Variance',
                value: state.variance.toStringAsFixed(6),
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Control Buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Mulai',
                  icon: Icons.play_arrow,
                  isPrimary: true,
                  onPressed: state.isActive
                      ? null
                      : () => ref
                          .read(accelerometerProvider.notifier)
                          .startListening(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Stop',
                  icon: Icons.stop,
                  isPrimary: false,
                  onPressed: state.isActive
                      ? () => ref
                          .read(accelerometerProvider.notifier)
                          .stopListening()
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              _IconActionButton(
                icon: Icons.refresh,
                onPressed: () =>
                    ref.read(accelerometerProvider.notifier).reset(),
              ),
            ],
          ),

          // Save Data Button
          if (state.hasEnoughData) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: () {
                  ref.read(activityDataProvider.notifier).updateData(
                        mean: state.mean,
                        variance: state.variance,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data aktivitas berhasil disimpan'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data Aktivitas'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Progress collection widget
class _CollectionProgress extends StatelessWidget {
  final double progress;
  final int sampleCount;
  final int maxSamples;

  const _CollectionProgress({
    required this.progress,
    required this.sampleCount,
    required this.maxSamples,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isComplete = progress >= 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mengumpulkan data...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
              ),
            ),
            Text(
              '$sampleCount / $maxSamples',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isComplete ? AppColors.success : theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 6,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(
              isComplete ? AppColors.success : theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Data card container
class _DataCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool highlight;

  const _DataCard({
    required this.title,
    required this.children,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlight
            ? theme.colorScheme.primaryContainer.withOpacity(0.2)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(
                color: theme.colorScheme.primary.withOpacity(0.3),
              )
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: highlight ? theme.colorScheme.primary : theme.hintColor,
            ),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

/// Single data row
class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _DataRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: highlight ? FontWeight.w600 : FontWeight.normal,
              color: highlight ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Status badge widget
class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? AppColors.success : Colors.grey).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? AppColors.success : Colors.grey,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.success : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Action button
class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      );
    }
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

/// Icon only action button
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _IconActionButton({
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
    );
  }
}
