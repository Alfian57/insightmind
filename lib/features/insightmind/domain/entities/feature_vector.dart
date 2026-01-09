/// FeatureVector Model
/// Struktur data yang berisi fitur-fitur untuk prediksi risiko kesehatan mental
/// menggunakan AI on-device berbasis rule-based.
///
/// Fitur terdiri dari:
/// - screeningScore: Skor hasil screening questionnaire (PHQ/DASS style)
/// - activityMean: Rata-rata magnitude accelerometer dari sliding window
/// - activityVar: Variance magnitude accelerometer dari sliding window
/// - ppgMean: Rata-rata nilai luminance dari PPG (photoplethysmography)
/// - ppgVar: Variance nilai luminance dari PPG
class FeatureVector {
  /// Skor dari hasil screening questionnaire (0-27 untuk 9 pertanyaan)
  final double screeningScore;

  /// Mean dari magnitude accelerometer (sliding window 50 sampel)
  /// Mengindikasikan tingkat aktivitas fisik rata-rata
  final double activityMean;

  /// Variance dari magnitude accelerometer (sliding window 50 sampel)
  /// Mengindikasikan variabilitas gerakan/kegelisahan
  final double activityVar;

  /// Mean dari nilai luminance PPG (sliding window 300 sampel)
  /// Mengindikasikan baseline aliran darah
  final double ppgMean;

  /// Variance dari nilai luminance PPG (sliding window 300 sampel)
  /// Mengindikasikan variabilitas detak jantung
  final double ppgVar;

  const FeatureVector({
    required this.screeningScore,
    required this.activityMean,
    required this.activityVar,
    required this.ppgMean,
    required this.ppgVar,
  });

  /// Factory constructor untuk membuat FeatureVector kosong/default
  factory FeatureVector.empty() {
    return const FeatureVector(
      screeningScore: 0.0,
      activityMean: 0.0,
      activityVar: 0.0,
      ppgMean: 0.0,
      ppgVar: 0.0,
    );
  }

  /// Factory constructor dari Map (untuk deserialisasi dari storage)
  factory FeatureVector.fromMap(Map<String, dynamic> map) {
    return FeatureVector(
      screeningScore: (map['screeningScore'] as num?)?.toDouble() ?? 0.0,
      activityMean: (map['activityMean'] as num?)?.toDouble() ?? 0.0,
      activityVar: (map['activityVar'] as num?)?.toDouble() ?? 0.0,
      ppgMean: (map['ppgMean'] as num?)?.toDouble() ?? 0.0,
      ppgVar: (map['ppgVar'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Konversi ke Map (untuk serialisasi ke storage)
  Map<String, dynamic> toMap() {
    return {
      'screeningScore': screeningScore,
      'activityMean': activityMean,
      'activityVar': activityVar,
      'ppgMean': ppgMean,
      'ppgVar': ppgVar,
    };
  }

  /// Membuat salinan dengan nilai yang diubah
  FeatureVector copyWith({
    double? screeningScore,
    double? activityMean,
    double? activityVar,
    double? ppgMean,
    double? ppgVar,
  }) {
    return FeatureVector(
      screeningScore: screeningScore ?? this.screeningScore,
      activityMean: activityMean ?? this.activityMean,
      activityVar: activityVar ?? this.activityVar,
      ppgMean: ppgMean ?? this.ppgMean,
      ppgVar: ppgVar ?? this.ppgVar,
    );
  }

  @override
  String toString() {
    return 'FeatureVector('
        'screeningScore: ${screeningScore.toStringAsFixed(2)}, '
        'activityMean: ${activityMean.toStringAsFixed(4)}, '
        'activityVar: ${activityVar.toStringAsFixed(4)}, '
        'ppgMean: ${ppgMean.toStringAsFixed(4)}, '
        'ppgVar: ${ppgVar.toStringAsFixed(4)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureVector &&
        other.screeningScore == screeningScore &&
        other.activityMean == activityMean &&
        other.activityVar == activityVar &&
        other.ppgMean == ppgMean &&
        other.ppgVar == ppgVar;
  }

  @override
  int get hashCode {
    return Object.hash(
      screeningScore,
      activityMean,
      activityVar,
      ppgMean,
      ppgVar,
    );
  }
}
