import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Konfigurasi untuk sliding window PPG
const int kPPGWindowSize = 300;

/// State untuk data PPG (Photoplethysmography)
class PPGState {
  /// Nilai luminance saat ini
  final double currentLuminance;

  /// Mean dari sliding window
  final double mean;

  /// Variance dari sliding window
  final double variance;

  /// Apakah sensor sedang aktif
  final bool isActive;

  /// Apakah kamera sudah diinisialisasi
  final bool isCameraInitialized;

  /// Jumlah sampel yang sudah dikumpulkan
  final int sampleCount;

  /// Status error jika ada
  final String? errorMessage;

  /// Apakah jari terdeteksi menutupi kamera
  final bool isFingerDetected;

  /// Heart rate estimation (opsional)
  final double? estimatedHeartRate;

  const PPGState({
    required this.currentLuminance,
    required this.mean,
    required this.variance,
    required this.isActive,
    required this.isCameraInitialized,
    required this.sampleCount,
    this.errorMessage,
    required this.isFingerDetected,
    this.estimatedHeartRate,
  });

  factory PPGState.initial() {
    return const PPGState(
      currentLuminance: 0.0,
      mean: 0.0,
      variance: 0.0,
      isActive: false,
      isCameraInitialized: false,
      sampleCount: 0,
      errorMessage: null,
      isFingerDetected: false,
      estimatedHeartRate: null,
    );
  }

  PPGState copyWith({
    double? currentLuminance,
    double? mean,
    double? variance,
    bool? isActive,
    bool? isCameraInitialized,
    int? sampleCount,
    String? errorMessage,
    bool clearError = false,
    bool? isFingerDetected,
    double? estimatedHeartRate,
  }) {
    return PPGState(
      currentLuminance: currentLuminance ?? this.currentLuminance,
      mean: mean ?? this.mean,
      variance: variance ?? this.variance,
      isActive: isActive ?? this.isActive,
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      sampleCount: sampleCount ?? this.sampleCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isFingerDetected: isFingerDetected ?? this.isFingerDetected,
      estimatedHeartRate: estimatedHeartRate ?? this.estimatedHeartRate,
    );
  }

  /// Apakah sudah memiliki cukup data untuk analisis
  bool get hasEnoughData => sampleCount >= kPPGWindowSize;

  /// Persentase pengumpulan data
  double get collectionProgress => math.min(sampleCount / kPPGWindowSize, 1.0);

  /// Status siap untuk pengukuran
  bool get isReady => isCameraInitialized && isFingerDetected && isActive;
}

/// Notifier untuk mengelola PPG menggunakan kamera
class PPGNotifier extends Notifier<PPGState> {
  CameraController? _cameraController;
  final List<double> _luminanceBuffer = [];
  Timer? _processingTimer;
  bool _isProcessing = false;

  @override
  PPGState build() {
    ref.onDispose(() {
      stopMeasurement();
      _disposeCamera();
    });
    return PPGState.initial();
  }

  /// Inisialisasi kamera
  Future<void> initializeCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        state = state.copyWith(errorMessage: 'Tidak ada kamera yang tersedia');
        return;
      }

      // Gunakan kamera belakang untuk PPG
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.low, // Low resolution untuk performa
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      // Nyalakan flash untuk PPG yang lebih akurat
      await _cameraController!.setFlashMode(FlashMode.torch);

      state = state.copyWith(isCameraInitialized: true, clearError: true);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Gagal inisialisasi kamera: $e');
    }
  }

  /// Mulai pengukuran PPG
  Future<void> startMeasurement() async {
    if (!state.isCameraInitialized) {
      await initializeCamera();
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      state = state.copyWith(errorMessage: 'Kamera belum siap');
      return;
    }

    _luminanceBuffer.clear();
    state = state.copyWith(isActive: true, sampleCount: 0, clearError: true);

    // Mulai streaming gambar
    await _cameraController!.startImageStream(_processImage);
  }

  /// Berhenti mengukur
  Future<void> stopMeasurement() async {
    _processingTimer?.cancel();
    _processingTimer = null;

    if (_cameraController != null &&
        _cameraController!.value.isStreamingImages) {
      await _cameraController!.stopImageStream();
    }

    state = state.copyWith(isActive: false);
  }

  /// Reset semua data
  Future<void> reset() async {
    await stopMeasurement();
    _luminanceBuffer.clear();
    state = PPGState.initial().copyWith(
      isCameraInitialized: state.isCameraInitialized,
    );
  }

  /// Dispose kamera
  Future<void> _disposeCamera() async {
    if (_cameraController != null) {
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      await _cameraController!.setFlashMode(FlashMode.off);
      await _cameraController!.dispose();
      _cameraController = null;
    }
  }

  /// Proses frame gambar untuk ekstraksi luminance
  void _processImage(CameraImage image) {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      // Ekstrak luminance (Y) dari frame YUV420
      final luminance = _extractLuminance(image);

      // Deteksi apakah jari menutupi kamera
      // Jari yang menutupi kamera akan menghasilkan nilai merah tinggi
      final isFingerDetected = _detectFinger(luminance);

      // Tambahkan ke buffer jika jari terdeteksi
      if (isFingerDetected) {
        _luminanceBuffer.add(luminance);

        // Jaga ukuran buffer
        if (_luminanceBuffer.length > kPPGWindowSize) {
          _luminanceBuffer.removeAt(0);
        }
      }

      // Hitung statistik
      final stats = _calculateStatistics(_luminanceBuffer);

      state = state.copyWith(
        currentLuminance: luminance,
        mean: stats.mean,
        variance: stats.variance,
        sampleCount: _luminanceBuffer.length,
        isFingerDetected: isFingerDetected,
      );
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  /// Ekstrak nilai luminance rata-rata dari frame
  double _extractLuminance(CameraImage image) {
    // Untuk format YUV420, plane pertama adalah Y (luminance)
    final yPlane = image.planes[0];
    final bytes = yPlane.bytes;

    // Hitung rata-rata luminance dari center region
    // untuk mengurangi noise dari tepi
    final width = image.width;
    final height = image.height;

    final centerX = width ~/ 2;
    final centerY = height ~/ 2;
    final regionSize = math.min(width, height) ~/ 4;

    double sum = 0;
    int count = 0;

    for (int y = centerY - regionSize; y < centerY + regionSize; y++) {
      for (int x = centerX - regionSize; x < centerX + regionSize; x++) {
        if (y >= 0 && y < height && x >= 0 && x < width) {
          final index = y * yPlane.bytesPerRow + x;
          if (index < bytes.length) {
            sum += bytes[index];
            count++;
          }
        }
      }
    }

    return count > 0 ? sum / count : 0;
  }

  /// Deteksi apakah jari menutupi kamera
  /// Jari yang diterangi flash akan menghasilkan luminance tinggi dan merah
  bool _detectFinger(double luminance) {
    // Threshold: luminance tinggi menandakan jari menutupi kamera
    // dan flash menerangi jaringan jari
    return luminance > 50 && luminance < 250;
  }

  /// Hitung mean dan variance dari list nilai
  _PPGStatistics _calculateStatistics(List<double> values) {
    if (values.isEmpty) {
      return const _PPGStatistics(mean: 0.0, variance: 0.0);
    }

    final sum = values.reduce((a, b) => a + b);
    final mean = sum / values.length;

    if (values.length < 2) {
      return _PPGStatistics(mean: mean, variance: 0.0);
    }

    final squaredDiffs = values.map((v) => math.pow(v - mean, 2));
    final sumSquaredDiffs = squaredDiffs.reduce((a, b) => a + b);
    final variance = sumSquaredDiffs / (values.length - 1);

    return _PPGStatistics(mean: mean, variance: variance);
  }

  /// Getter untuk camera controller (untuk preview di UI)
  CameraController? get cameraController => _cameraController;
}

/// Helper class untuk statistik PPG
class _PPGStatistics {
  final double mean;
  final double variance;

  const _PPGStatistics({required this.mean, required this.variance});
}

/// Provider untuk PPG sensor
final ppgProvider = NotifierProvider<PPGNotifier, PPGState>(PPGNotifier.new);

/// Provider untuk mendapatkan CameraController
final ppgCameraControllerProvider = Provider<CameraController?>((ref) {
  final notifier = ref.watch(ppgProvider.notifier);
  return notifier.cameraController;
});
