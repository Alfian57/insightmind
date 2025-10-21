import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/presentation/pages/result_page.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_answer_tile.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_header.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_info_banner.dart';
import '../providers/summary_provider.dart';

class SummaryPage extends ConsumerStatefulWidget {
  const SummaryPage({super.key});

  @override
  ConsumerState<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends ConsumerState<SummaryPage> {
  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(questionnaireProgressProvider);
    final summaries = ref.watch(summaryListProvider);

    final total = summaries.length;
    final answered = summaries.where((s) => s.answer != 'Belum dijawab').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Jawaban'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [],
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
                      Text('$answered/$total'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          SummaryHeader(total: total, answered: answered),
          const SizedBox(height: 12),

          // Tampilkan pesan jika belum ada jawaban
          if (summaries.isEmpty || answered == 0) ...[
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
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton(
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ResultPage()));
          },
          child: const Text('Lihat Hasil'),
        ),
      ),
    );
  }
}
