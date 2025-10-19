class ScoreRepository {
  // Repository: menghitung total skor dari daftar jawaban kuisioner
  int calculateScore(List<int> answers) {
    int total = 0;
    for (final answer in answers) {
      total += answer;
    }
    return total;
  }
}
