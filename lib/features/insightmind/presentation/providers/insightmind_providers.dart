import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/score_repository.dart';
import '../../domain/usecases/calculate_risk_level.dart';
import '../../domain/entities/mental_result.dart';

// 1) Provider repository (instance)
final scoreRepositoryProvider = Provider<ScoreRepository>((ref) {
  return ScoreRepository();
});

// 2) Provider usecase (instance)
final calculateRiskProvider = Provider<CalculateRiskLevel>((ref) {
  return CalculateRiskLevel();
});

// 3) answersProvider: menyimpan jawaban sementara (list int)
class AnswersNotifier extends StateNotifier<List<int>> {
  AnswersNotifier(): super([]);

  void addAnswer(int value) {
    state = [...state, value];
  }

  void clear() {
    state = [];
  }
}
final answersProvider = StateNotifierProvider<AnswersNotifier, List<int>>((ref) {
  return AnswersNotifier();
});

// 4) scoreProvider: hitung total skor memakai repository
final scoreProvider = Provider<int>((ref) {
  final answers = ref.watch(answersProvider);
  final repo = ref.read(scoreRepositoryProvider);
  return repo.calculateScore(answers);
});

// 5) resultProvider: hasil akhir berupa MentalResult dari use case
final resultProvider = Provider<MentalResult>((ref) {
  final score = ref.watch(scoreProvider);
  final usecase = ref.read(calculateRiskProvider);
  return usecase.execute(score);
});
