import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/question.dart';
import '../../providers/questionnaire_provider.dart';
import '../../providers/score_provider.dart'; // dari Minggu 2 (resultProvider/answersProvider)
import 'result_page.dart';

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
          final selected = qState.answers[q.id]; // skor terpilih (0..3) atau null
          return _QuestionTile(
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

            // Alirkan jawaban ke `answersProvider` (Minggu 2) agar pipeline lama tetap jalan
            final answersOrdered = <int>[];
            for (final q in questions) {
              answersOrdered.add(qState.answers[q.id]!);
            }

            ref.read(answersProvider.notifier).state = answersOrdered;

            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ResultPage()),
            );
          },
          child: const Text('Lihat Hasil'),
        ),
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  const _QuestionTile({
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question.text,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final opt in question.options)
              ChoiceChip(
                label: Text(opt.label),
                selected: selectedScore == opt.score,
                onSelected: (_) => onSelected(opt.score),
              ),
          ],
        ),
      ],
    );
  }
}
