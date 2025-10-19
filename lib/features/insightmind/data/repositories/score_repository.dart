class ScoreRepository {
  // Repository: menghitung total skor dari daftar jawaban kuisioner
  int calculateScore(List<int> answers) {
    if (answers.isEmpty) return 0;
    return answers.reduce((a, b) => a + b);
  }
}
