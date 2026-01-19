import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Question number navigator for quick jumping between questions
class QuestionNavigator extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final Map<String, int> answers;
  final List<String> questionIds;
  final Function(int) onQuestionTap;

  const QuestionNavigator({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answers,
    required this.questionIds,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: List.generate(totalQuestions, (index) {
            final isAnswered = answers.containsKey(questionIds[index]);
            final isCurrent = index == currentIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onQuestionTap(index),
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : isAnswered
                            ? AppColors.success.withOpacity(0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : isAnswered
                              ? AppColors.success
                              : theme.colorScheme.outlineVariant,
                      width: isCurrent ? 2 : 1,
                    ),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color:
                                  theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: isCurrent
                                ? Colors.white
                                : isAnswered
                                    ? AppColors.success
                                    : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isAnswered && !isCurrent)
                        Positioned(
                          top: 2,
                          right: 2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

/// Compact question navigator as a bottom sheet
class QuestionNavigatorSheet extends StatelessWidget {
  final int totalQuestions;
  final int currentIndex;
  final Map<String, int> answers;
  final List<String> questionIds;
  final Function(int) onQuestionTap;

  const QuestionNavigatorSheet({
    super.key,
    required this.totalQuestions,
    required this.currentIndex,
    required this.answers,
    required this.questionIds,
    required this.onQuestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Lompat ke Pertanyaan',
                style: theme.textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${answers.length} dari $totalQuestions terjawab',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
            ),
            itemCount: totalQuestions,
            itemBuilder: (context, index) {
              final isAnswered = answers.containsKey(questionIds[index]);
              final isCurrent = index == currentIndex;

              return InkWell(
                onTap: () {
                  onQuestionTap(index);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? theme.colorScheme.primary
                        : isAnswered
                            ? AppColors.success.withOpacity(0.15)
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCurrent
                          ? theme.colorScheme.primary
                          : isAnswered
                              ? AppColors.success
                              : theme.colorScheme.outlineVariant,
                      width: isCurrent ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isCurrent
                                ? Colors.white
                                : isAnswered
                                    ? AppColors.success
                                    : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isAnswered && !isCurrent)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
