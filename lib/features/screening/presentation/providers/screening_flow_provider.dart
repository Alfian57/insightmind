import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../insightmind/domain/entities/question.dart';

/// State for step-by-step screening flow
class ScreeningFlowState {
  final int currentIndex;
  final Map<String, int> answers;
  final bool isComplete;

  const ScreeningFlowState({
    this.currentIndex = 0,
    this.answers = const {},
    this.isComplete = false,
  });

  ScreeningFlowState copyWith({
    int? currentIndex,
    Map<String, int>? answers,
    bool? isComplete,
  }) {
    return ScreeningFlowState(
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  int get totalQuestions => defaultQuestions.length;

  double get progress {
    if (totalQuestions == 0) return 0;
    return answers.length / totalQuestions;
  }

  int get answeredCount => answers.length;

  int get totalScore => answers.values.fold(0, (a, b) => a + b);

  bool isQuestionAnswered(String questionId) => answers.containsKey(questionId);

  int? getAnswer(String questionId) => answers[questionId];
}

class ScreeningFlowNotifier extends Notifier<ScreeningFlowState> {
  @override
  ScreeningFlowState build() => const ScreeningFlowState();

  /// Select an answer for a question
  void selectAnswer({required String questionId, required int score}) {
    final newAnswers = Map<String, int>.from(state.answers);
    newAnswers[questionId] = score;

    final isComplete = newAnswers.length >= defaultQuestions.length;

    state = state.copyWith(
      answers: newAnswers,
      isComplete: isComplete,
    );
  }

  /// Go to next question
  void nextQuestion() {
    if (state.currentIndex < defaultQuestions.length - 1) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  /// Go to previous question
  void previousQuestion() {
    if (state.currentIndex > 0) {
      state = state.copyWith(currentIndex: state.currentIndex - 1);
    }
  }

  /// Jump to a specific question
  void jumpToQuestion(int index) {
    if (index >= 0 && index < defaultQuestions.length) {
      state = state.copyWith(currentIndex: index);
    }
  }

  /// Reset the screening flow
  void reset() {
    state = const ScreeningFlowState();
  }

  /// Check if can proceed to result
  bool get canViewResult => state.isComplete;
}

/// Provider for screening flow state
final screeningFlowProvider =
    NotifierProvider<ScreeningFlowNotifier, ScreeningFlowState>(
  ScreeningFlowNotifier.new,
);

/// Provider for questions list
final screeningQuestionsProvider = Provider<List<Question>>((ref) {
  return defaultQuestions;
});

/// Provider for current question
final currentQuestionProvider = Provider<Question>((ref) {
  final state = ref.watch(screeningFlowProvider);
  final questions = ref.watch(screeningQuestionsProvider);
  return questions[state.currentIndex];
});
