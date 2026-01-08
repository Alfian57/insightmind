import 'dart:math' as math;

import '../entities/feature_vector.dart';
import '../entities/prediction_result.dart';

/// PredictRiskAI - Use Case untuk prediksi risiko kesehatan mental
///
/// Menggunakan rule-based AI on-device untuk menganalisis FeatureVector
/// dan menghasilkan prediksi risiko dengan confidence score.
///
/// Formula Prediksi:
/// Score = (0.6 × screeningScore) + (0.2 × activityVar × 10) + (0.2 × ppgVar × 1000)
///
/// Kategori Risiko:
/// - Tinggi: Score > 25
/// - Sedang: 12 ≤ Score ≤ 25
/// - Rendah: Score < 12
///
/// Confidence Score:
/// clamp(Score / 30, 0.3, 0.95)
class PredictRiskAI {
  /// Bobot untuk masing-masing fitur
  static const double _weightScreening = 0.6;
  static const double _weightActivity = 0.2;
  static const double _weightPPG = 0.2;

  /// Multiplier untuk normalisasi nilai sensor
  static const double _activityMultiplier = 10.0;
  static const double _ppgMultiplier = 1000.0;

  /// Threshold untuk kategori risiko
  static const double _thresholdHigh = 25.0;
  static const double _thresholdMedium = 12.0;

  /// Batas confidence score
  static const double _minConfidence = 0.3;
  static const double _maxConfidence = 0.95;
  static const double _confidenceDivisor = 30.0;

  /// Eksekusi prediksi risiko dari FeatureVector
  ///
  /// [features] - FeatureVector yang berisi data dari screening dan sensor
  ///
  /// Returns [PredictionResult] dengan score, riskLevel, dan confidence
  PredictionResult execute(FeatureVector features) {
    // Hitung skor prediksi menggunakan formula rule-based
    final double score = _calculateScore(features);

    // Tentukan kategori risiko berdasarkan threshold
    final String riskLevel = _determineRiskLevel(score);

    // Hitung confidence score
    final double confidence = _calculateConfidence(score);

    return PredictionResult(
      score: score,
      riskLevel: riskLevel,
      confidence: confidence,
      timestamp: DateTime.now(),
      featureDetails: features.toMap(),
    );
  }

  /// Eksekusi prediksi hanya dengan skor screening (tanpa data sensor)
  ///
  /// Berguna ketika data sensor tidak tersedia
  PredictionResult executeWithScreeningOnly(int screeningScore) {
    final features = FeatureVector(
      screeningScore: screeningScore.toDouble(),
      activityMean: 0.0,
      activityVar: 0.0,
      ppgMean: 0.0,
      ppgVar: 0.0,
    );

    return execute(features);
  }

  /// Hitung skor prediksi dari FeatureVector
  ///
  /// Formula: Score = (0.6 × screeningScore) + (0.2 × activityVar × 10) + (0.2 × ppgVar × 1000)
  double _calculateScore(FeatureVector features) {
    final screeningComponent = _weightScreening * features.screeningScore;
    final activityComponent =
        _weightActivity * features.activityVar * _activityMultiplier;
    final ppgComponent = _weightPPG * features.ppgVar * _ppgMultiplier;

    return screeningComponent + activityComponent + ppgComponent;
  }

  /// Tentukan kategori risiko berdasarkan skor
  ///
  /// - Tinggi: Score > 25
  /// - Sedang: 12 ≤ Score ≤ 25
  /// - Rendah: Score < 12
  String _determineRiskLevel(double score) {
    if (score > _thresholdHigh) {
      return 'Tinggi';
    } else if (score >= _thresholdMedium) {
      return 'Sedang';
    } else {
      return 'Rendah';
    }
  }

  /// Hitung confidence score
  ///
  /// Formula: clamp(Score / 30, 0.3, 0.95)
  ///
  /// Confidence minimal 0.3 (30%) dan maksimal 0.95 (95%)
  double _calculateConfidence(double score) {
    final rawConfidence = score / _confidenceDivisor;
    return _clamp(rawConfidence, _minConfidence, _maxConfidence);
  }

  /// Fungsi clamp untuk membatasi nilai dalam range tertentu
  double _clamp(double value, double min, double max) {
    return math.min(math.max(value, min), max);
  }

  /// Mendapatkan penjelasan detail tentang prediksi
  ///
  /// Berguna untuk debugging atau menampilkan breakdown kepada user
  Map<String, dynamic> getScoreBreakdown(FeatureVector features) {
    final screeningComponent = _weightScreening * features.screeningScore;
    final activityComponent =
        _weightActivity * features.activityVar * _activityMultiplier;
    final ppgComponent = _weightPPG * features.ppgVar * _ppgMultiplier;
    final totalScore = screeningComponent + activityComponent + ppgComponent;

    return {
      'components': {
        'screening': {
          'value': features.screeningScore,
          'weight': _weightScreening,
          'contribution': screeningComponent,
          'percentage': totalScore > 0
              ? (screeningComponent / totalScore * 100).toStringAsFixed(1)
              : '0.0',
        },
        'activity': {
          'variance': features.activityVar,
          'weight': _weightActivity,
          'multiplier': _activityMultiplier,
          'contribution': activityComponent,
          'percentage': totalScore > 0
              ? (activityComponent / totalScore * 100).toStringAsFixed(1)
              : '0.0',
        },
        'ppg': {
          'variance': features.ppgVar,
          'weight': _weightPPG,
          'multiplier': _ppgMultiplier,
          'contribution': ppgComponent,
          'percentage': totalScore > 0
              ? (ppgComponent / totalScore * 100).toStringAsFixed(1)
              : '0.0',
        },
      },
      'totalScore': totalScore,
      'riskLevel': _determineRiskLevel(totalScore),
      'confidence': _calculateConfidence(totalScore),
      'thresholds': {'high': _thresholdHigh, 'medium': _thresholdMedium},
    };
  }

  /// Validasi apakah FeatureVector memiliki data yang cukup untuk prediksi akurat
  ///
  /// Mengembalikan list string berisi peringatan jika ada data yang kurang
  List<String> validateFeatures(FeatureVector features) {
    final warnings = <String>[];

    if (features.screeningScore <= 0) {
      warnings.add('Skor screening belum tersedia. Silakan isi kuesioner.');
    }

    if (features.activityVar <= 0) {
      warnings.add(
        'Data aktivitas belum tersedia. Aktifkan sensor accelerometer.',
      );
    }

    if (features.ppgVar <= 0) {
      warnings.add(
        'Data PPG belum tersedia. Gunakan fitur biometrik untuk mengukur.',
      );
    }

    return warnings;
  }
}
