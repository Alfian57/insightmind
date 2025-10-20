import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

      return _AnswerSummary(
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
          const _InfoBanner(
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
          _SummaryHeader(total: total, dijawab: dijawab, ditandai: ditandai),
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
            ...summaries.map((s) => _AnswerTile(summary: s)),
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
                color: Colors.black.withOpacity(0.06),
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

// --- Widget Pembantu (Semua StatelessWidget) ---

class _InfoBanner extends StatelessWidget {
  final String text;
  const _InfoBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.indigo.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.indigo),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: scheme.onSurface)),
          ),
        ],
      ),
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  final int total;
  final int dijawab;
  final int ditandai;
  const _SummaryHeader({
    required this.total,
    required this.dijawab,
    required this.ditandai,
  });

  @override
  Widget build(BuildContext context) {
    // Konversi int ke String untuk tampilan Chip
    final totalStr = total.toString();
    final dijawabStr = dijawab.toString();
    final ditandaiStr = ditandai.toString();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(
              label: 'Total Pertanyaan',
              value: totalStr,
              color: Colors.indigo,
            ),
            _StatChip(label: 'Dijawab', value: dijawabStr, color: Colors.green),
            _StatChip(
              label: 'Ditandai',
              value: ditandaiStr,
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }
}

class _AnswerTile extends StatelessWidget {
  final _AnswerSummary summary;
  const _AnswerTile({required this.summary});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.12),
          child: Text(
            '${summary.number}',
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(summary.question),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('Jawaban Anda: ${summary.answer}'),
        ),
        trailing: summary.flagged
            ? const Tooltip(
                message: 'Ditandai untuk ditinjau',
                child: Icon(Icons.flag_outlined, color: Colors.orange),
              )
            : null,
      ),
    );
  }
}

class _AnswerSummary {
  final int number;
  final String question;
  final String answer;
  final bool flagged;

  const _AnswerSummary({
    required this.number,
    required this.question,
    required this.answer,
    this.flagged = false,
  });
}
