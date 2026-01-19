import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../providers/biometric_providers.dart';

/// Widget section untuk PPG (Photoplethysmography) dengan UI modern
class PPGSection extends ConsumerWidget {
  const PPGSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ppgProvider);
    final theme = Theme.of(context);

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
                          ? AppColors.error
                          : theme.colorScheme.surfaceContainerHighest)
                      .withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: state.isActive ? AppColors.error : theme.hintColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PPG (Photoplethysmography)',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Pengukuran via kamera',
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

          // Error message
          if (state.errorMessage != null) ...[
            _ErrorBanner(message: state.errorMessage!),
            const SizedBox(height: 16),
          ],

          // Camera preview and finger detection
          if (state.isCameraInitialized && state.isActive) ...[
            _CameraPreviewSection(state: state),
            const SizedBox(height: 16),
          ],

          // Finger detection status
          if (state.isActive) ...[
            _FingerDetectionBanner(isDetected: state.isFingerDetected),
            const SizedBox(height: 16),
            _CollectionProgress(
              progress: state.collectionProgress,
              sampleCount: state.sampleCount,
              maxSamples: kPPGWindowSize,
            ),
            const SizedBox(height: 20),
          ],

          // Data Values
          _DataCard(
            title: 'Nilai Analisis',
            highlight: state.hasEnoughData,
            children: [
              _DataRow(
                label: 'Luminance',
                value: state.currentLuminance.toStringAsFixed(2),
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
                  color: AppColors.error,
                  onPressed: state.isActive
                      ? null
                      : () => ref.read(ppgProvider.notifier).startMeasurement(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Stop',
                  icon: Icons.stop,
                  isPrimary: false,
                  onPressed: state.isActive
                      ? () => ref.read(ppgProvider.notifier).stopMeasurement()
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              _IconActionButton(
                icon: Icons.refresh,
                onPressed: () => ref.read(ppgProvider.notifier).reset(),
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
                  ref.read(ppgDataProvider.notifier).updateData(
                        mean: state.mean,
                        variance: state.variance,
                      );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data PPG berhasil disimpan'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.save),
                label: const Text('Simpan Data PPG'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error.withOpacity(0.15),
                  foregroundColor: AppColors.error,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Camera preview section
class _CameraPreviewSection extends ConsumerWidget {
  final PPGState state;

  const _CameraPreviewSection({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ppgCameraControllerProvider);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state.isFingerDetected
                ? AppColors.success
                : AppColors.warning,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: (state.isFingerDetected
                      ? AppColors.success
                      : AppColors.warning)
                  .withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            height: 120,
            width: 120,
            child: controller != null && controller.value.isInitialized
                ? CameraPreview(controller)
                : const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

/// Finger detection status banner
class _FingerDetectionBanner extends StatelessWidget {
  final bool isDetected;

  const _FingerDetectionBanner({required this.isDetected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDetected ? AppColors.success : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isDetected ? Icons.check_circle : Icons.warning_amber,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            isDetected ? 'Jari terdeteksi' : 'Letakkan jari di kamera',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Error banner
class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
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
                color: isComplete ? AppColors.success : AppColors.error,
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
              isComplete ? AppColors.success : AppColors.error,
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
            ? AppColors.error.withOpacity(0.05)
            : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: highlight
            ? Border.all(color: AppColors.error.withOpacity(0.3))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: highlight ? AppColors.error : theme.hintColor,
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
              color: highlight ? AppColors.error : null,
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
    final color = isActive ? AppColors.error : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
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
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isActive ? 'Aktif' : 'Nonaktif',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
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
  final Color? color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    this.color,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: color != null
            ? FilledButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              )
            : null,
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
