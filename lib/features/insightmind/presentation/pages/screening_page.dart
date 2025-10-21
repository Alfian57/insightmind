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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Screening InsightMind'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
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
          child: const Text('Lihat Hasil'),
        ),
      ),
    );
  }
}
