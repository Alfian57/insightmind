import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Konfigurasi untuk sliding window accelerometer
const int kAccelerometerWindowSize = 50;

/// State untuk data sensor accelerometer
class AccelerometerState {
  /// Nilai magnitude saat ini
  final double currentMagnitude;

  /// Mean dari sliding window
  final double mean;

  /// Variance dari sliding window
  final double variance;

  /// Apakah sensor sedang aktif
  final bool isActive;

  /// Jumlah sampel yang sudah dikumpulkan
  final int sampleCount;

  /// Raw accelerometer values
  final double x;
  final double y;
  final double z;

  const AccelerometerState({
    required this.currentMagnitude,
    required this.mean,
    required this.variance,
    required this.isActive,
    required this.sampleCount,
    required this.x,
    required this.y,
    required this.z,
  });

  factory AccelerometerState.initial() {
    return const AccelerometerState(
      currentMagnitude: 0.0,
      mean: 0.0,
      variance: 0.0,
      isActive: false,
      sampleCount: 0,
      x: 0.0,
      y: 0.0,
      z: 0.0,
    );
  }

  AccelerometerState copyWith({
    double? currentMagnitude,
    double? mean,
    double? variance,
    bool? isActive,
    int? sampleCount,
    double? x,
    double? y,
    double? z,
  }) {
    return AccelerometerState(
      currentMagnitude: currentMagnitude ?? this.currentMagnitude,
      mean: mean ?? this.mean,
      variance: variance ?? this.variance,
      isActive: isActive ?? this.isActive,
      sampleCount: sampleCount ?? this.sampleCount,
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  /// Apakah sudah memiliki cukup data untuk analisis
  bool get hasEnoughData => sampleCount >= kAccelerometerWindowSize;

  /// Persentase pengumpulan data
  double get collectionProgress =>
      math.min(sampleCount / kAccelerometerWindowSize, 1.0);
}

/// Notifier untuk mengelola sensor accelerometer dengan sliding window
class AccelerometerNotifier extends Notifier<AccelerometerState> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final List<double> _magnitudeBuffer = [];

  @override
  AccelerometerState build() {
    // Cleanup saat provider di-dispose
    ref.onDispose(() {
      stopListening();
    });
    return AccelerometerState.initial();
  }

  /// Mulai mendengarkan sensor accelerometer
  void startListening() {
    if (state.isActive) return;

    _magnitudeBuffer.clear();
    state = state.copyWith(isActive: true, sampleCount: 0);

    _subscription = accelerometerEventStream(
      samplingPeriod: const Duration(milliseconds: 100), // 10 Hz
    ).listen(_onAccelerometerEvent);
  }

  /// Berhenti mendengarkan sensor
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(isActive: false);
  }

  /// Reset semua data
  void reset() {
    stopListening();
    _magnitudeBuffer.clear();
    state = AccelerometerState.initial();
  }

  /// Handler untuk event accelerometer
  void _onAccelerometerEvent(AccelerometerEvent event) {
    // Hitung magnitude: sqrt(x² + y² + z²)
    final magnitude = math.sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );

    // Tambahkan ke buffer (sliding window)
    _magnitudeBuffer.add(magnitude);

    // Jaga ukuran buffer tidak melebihi window size
    if (_magnitudeBuffer.length > kAccelerometerWindowSize) {
      _magnitudeBuffer.removeAt(0);
    }

    // Hitung mean dan variance dari buffer
    final stats = _calculateStatistics(_magnitudeBuffer);

    state = state.copyWith(
      currentMagnitude: magnitude,
      mean: stats.mean,
      variance: stats.variance,
      sampleCount: _magnitudeBuffer.length,
      x: event.x,
      y: event.y,
      z: event.z,
    );
  }

  /// Hitung mean dan variance dari list nilai
  _Statistics _calculateStatistics(List<double> values) {
    if (values.isEmpty) {
      return const _Statistics(mean: 0.0, variance: 0.0);
    }

    // Hitung mean
    final sum = values.reduce((a, b) => a + b);
    final mean = sum / values.length;

    // Hitung variance
    if (values.length < 2) {
      return _Statistics(mean: mean, variance: 0.0);
    }

    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final sumSquaredDiffs = squaredDiffs.reduce((a, b) => a + b);
    final variance = sumSquaredDiffs / (values.length - 1); // Sample variance

    return _Statistics(mean: mean, variance: variance);
  }
}

/// Helper class untuk menyimpan statistik
class _Statistics {
  final double mean;
  final double variance;

  const _Statistics({required this.mean, required this.variance});
}

/// Provider untuk accelerometer sensor
final accelerometerProvider =
    NotifierProvider<AccelerometerNotifier, AccelerometerState>(
      AccelerometerNotifier.new,
    );

/// Provider untuk gyroscope (opsional, untuk fitur tambahan)
class GyroscopeState {
  final double x;
  final double y;
  final double z;
  final bool isActive;

  const GyroscopeState({
    required this.x,
    required this.y,
    required this.z,
    required this.isActive,
  });

  factory GyroscopeState.initial() {
    return const GyroscopeState(x: 0.0, y: 0.0, z: 0.0, isActive: false);
  }

  GyroscopeState copyWith({double? x, double? y, double? z, bool? isActive}) {
    return GyroscopeState(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
      isActive: isActive ?? this.isActive,
    );
  }
}

class GyroscopeNotifier extends Notifier<GyroscopeState> {
  StreamSubscription<GyroscopeEvent>? _subscription;

  @override
  GyroscopeState build() {
    ref.onDispose(() {
      stopListening();
    });
    return GyroscopeState.initial();
  }

  void startListening() {
    if (state.isActive) return;

    state = state.copyWith(isActive: true);

    _subscription =
        gyroscopeEventStream(
          samplingPeriod: const Duration(milliseconds: 100),
        ).listen((event) {
          state = state.copyWith(x: event.x, y: event.y, z: event.z);
        });
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    state = state.copyWith(isActive: false);
  }
}

final gyroscopeProvider = NotifierProvider<GyroscopeNotifier, GyroscopeState>(
  GyroscopeNotifier.new,
);
