import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/mental_result.dart';
import '../../domain/entities/question.dart';
import '../../domain/usecases/calculate_risk_level.dart';

/// Provider untuk use case calculate risk level
final calculateRiskLevelProvider = Provider<CalculateRiskLevel>((ref) {
  return CalculateRiskLevel();
});

/// Provider untuk pertanyaan kuisioner
final questionsProvider = Provider<List<Question>>((ref) {
  return defaultQuestions;
});

/// State class untuk menyimpan jawaban pengguna
class QuestionnaireState {
  final Map<String, int> answers;
  final bool isCompleted;

  const QuestionnaireState({required this.answers, required this.isCompleted});

  QuestionnaireState copyWith({Map<String, int>? answers, bool? isCompleted}) {
    return QuestionnaireState(
      answers: answers ?? this.answers,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  /// Menghitung total skor dari semua jawaban
  int get totalScore {
    return answers.values.fold(0, (sum, score) => sum + score);
  }

  /// Mengecek apakah semua pertanyaan sudah dijawab
  bool get isAllAnswered {
    final questions = defaultQuestions;
    return questions.every((question) => answers.containsKey(question.id));
  }
}

/// StateNotifier untuk mengelola state kuisioner
class QuestionnaireNotifier extends Notifier<QuestionnaireState> {
  @override
  QuestionnaireState build() {
    return const QuestionnaireState(answers: {}, isCompleted: false);
  }

  /// Menyimpan jawaban untuk pertanyaan tertentu
  void answerQuestion(String questionId, int score) {
    final newAnswers = Map<String, int>.from(state.answers);
    newAnswers[questionId] = score;

    state = state.copyWith(answers: newAnswers, isCompleted: false);
  }

  /// Menyelesaikan kuisioner
  void completeQuestionnaire() {
    if (state.isAllAnswered) {
      state = state.copyWith(isCompleted: true);
    }
  }

  /// Reset kuisioner
  void resetQuestionnaire() {
    state = const QuestionnaireState(answers: {}, isCompleted: false);
  }

  /// Mendapatkan jawaban untuk pertanyaan tertentu
  int? getAnswer(String questionId) {
    return state.answers[questionId];
  }
}

/// Provider untuk StateNotifier kuisioner
final questionnaireProvider =
    NotifierProvider<QuestionnaireNotifier, QuestionnaireState>(() {
      return QuestionnaireNotifier();
    });

/// Provider untuk mendapatkan hasil mental health assessment
final mentalResultProvider = Provider<MentalResult?>((ref) {
  final questionnaireState = ref.watch(questionnaireProvider);
  final calculateRiskLevel = ref.watch(calculateRiskLevelProvider);

  if (!questionnaireState.isCompleted || !questionnaireState.isAllAnswered) {
    return null;
  }

  return calculateRiskLevel.execute(questionnaireState.totalScore);
});

/// Provider untuk mendapatkan progress kuisioner (0.0 - 1.0)
final questionnaireProgressProvider = Provider<double>((ref) {
  final questionnaireState = ref.watch(questionnaireProvider);
  final totalQuestions = defaultQuestions.length;
  final answeredQuestions = questionnaireState.answers.length;

  return totalQuestions > 0 ? answeredQuestions / totalQuestions : 0.0;
});

/// Provider untuk mengecek apakah kuisioner dapat diselesaikan
final canCompleteQuestionnaireProvider = Provider<bool>((ref) {
  final questionnaireState = ref.watch(questionnaireProvider);
  return questionnaireState.isAllAnswered && !questionnaireState.isCompleted;
});

/// Provider untuk mendapatkan pertanyaan yang belum dijawab
final unansweredQuestionsProvider = Provider<List<Question>>((ref) {
  final questions = ref.watch(questionsProvider);
  final questionnaireState = ref.watch(questionnaireProvider);

  return questions
      .where((question) => !questionnaireState.answers.containsKey(question.id))
      .toList();
});

/// Provider untuk statistik jawaban (opsional - untuk analytics)
final answerStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final questionnaireState = ref.watch(questionnaireProvider);

  if (questionnaireState.answers.isEmpty) {
    return {
      'averageScore': 0.0,
      'highestScore': 0,
      'lowestScore': 0,
      'totalAnswers': 0,
    };
  }

  final scores = questionnaireState.answers.values.toList();
  final average = scores.reduce((a, b) => a + b) / scores.length;
  final highest = scores.reduce((a, b) => a > b ? a : b);
  final lowest = scores.reduce((a, b) => a < b ? a : b);

  return {
    'averageScore': average,
    'highestScore': highest,
    'lowestScore': lowest,
    'totalAnswers': scores.length,
  };
});
