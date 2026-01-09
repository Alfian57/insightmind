/// Hasil prediksi risiko dari AI on-device
///
/// Berisi informasi lengkap tentang prediksi risiko kesehatan mental
/// termasuk skor, kategori risiko, dan tingkat kepercayaan prediksi.
class PredictionResult {
  /// Skor prediksi yang dihitung dari FeatureVector
  final double score;

  /// Kategori risiko: "Rendah", "Sedang", atau "Tinggi"
  final String riskLevel;

  /// Tingkat kepercayaan prediksi (0.3 - 0.95)
  final double confidence;

  /// Timestamp ketika prediksi dibuat
  final DateTime timestamp;

  /// FeatureVector yang digunakan untuk prediksi (opsional, untuk tracing)
  final Map<String, dynamic>? featureDetails;

  const PredictionResult({
    required this.score,
    required this.riskLevel,
    required this.confidence,
    required this.timestamp,
    this.featureDetails,
  });

  /// Factory constructor untuk hasil prediksi default/kosong
  factory PredictionResult.empty() {
    return PredictionResult(
      score: 0.0,
      riskLevel: 'Belum Dianalisis',
      confidence: 0.0,
      timestamp: DateTime.now(),
    );
  }

  /// Factory constructor dari Map (untuk deserialisasi)
  factory PredictionResult.fromMap(Map<String, dynamic> map) {
    return PredictionResult(
      score: (map['score'] as num?)?.toDouble() ?? 0.0,
      riskLevel: map['riskLevel'] as String? ?? 'Belum Dianalisis',
      confidence: (map['confidence'] as num?)?.toDouble() ?? 0.0,
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      featureDetails: map['featureDetails'] as Map<String, dynamic>?,
    );
  }

  /// Konversi ke Map (untuk serialisasi)
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'riskLevel': riskLevel,
      'confidence': confidence,
      'timestamp': timestamp.toIso8601String(),
      if (featureDetails != null) 'featureDetails': featureDetails,
    };
  }

  /// Mendapatkan warna indikator berdasarkan risiko (untuk UI)
  String get riskColorHex {
    switch (riskLevel) {
      case 'Tinggi':
        return '#E53935'; // Merah
      case 'Sedang':
        return '#FB8C00'; // Oranye
      case 'Rendah':
        return '#43A047'; // Hijau
      default:
        return '#9E9E9E'; // Abu-abu
    }
  }

  /// Mendapatkan deskripsi singkat risiko
  String get riskDescription {
    switch (riskLevel) {
      case 'Tinggi':
        return 'Disarankan untuk berkonsultasi dengan profesional kesehatan mental.';
      case 'Sedang':
        return 'Perhatikan kondisi Anda dan pertimbangkan untuk berbicara dengan seseorang.';
      case 'Rendah':
        return 'Kondisi Anda terlihat baik. Tetap jaga kesehatan mental Anda.';
      default:
        return 'Lakukan screening untuk mendapatkan analisis.';
    }
  }

  /// Mendapatkan persentase confidence sebagai string
  String get confidencePercentage {
    return '${(confidence * 100).toStringAsFixed(0)}%';
  }

  @override
  String toString() {
    return 'PredictionResult('
        'score: ${score.toStringAsFixed(2)}, '
        'riskLevel: $riskLevel, '
        'confidence: ${confidencePercentage}, '
        'timestamp: ${timestamp.toIso8601String()})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PredictionResult &&
        other.score == score &&
        other.riskLevel == riskLevel &&
        other.confidence == confidence &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(score, riskLevel, confidence, timestamp);
  }
}
