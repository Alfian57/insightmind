import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/feature_vector.dart';
import '../../domain/entities/prediction_result.dart';
import '../../domain/usecases/predict_risk_ai.dart';
import 'score_provider.dart';

/// Provider untuk use case PredictRiskAI
final predictRiskAIProvider = Provider<PredictRiskAI>((ref) {
  return PredictRiskAI();
});

/// State untuk menyimpan data sensor accelerometer
class ActivityDataNotifier extends Notifier<ActivitySensorData> {
  @override
  ActivitySensorData build() {
    return ActivitySensorData.empty();
  }

  /// Update data dari sensor accelerometer
  void updateData({required double mean, required double variance}) {
    state = ActivitySensorData(mean: mean, variance: variance);
  }

  /// Reset data sensor
  void reset() {
    state = ActivitySensorData.empty();
  }
}

/// Data struktur untuk sensor aktivitas
class ActivitySensorData {
  final double mean;
  final double variance;

  const ActivitySensorData({required this.mean, required this.variance});

  factory ActivitySensorData.empty() {
    return const ActivitySensorData(mean: 0.0, variance: 0.0);
  }

  bool get hasData => mean > 0 || variance > 0;
}

final activityDataProvider =
    NotifierProvider<ActivityDataNotifier, ActivitySensorData>(
      ActivityDataNotifier.new,
    );

/// State untuk menyimpan data sensor PPG
class PPGDataNotifier extends Notifier<PPGSensorData> {
  @override
  PPGSensorData build() {
    return PPGSensorData.empty();
  }

  /// Update data dari sensor PPG
  void updateData({required double mean, required double variance}) {
    state = PPGSensorData(mean: mean, variance: variance);
  }

  /// Reset data sensor
  void reset() {
    state = PPGSensorData.empty();
  }
}

/// Data struktur untuk sensor PPG
class PPGSensorData {
  final double mean;
  final double variance;

  const PPGSensorData({required this.mean, required this.variance});

  factory PPGSensorData.empty() {
    return const PPGSensorData(mean: 0.0, variance: 0.0);
  }

  bool get hasData => mean > 0 || variance > 0;
}

final ppgDataProvider = NotifierProvider<PPGDataNotifier, PPGSensorData>(
  PPGDataNotifier.new,
);

/// Provider untuk FeatureVector gabungan dari semua sumber data
final featureVectorProvider = Provider<FeatureVector>((ref) {
  // Ambil skor screening dari provider yang sudah ada
  final screeningScore = ref.watch(scoreProvider);

  // Ambil data sensor
  final activityData = ref.watch(activityDataProvider);
  final ppgData = ref.watch(ppgDataProvider);

  return FeatureVector(
    screeningScore: screeningScore.toDouble(),
    activityMean: activityData.mean,
    activityVar: activityData.variance,
    ppgMean: ppgData.mean,
    ppgVar: ppgData.variance,
  );
});

/// Provider untuk hasil prediksi AI
final aiPredictionProvider = Provider<PredictionResult>((ref) {
  final features = ref.watch(featureVectorProvider);
  final predictAI = ref.watch(predictRiskAIProvider);

  return predictAI.execute(features);
});

/// Provider untuk mendapatkan breakdown skor (untuk debugging/detail view)
final scoreBreakdownProvider = Provider<Map<String, dynamic>>((ref) {
  final features = ref.watch(featureVectorProvider);
  final predictAI = ref.watch(predictRiskAIProvider);

  return predictAI.getScoreBreakdown(features);
});

/// Provider untuk validasi fitur (warnings jika data kurang)
final featureWarningsProvider = Provider<List<String>>((ref) {
  final features = ref.watch(featureVectorProvider);
  final predictAI = ref.watch(predictRiskAIProvider);

  return predictAI.validateFeatures(features);
});

/// Provider untuk status kelengkapan data
final dataCompletenessProvider = Provider<DataCompleteness>((ref) {
  final features = ref.watch(featureVectorProvider);

  return DataCompleteness(
    hasScreeningData: features.screeningScore > 0,
    hasActivityData: features.activityVar > 0,
    hasPPGData: features.ppgVar > 0,
  );
});

/// Status kelengkapan data untuk prediksi
class DataCompleteness {
  final bool hasScreeningData;
  final bool hasActivityData;
  final bool hasPPGData;

  const DataCompleteness({
    required this.hasScreeningData,
    required this.hasActivityData,
    required this.hasPPGData,
  });

  /// Semua data tersedia
  bool get isComplete => hasScreeningData && hasActivityData && hasPPGData;

  /// Minimal data screening tersedia
  bool get hasMinimalData => hasScreeningData;

  /// Persentase kelengkapan data
  double get completenessPercentage {
    int complete = 0;
    if (hasScreeningData) complete++;
    if (hasActivityData) complete++;
    if (hasPPGData) complete++;
    return complete / 3.0;
  }

  /// Deskripsi status kelengkapan
  String get statusDescription {
    if (isComplete) {
      return 'Semua data tersedia untuk analisis lengkap';
    } else if (hasMinimalData) {
      return 'Analisis dasar tersedia. Lengkapi data sensor untuk hasil lebih akurat.';
    } else {
      return 'Silakan isi kuesioner screening terlebih dahulu.';
    }
  }
}
