import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/data/repositories/score_repository.dart';
import 'package:insightmind/features/insightmind/domain/usecases/calculate_risk_level.dart';

/// Simpan jawaban kuisioner di memori (sementara).
class AnswersNotifier extends Notifier<List<int>> {
  @override
  List<int> build() {
    return [];
  }

  /// Replace entire answers list.
  void setAnswers(List<int> answers) {
    state = List<int>.from(answers);
  }

  /// Append a single answer.
  void addAnswer(int answer) {
    state = [...state, answer];
  }
}

final answersProvider = NotifierProvider<AnswersNotifier, List<int>>(
  AnswersNotifier.new,
);

/// Repository sederhana untuk hitung skor total.
final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository();
});

/// Use case untuk konversi skor → level risiko.
final calculateRiskProvider = Provider<CalculateRiskLevel>((ref) {
  return CalculateRiskLevel();
});

/// Hasil skoring mentah.
final scoreProvider = Provider<int>((ref) {
  final repo = ref.watch(scoreRepositoryProvider);
  final answers = ref.watch(answersProvider);
  return repo.calculateScore(answers);
});

/// Hasil akhir (skor + level risiko).
final resultProvider = Provider((ref) {
  final score = ref.watch(scoreProvider);
  final usecase = ref.watch(calculateRiskProvider);
  return usecase.execute(score);
});
