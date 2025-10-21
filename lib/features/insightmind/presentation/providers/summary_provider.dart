import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/domain/entities/question.dart';
import 'package:insightmind/features/insightmind/domain/entities/mental_result.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_answer.dart';
import 'package:insightmind/features/insightmind/presentation/providers/questionnaire_provider.dart';
import 'package:insightmind/features/insightmind/presentation/providers/score_provider.dart';

/// Progres (0.0 .. 1.0) berdasarkan jumlah pertanyaan yang sudah dijawab.
final questionnaireProgressProvider = Provider<double>((ref) {
  final questions = ref.watch(questionsProvider);
  final state = ref.watch(questionnaireProvider);
  if (questions.isEmpty) return 0.0;
  final value = state.answers.length / questions.length;
  if (value < 0) return 0.0;
  if (value > 1) return 1.0;
  return value;
});

/// Daftar pertanyaan yang belum dijawab.
final unansweredQuestionsProvider = Provider<List<Question>>((ref) {
  final questions = ref.watch(questionsProvider);
  final state = ref.watch(questionnaireProvider);
  final answers = state.answers;
  return questions.where((q) => !answers.containsKey(q.id)).toList();
});

/// Apakah kuesioner sudah siap diselesaikan (semua pertanyaan sudah dijawab).
final canCompleteQuestionnaireProvider = Provider<bool>((ref) {
  final questions = ref.watch(questionsProvider);
  final state = ref.watch(questionnaireProvider);
  return questions.isNotEmpty && state.answers.length >= questions.length;
});

/// Hasil mental yang didapat (null jika belum semua dijawab).
final mentalResultProvider = Provider<MentalResult?>((ref) {
  final state = ref.watch(questionnaireProvider);
  final questions = ref.watch(questionsProvider);
  if (questions.isEmpty) return null;
  if (state.answers.length < questions.length) return null;
  final usecase = ref.watch(calculateRiskProvider);
  return usecase.execute(state.totalScore);
});

/// Statistik jawaban sederhana yang dihitung dari jawaban saat ini.
final answerStatsProvider = Provider<Map<String, num>>((ref) {
  final state = ref.watch(questionnaireProvider);
  final values = state.answers.values.toList();
  if (values.isEmpty) {
    return {
      'averageScore': 0.0,
      'highestScore': 0,
      'lowestScore': 0,
      'totalAnswers': 0,
    };
  }

  final total = values.fold<int>(0, (p, e) => p + e);
  final highest = values.reduce((a, b) => a > b ? a : b);
  final lowest = values.reduce((a, b) => a < b ? a : b);
  return {
    'averageScore': total / values.length,
    'highestScore': highest,
    'lowestScore': lowest,
    'totalAnswers': values.length,
  };
});

/// Daftar ringkasan yang digunakan oleh UI: memetakan pertanyaan -> label yang dipilih dan status flag.
final summaryListProvider = Provider<List<SummaryAnswer>>((ref) {
  final questions = ref.watch(questionsProvider);
  final state = ref.watch(questionnaireProvider);
  final answers = state.answers;

  return questions.asMap().entries.map((entry) {
    final index = entry.key;
    final question = entry.value;
    final answer = answers[question.id];

    String answerText = 'Belum dijawab';
    if (answer != null) {
      final selectedOption = question.options.firstWhere(
        (option) => option.score == answer,
        orElse: () => question.options.first,
      );
      answerText = selectedOption.label;
    }

    return SummaryAnswer(
      number: index + 1,
      question: question.text,
      answer: answerText,
    );
  }).toList();
});
