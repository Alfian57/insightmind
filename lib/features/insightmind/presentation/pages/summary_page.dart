import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_answer.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_answer_tile.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_header.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_info_banner.dart';
import '../providers/summary_provider.dart';
import '../widgets/questionnaire_widgets.dart';

class SummaryPage extends ConsumerStatefulWidget {
  const SummaryPage({super.key});

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage> {
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    final questions = ref.watch(questionsProvider);
    final questionnaireState = ref.watch(questionnaireProvider);
    final progress = ref.watch(questionnaireProgressProvider);
    final canComplete = ref.watch(canCompleteQuestionnaireProvider);

    // Buat data summary dari provider
    final summaries = questions.asMap().entries.map((entry) {
      final index = entry.key;
      final question = entry.value;
      final answer = questionnaireState.answers[question.id];

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
        flagged: answer != null && answer >= 2, // Flag jika skor tinggi
      );
    }).toList();

    final total = summaries.length;
    final dijawab = summaries.where((s) => s.answer != 'Belum dijawab').length;
    final ditandai = summaries.where((s) => s.flagged).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Jawaban'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          // Button untuk mulai kuisioner jika belum ada jawaban
          if (dijawab == 0)
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const QuestionnaireWidget(),
                  ),
                );
              },
              child: const Text(
                'Mulai Kuisioner',
                style: TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SummaryInfoBanner(
            text:
                'Periksa kembali ringkasan jawaban Anda sebelum melihat hasil screening.',
          ),
          const SizedBox(height: 12),

          // Progress indicator
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Text('Progress: '),
                      Text('${(progress * 100).toInt()}%'),
                      const Spacer(),
                      Text('$dijawab/$total'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          SummaryHeader(total: total, dijawab: dijawab, ditandai: ditandai),
          const SizedBox(height: 12),

          // Tampilkan pesan jika belum ada jawaban
          if (summaries.isEmpty || dijawab == 0) ...[
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.quiz_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Belum ada jawaban',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Mulai kuisioner untuk melihat ringkasan jawaban Anda.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            ...summaries.map((s) => SummaryAnswerTile(summary: s)),
          ],

          const SizedBox(height: 96), // ruang untuk panel aksi bawah
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.06 * 255).toInt()),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Checkbox untuk konfirmasi
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Saya sudah meninjau ringkasan jawaban'),
                value: _isConfirmed,
                onChanged: dijawab > 0
                    ? (value) {
                        setState(() {
                          _isConfirmed = value ?? false;
                        });
                      }
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: dijawab > 0
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const QuestionnaireWidget(),
                                ),
                              );
                            }
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const QuestionnaireWidget(),
                                ),
                              );
                            },
                      icon: Icon(
                        dijawab > 0
                            ? Icons.edit_outlined
                            : Icons.play_arrow_outlined,
                      ),
                      label: Text(
                        dijawab > 0 ? 'Ubah Jawaban' : 'Mulai Kuisioner',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (_isConfirmed && canComplete)
                          ? () {
                              // Complete questionnaire dan navigasi ke hasil
                              if (!questionnaireState.isCompleted) {
                                ref
                                    .read(questionnaireProvider.notifier)
                                    .completeQuestionnaire();
                              }
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ResultWidget(),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.check_circle_outlined),
                      label: const Text('Lihat Hasil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}