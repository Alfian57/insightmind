import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/domain/entities/question.dart';
import 'package:insightmind/features/insightmind/presentation/pages/summary_page.dart';
import 'package:insightmind/features/insightmind/presentation/providers/score_provider.dart';
import 'package:insightmind/features/insightmind/presentation/providers/questionnaire_provider.dart';

class ScreeningPage extends ConsumerWidget {
  const ScreeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final progress = questions.isEmpty
        ? 0.0
        : (qState.answers.length / questions.length);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening InsightMind'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            elevation: 1.5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade300,
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Terisi ${qState.answers.length} dari ${questions.length} pertanyaan",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          for (var i = 0; i < questions.length; i++)
            _QuestionCard(
              index: i,
              question: questions[i],
              selectedScore: qState.answers[questions[i].id],
              onSelected: (score) {
                ref
                    .read(questionnaireProvider.notifier)
                    .selectAnswer(questionId: questions[i].id, score: score);
              },
            ),

          const SizedBox(height: 12),
          FilledButton.icon(
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Lihat Hasil'),
            onPressed: () {
              if (!qState.isComplete) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Lengkapi semua pertanyaan sebelum melihat hasil.',
                    ),
                  ),
                );
                return;
              }

              final ordered = <int>[];
              for (final q in questions) {
                ordered.add(qState.answers[q.id]!);
              }
              ref.read(answersProvider.notifier).setAnswers(ordered);

              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SummaryPage()));
            },
          ),

          const SizedBox(height: 8),

          TextButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Jawaban'),
            onPressed: () {
              ref.read(questionnaireProvider.notifier).reset();
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Jawaban direset.')));
            },
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int index;
  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const _QuestionCard({
    required this.index,
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${question.text}',
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ...question.options.map(
              (opt) => RadioListTile<int>(
                title: Text(opt.label),
                value: opt.score,
                groupValue: selectedScore,
                onChanged: (value) {
                  if (value != null) onSelected(value);
                },
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
