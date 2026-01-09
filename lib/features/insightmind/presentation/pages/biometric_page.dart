import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_prediction_provider.dart';
import '../providers/ppg_provider.dart';
import '../providers/sensors_provider.dart';

/// Halaman untuk menampilkan dan mengumpulkan data biometrik
/// dari sensor accelerometer dan PPG (kamera)
class BiometricPage extends ConsumerStatefulWidget {
  const BiometricPage({super.key});

  @override
  ConsumerState<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends ConsumerState<BiometricPage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Hentikan sensor saat app di-background
    if (state == AppLifecycleState.paused) {
      ref.read(accelerometerProvider.notifier).stopListening();
      ref.read(ppgProvider.notifier).stopMeasurement();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometrik'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header info
            Card(
              color: theme.colorScheme.primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Data biometrik membantu AI menganalisis kondisi Anda dengan lebih akurat.',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Accelerometer Section
            const _AccelerometerSection(),
            const SizedBox(height: 16),

            // PPG Section
            const _PPGSection(),
            const SizedBox(height: 24),

            // Data Completeness Status
            const _DataCompletenessCard(),
            const SizedBox(height: 16),

            // Save Data Button
            _SaveDataButton(onPressed: () => _saveDataToAI(context)),
          ],
        ),
      ),
    );
  }

  void _saveDataToAI(BuildContext context) {
    final accelerometerState = ref.read(accelerometerProvider);
    final ppgState = ref.read(ppgProvider);

    // Update activity data provider
    ref
        .read(activityDataProvider.notifier)
        .updateData(
          mean: accelerometerState.mean,
          variance: accelerometerState.variance,
        );

    // Update PPG data provider
    ref
        .read(ppgDataProvider.notifier)
        .updateData(mean: ppgState.mean, variance: ppgState.variance);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data biometrik berhasil disimpan untuk analisis AI'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Panduan Pengukuran'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Accelerometer:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Letakkan ponsel di permukaan datar\n'
                '• Atau pegang ponsel dengan stabil\n'
                '• Data akan mengukur tingkat aktivitas/kegelisahan',
              ),
              SizedBox(height: 16),
              Text(
                'PPG (Kamera):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '• Tutup kamera belakang dengan jari telunjuk\n'
                '• Pastikan jari menutupi seluruh lensa\n'
                '• Flash akan menyala untuk pengukuran\n'
                '• Tahan posisi selama 30 detik',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }
}

/// Section untuk Accelerometer
class _AccelerometerSection extends ConsumerWidget {
  const _AccelerometerSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accelerometerProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: state.isActive ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'Accelerometer',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _StatusChip(isActive: state.isActive),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            if (state.isActive) ...[
              LinearProgressIndicator(
                value: state.collectionProgress,
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(height: 8),
              Text(
                '${state.sampleCount} / 50 sampel',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],

            // Raw values
            _DataRow(
              label: 'X',
              value: state.x.toStringAsFixed(2),
              unit: 'm/s²',
            ),
            _DataRow(
              label: 'Y',
              value: state.y.toStringAsFixed(2),
              unit: 'm/s²',
            ),
            _DataRow(
              label: 'Z',
              value: state.z.toStringAsFixed(2),
              unit: 'm/s²',
            ),
            const Divider(),
            _DataRow(
              label: 'Magnitude',
              value: state.currentMagnitude.toStringAsFixed(4),
              unit: 'm/s²',
              isHighlighted: true,
            ),
            _DataRow(
              label: 'Mean',
              value: state.mean.toStringAsFixed(4),
              unit: 'm/s²',
              isHighlighted: true,
            ),
            _DataRow(
              label: 'Variance',
              value: state.variance.toStringAsFixed(6),
              unit: '',
              isHighlighted: true,
            ),
            const SizedBox(height: 16),

            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isActive
                        ? null
                        : () {
                            ref
                                .read(accelerometerProvider.notifier)
                                .startListening();
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isActive
                        ? () {
                            ref
                                .read(accelerometerProvider.notifier)
                                .stopListening();
                          }
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref.read(accelerometerProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Section untuk PPG
class _PPGSection extends ConsumerWidget {
  const _PPGSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ppgProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite,
                  color: state.isActive ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 8),
                Text(
                  'PPG (Photoplethysmography)',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _StatusChip(isActive: state.isActive),
              ],
            ),
            const SizedBox(height: 16),

            // Error message
            if (state.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Camera preview (small)
            if (state.isCameraInitialized && state.isActive) ...[
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    height: 120,
                    width: 120,
                    child: Consumer(
                      builder: (context, ref, child) {
                        final controller = ref.watch(
                          ppgCameraControllerProvider,
                        );
                        if (controller != null &&
                            controller.value.isInitialized) {
                          return CameraPreview(controller);
                        }
                        return const Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Finger detection status
            if (state.isActive) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: state.isFingerDetected
                      ? Colors.green[50]
                      : Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      state.isFingerDetected
                          ? Icons.check_circle
                          : Icons.warning,
                      color: state.isFingerDetected
                          ? Colors.green
                          : Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.isFingerDetected
                          ? 'Jari terdeteksi'
                          : 'Letakkan jari di kamera',
                      style: TextStyle(
                        color: state.isFingerDetected
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Progress bar
            if (state.isActive) ...[
              LinearProgressIndicator(
                value: state.collectionProgress,
                backgroundColor: Colors.grey[300],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.sampleCount} / 300 sampel',
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
            ],

            // Data values
            _DataRow(
              label: 'Luminance',
              value: state.currentLuminance.toStringAsFixed(2),
              unit: '',
            ),
            _DataRow(
              label: 'Mean',
              value: state.mean.toStringAsFixed(4),
              unit: '',
              isHighlighted: true,
            ),
            _DataRow(
              label: 'Variance',
              value: state.variance.toStringAsFixed(6),
              unit: '',
              isHighlighted: true,
            ),
            const SizedBox(height: 16),

            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state.isActive
                        ? null
                        : () async {
                            await ref
                                .read(ppgProvider.notifier)
                                .startMeasurement();
                          },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Mulai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[400],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: state.isActive
                        ? () {
                            ref.read(ppgProvider.notifier).stopMeasurement();
                          }
                        : null,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    ref.read(ppgProvider.notifier).reset();
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Card untuk menampilkan status kelengkapan data
class _DataCompletenessCard extends ConsumerWidget {
  const _DataCompletenessCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completeness = ref.watch(dataCompletenessProvider);
    final theme = Theme.of(context);

    return Card(
      color: completeness.isComplete
          ? Colors.green[50]
          : theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  completeness.isComplete ? Icons.check_circle : Icons.pending,
                  color: completeness.isComplete ? Colors.green : Colors.orange,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status Data',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: completeness.completenessPercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                completeness.isComplete ? Colors.green : Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${(completeness.completenessPercentage * 100).toStringAsFixed(0)}% lengkap',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            _ChecklistItem(
              label: 'Data Screening',
              isComplete: completeness.hasScreeningData,
            ),
            _ChecklistItem(
              label: 'Data Aktivitas (Accelerometer)',
              isComplete: completeness.hasActivityData,
            ),
            _ChecklistItem(
              label: 'Data PPG (Kamera)',
              isComplete: completeness.hasPPGData,
            ),
            const SizedBox(height: 8),
            Text(
              completeness.statusDescription,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol untuk menyimpan data ke AI
class _SaveDataButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SaveDataButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.save),
      label: const Text('Simpan Data untuk Analisis AI'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }
}

/// Widget untuk menampilkan row data
class _DataRow extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final bool isHighlighted;

  const _DataRow({
    required this.label,
    required this.value,
    required this.unit,
    this.isHighlighted = false,
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
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '$value $unit',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: 'monospace',
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
              color: isHighlighted ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Chip untuk menampilkan status aktif/tidak aktif
class _StatusChip extends StatelessWidget {
  final bool isActive;

  const _StatusChip({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.green[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'Aktif' : 'Tidak Aktif',
        style: TextStyle(
          fontSize: 12,
          color: isActive ? Colors.green[800] : Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Widget untuk checklist item
class _ChecklistItem extends StatelessWidget {
  final String label;
  final bool isComplete;

  const _ChecklistItem({required this.label, required this.isComplete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 16,
            color: isComplete ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isComplete ? Colors.black : Colors.grey,
              decoration: isComplete ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }
}
