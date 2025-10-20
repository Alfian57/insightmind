import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/summary_provider.dart';

/// Contoh widget untuk menampilkan kuisioner
class QuestionnaireWidget extends ConsumerWidget {
  const QuestionnaireWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questions = ref.watch(questionsProvider);
    final questionnaireState = ref.watch(questionnaireProvider);
    final progress = ref.watch(questionnaireProgressProvider);
    final canComplete = ref.watch(canCompleteQuestionnaireProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mental Health Assessment'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(value: progress),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Progress: ${(progress * 100).toInt()}% (${questionnaireState.answers.length}/${questions.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),

          // Questions list
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final selectedAnswer = ref
                    .read(questionnaireProvider.notifier)
                    .getAnswer(question.id);

                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${question.text}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        ...question.options.map((option) {
                          return RadioListTile<int>(
                            title: Text(option.label),
                            value: option.score,
                            groupValue: selectedAnswer,
                            onChanged: (value) {
                              if (value != null) {
                                ref
                                    .read(questionnaireProvider.notifier)
                                    .answerQuestion(question.id, value);
                              }
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Complete button
          if (canComplete)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: () {
                  ref
                      .read(questionnaireProvider.notifier)
                      .completeQuestionnaire();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const ResultWidget(),
                    ),
                  );
                },
                child: const Text('Lihat Hasil'),
              ),
            ),
        ],
      ),
    );
  }
}

/// Widget untuk menampilkan hasil assessment
class ResultWidget extends ConsumerWidget {
  const ResultWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(mentalResultProvider);
    final stats = ref.watch(answerStatsProvider);

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Hasil')),
        body: const Center(
          child: Text(
            'Hasil tidak tersedia. Silakan selesaikan kuisioner terlebih dahulu.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Assessment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Assessment',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Total Skor: '),
                        Text(
                          '${result.score}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Text('Tingkat Risiko: '),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRiskColor(result.riskLevel),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            result.riskLevel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Statistik jawaban
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Jawaban',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      'Rata-rata Skor',
                      '${stats['averageScore'].toStringAsFixed(1)}',
                    ),
                    _buildStatRow('Skor Tertinggi', '${stats['highestScore']}'),
                    _buildStatRow('Skor Terendah', '${stats['lowestScore']}'),
                    _buildStatRow('Total Jawaban', '${stats['totalAnswers']}'),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(questionnaireProvider.notifier)
                          .resetQuestionnaire();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Ulang Assessment'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Kembali'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Rendah':
        return Colors.green;
      case 'Sedang':
        return Colors.orange;
      case 'Tinggi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Widget untuk menampilkan summary/ringkasan
class SummaryWidget extends ConsumerWidget {
  const SummaryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questionnaireState = ref.watch(questionnaireProvider);
    final progress = ref.watch(questionnaireProgressProvider);
    final unansweredQuestions = ref.watch(unansweredQuestionsProvider);
    final result = ref.watch(mentalResultProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ringkasan', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),

            // Progress
            Row(
              children: [
                const Text('Progress: '),
                Text('${(progress * 100).toInt()}%'),
                const SizedBox(width: 8),
                Expanded(child: LinearProgressIndicator(value: progress)),
              ],
            ),

            const SizedBox(height: 8),

            // Status
            if (questionnaireState.isCompleted && result != null) ...[
              const Text('Status: Selesai'),
              Text('Skor: ${result.score}'),
              Text('Tingkat Risiko: ${result.riskLevel}'),
            ] else if (unansweredQuestions.isEmpty &&
                !questionnaireState.isCompleted) ...[
              const Text('Status: Siap diselesaikan'),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(questionnaireProvider.notifier)
                      .completeQuestionnaire();
                },
                child: const Text('Selesaikan Assessment'),
              ),
            ] else ...[
              Text(
                'Status: ${unansweredQuestions.length} pertanyaan belum dijawab',
              ),
              if (unansweredQuestions.isNotEmpty)
                Text(
                  'Pertanyaan selanjutnya: ${unansweredQuestions.first.text}',
                ),
            ],
          ],
        ),
      ),
    );
  }
}
