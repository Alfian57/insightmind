import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/summary_provider.dart';

/// Simple demo page untuk test provider
class ProviderDemoPage extends ConsumerWidget {
  const ProviderDemoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final questionnaireState = ref.watch(questionnaireProvider);
    final progress = ref.watch(questionnaireProgressProvider);
    final result = ref.watch(mentalResultProvider);
    final canComplete = ref.watch(canCompleteQuestionnaireProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Provider Demo'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Kuisioner',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Total Pertanyaan: ${questions.length}'),
                    Text('Sudah Dijawab: ${questionnaireState.answers.length}'),
                    Text('Progress: ${(progress * 100).toInt()}%'),
                    Text('Dapat Diselesaikan: ${canComplete ? "Ya" : "Tidak"}'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: progress),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Hasil Card
            if (result != null) ...[
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hasil Assessment',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text('Total Skor: ${result.score}'),
                      Text('Tingkat Risiko: ${result.riskLevel}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Quick Test Buttons
            Text(
              'Quick Test Actions:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Jawab semua dengan skor random
                    final notifier = ref.read(questionnaireProvider.notifier);
                    for (int i = 0; i < questions.length; i++) {
                      final question = questions[i];
                      final score = i % 4; // 0, 1, 2, 3
                      notifier.answerQuestion(question.id, score);
                    }
                  },
                  child: const Text('Jawab Semua'),
                ),

                ElevatedButton(
                  onPressed: canComplete
                      ? () {
                          ref
                              .read(questionnaireProvider.notifier)
                              .completeQuestionnaire();
                        }
                      : null,
                  child: const Text('Selesaikan'),
                ),

                ElevatedButton(
                  onPressed: () {
                    ref
                        .read(questionnaireProvider.notifier)
                        .resetQuestionnaire();
                  },
                  child: const Text('Reset'),
                ),

                ElevatedButton(
                  onPressed: () {
                    // Jawab dengan skor tinggi (simulasi risiko tinggi)
                    final notifier = ref.read(questionnaireProvider.notifier);
                    for (final question in questions) {
                      notifier.answerQuestion(question.id, 3); // skor tertinggi
                    }
                  },
                  child: const Text('Skor Tinggi'),
                ),

                ElevatedButton(
                  onPressed: () {
                    // Jawab dengan skor rendah (simulasi risiko rendah)
                    final notifier = ref.read(questionnaireProvider.notifier);
                    for (final question in questions) {
                      notifier.answerQuestion(question.id, 0); // skor terendah
                    }
                  },
                  child: const Text('Skor Rendah'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Individual Questions
            Expanded(
              child: ListView.builder(
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  final question = questions[index];
                  final answer = questionnaireState.answers[question.id];

                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: answer != null
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.grey.withValues(alpha: 0.2),
                        child: Text('${index + 1}'),
                      ),
                      title: Text(
                        question.text,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: answer != null
                          ? Text('Skor: $answer')
                          : const Text('Belum dijawab'),
                      trailing: answer != null
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(
                              Icons.radio_button_unchecked,
                              color: Colors.grey,
                            ),
                      onTap: () {
                        // Show dialog untuk pilih jawaban
                        _showAnswerDialog(context, ref, question);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnswerDialog(BuildContext context, WidgetRef ref, question) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Jawab Pertanyaan ${question.id}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(question.text),
            const SizedBox(height: 16),
            ...question.options
                .map(
                  (option) => ListTile(
                    title: Text(option.label),
                    subtitle: Text('Skor: ${option.score}'),
                    onTap: () {
                      ref
                          .read(questionnaireProvider.notifier)
                          .answerQuestion(question.id, option.score);
                      Navigator.of(context).pop();
                    },
                  ),
                )
                .toList(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }
}
