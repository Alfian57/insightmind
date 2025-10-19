class MentalResult {
  final int score; // total skor dari hasil kuisioner
  final String riskLevel; // level risiko: "Rendah", "Sedang", "Tinggi"

  const MentalResult({
    required this.score,
    required this.riskLevel,
  });

  @override
  String toString() => 'Score: $score, Risk Level: $riskLevel';
}
