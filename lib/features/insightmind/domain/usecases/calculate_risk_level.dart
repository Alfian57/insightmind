import '../entities/mental_result.dart';

class CalculateRiskLevel {
  // Use case: menentukan level risiko berdasarkan skor
  MentalResult execute(int score) {
    String risk;

    if (score < 30) {
      risk = 'Rendah';
    } else if (score < 70) {
      risk = 'Sedang';
    } else {
      risk = 'Tinggi';
    }

    return MentalResult(score: score, riskLevel: risk);
  }
}



