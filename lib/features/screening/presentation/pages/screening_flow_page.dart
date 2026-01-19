import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_progress.dart';
import '../../../insightmind/domain/entities/question.dart';
import '../providers/screening_flow_provider.dart';
import '../widgets/answer_option_card.dart';
import '../widgets/question_card.dart';
import '../widgets/question_navigator.dart';
import 'screening_result_page.dart';

class ScreeningFlowPage extends ConsumerStatefulWidget {
  const ScreeningFlowPage({super.key});

  @override
  ConsumerState<ScreeningFlowPage> createState() => _ScreeningFlowPageState();
}

class _ScreeningFlowPageState extends ConsumerState<ScreeningFlowPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late PageController _pageController;
  int _previousIndex = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
    
    // Initialize PageController with initial page from state
    final initialIndex = ref.read(screeningFlowProvider).currentIndex;
    _pageController = PageController(initialPage: initialIndex);
    _previousIndex = initialIndex;

    // Start initial animation
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync PageController when returning to this page
    final state = ref.read(screeningFlowProvider);
    if (state.currentIndex == 0 && state.answers.isEmpty && _pageController.hasClients) {
      final currentPage = _pageController.page?.round() ?? 0;
      if (currentPage != 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(0);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    ref.read(screeningFlowProvider.notifier).jumpToQuestion(index);
    _resetAnimation();
  }

  void _jumpToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextQuestion() {
    final state = ref.read(screeningFlowProvider);
    if (state.currentIndex < state.totalQuestions - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _resetAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  void _onAnswerSelected(String questionId, int score) {
    HapticFeedback.lightImpact();
    ref.read(screeningFlowProvider.notifier).selectAnswer(
          questionId: questionId,
          score: score,
        );

    // Auto-advance after short delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        final state = ref.read(screeningFlowProvider);
        if (state.currentIndex < state.totalQuestions - 1) {
          _nextQuestion();
        }
      }
    });
  }

  void _showQuestionNavigator() {
    final state = ref.read(screeningFlowProvider);
    final questions = ref.read(screeningQuestionsProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: QuestionNavigatorSheet(
            totalQuestions: state.totalQuestions,
            currentIndex: state.currentIndex,
            answers: state.answers,
            questionIds: questions.map((q) => q.id).toList(),
            onQuestionTap: _jumpToQuestion,
          ),
        ),
      ),
    );
  }

  void _viewResult() {
    final state = ref.read(screeningFlowProvider);
    if (!state.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Lengkapi semua pertanyaan terlebih dahulu (${state.answeredCount}/${state.totalQuestions})',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScreeningResultPage(),
      ),
    );
  }

  void _resetScreening() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Screening?'),
        content: const Text(
          'Semua jawaban akan dihapus. Anda yakin ingin melanjutkan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(screeningFlowProvider.notifier).reset();
              _pageController.animateToPage(
                0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(screeningFlowProvider);
    final questions = ref.watch(screeningQuestionsProvider);

    // Sync PageController with state when reset is detected
    // This handles the case when user returns to screening page after completing
    if (state.currentIndex == 0 && _previousIndex != 0 && state.answers.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients && _pageController.page != 0) {
          _pageController.jumpToPage(0);
          _resetAnimation();
        }
      });
    }
    _previousIndex = state.currentIndex;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                onTap: _resetScreening,
                child: const Row(
                  children: [
                    Icon(Icons.refresh, size: 20),
                    SizedBox(width: 12),
                    Text('Reset Jawaban'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${state.answeredCount} dari ${state.totalQuestions} terjawab',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${(state.progress * 100).toInt()}%',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AppProgressIndicator(
                  value: state.progress,
                  height: 6,
                ),
              ],
            ),
          ),

          // Question Navigator
          QuestionNavigator(
            totalQuestions: state.totalQuestions,
            currentIndex: state.currentIndex,
            answers: state.answers,
            questionIds: questions.map((q) => q.id).toList(),
            onQuestionTap: _jumpToQuestion,
          ),

          // Questions PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final selectedAnswer = state.getAnswer(question.id);

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Question Card
                      QuestionCard(
                        questionNumber: index + 1,
                        totalQuestions: questions.length,
                        questionText: question.text,
                        animation: _animation,
                      ),
                      const SizedBox(height: 24),

                      // Answer Options
                      ...List.generate(
                        question.options.length,
                        (optIndex) {
                          final option = question.options[optIndex];
                          return AnswerOptionCard(
                            label: option.label,
                            score: option.score,
                            isSelected: selectedAnswer == option.score,
                            index: optIndex,
                            animation: _animation,
                            onTap: () =>
                                _onAnswerSelected(question.id, option.score),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Navigation
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                // Previous button
                if (state.currentIndex > 0)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _previousQuestion,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Sebelumnya'),
                    ),
                  )
                else
                  const Expanded(child: SizedBox()),

                const SizedBox(width: 8),

                // Next/Result button
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    onPressed: state.currentIndex == state.totalQuestions - 1
                        ? _viewResult
                        : _nextQuestion,
                    icon: Icon(
                      state.currentIndex == state.totalQuestions - 1
                          ? Icons.check_circle_outline
                          : Icons.arrow_forward,
                      size: 18,
                    ),
                    label: Text(
                      state.currentIndex == state.totalQuestions - 1
                          ? 'Lihat Hasil'
                          : 'Selanjutnya',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
