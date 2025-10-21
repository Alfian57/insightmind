import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/presentation/pages/summary_page.dart';
import 'package:insightmind/features/insightmind/presentation/providers/score_provider.dart';
import 'package:insightmind/features/insightmind/presentation/providers/questionnaire_provider.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/screening_question_tile.dart';

class ScreeningPage extends ConsumerWidget {
  const ScreeningPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final qState = ref.watch(questionnaireProvider);

    final answered = qState.answers.length;
    final total = questions.length;
    final progress = total == 0 ? 0.0 : (answered / total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening InsightMind'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress card specific to screening page
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _ScreeningProgressCard(
              answered: answered,
              total: total,
              progress: progress,
            ),
          ),

          // Questions list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              itemCount: questions.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final q = questions[index];
                final selected =
                    qState.answers[q.id]; // skor terpilih (0..3) atau null
                return ScreeningQuestionTile(
                  question: q,
                  selectedScore: selected,
                  onSelected: (score) {
                    ref
                        .read(questionnaireProvider.notifier)
                        .selectAnswer(questionId: q.id, score: score);
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: () {
            if (!qState.isComplete) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Lengkapi semua pertanyaan dulu.'),
                ),
              );
              return;
            }

            final answersOrdered = <int>[];
            for (final q in questions) {
              answersOrdered.add(qState.answers[q.id]!);
            }

            ref.read(answersProvider.notifier).setAnswers(answersOrdered);

            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const SummaryPage()));
          },
          child: const Text('Lihat Ringkasan'),
        ),
      ),
    );
  }
}

/// Small progress card used only on the screening page.
class _ScreeningProgressCard extends StatelessWidget {
  final int answered;
  final int total;
  final double progress;

  const _ScreeningProgressCard({
    required this.answered,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Progress: '),
                Text('${(progress * 100).toInt()}%'),
                const Spacer(),
                Text('$answered/$total pertanyaan terisi'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress),
          ],
        ),
      ),
    );
  }
}
