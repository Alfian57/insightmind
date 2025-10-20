import 'package:flutter/material.dart';
import 'result_page.dart';

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  // Data statis ringkasan jawaban (contoh)
  final List<_AnswerSummary> _summaries = const [
    _AnswerSummary(
      number: 1,
      question: 'Dalam 2 minggu terakhir, seberapa sering merasa cemas?',
      answer: 'Sering',
    ),
    _AnswerSummary(
      number: 2,
      question: 'Seberapa sering sulit tidur atau gelisah?',
      answer: 'Kadang-kadang',
    ),
    _AnswerSummary(
      number: 3,
      question: 'Seberapa sulit berkonsentrasi saat belajar/kerja?',
      answer: 'Sering',
      flagged: true, // contoh ditandai untuk ditinjau
    ),
    _AnswerSummary(
      number: 4,
      question: 'Seberapa sering merasa lelah tanpa sebab jelas?',
      answer: 'Jarang',
    ),
    _AnswerSummary(
      number: 5,
      question: 'Seberapa sering merasa putus asa/tertekan?',
      answer: 'Kadang-kadang',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final total = _summaries.length;
    final dijawab = _summaries.where((s) => s.answer.trim().isNotEmpty).length;
    final ditandai = _summaries.where((s) => s.flagged).length;

    // Status konfirmasi statis (diasumsikan sudah dikonfirmasi agar tombol aktif)
    const bool confirmedStatus = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ringkasan Jawaban'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _InfoBanner(
            text:
                'Periksa kembali ringkasan jawaban Anda sebelum melihat hasil screening.',
          ),
          const SizedBox(height: 12),
          // Menggunakan data hasil perhitungan statis
          _SummaryHeader(total: total, dijawab: dijawab, ditandai: ditandai),
          const SizedBox(height: 12),
          ..._summaries.map((s) => _AnswerTile(summary: s)),
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
              // Checkbox dibuat non-interaktif
              CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: const Text('Saya sudah meninjau ringkasan jawaban'),
                value: confirmedStatus, // Nilai statis
                onChanged:
                    null, // PENTING: null, karena StatelessWidget tidak bisa mengubah state
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Aksi hanya tampilan notifikasi (simulasi aksi)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Aksi ubah jawaban (UI statis contoh)',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('Ubah Jawaban'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      // Tombol selalu aktif (berdasarkan confirmedStatus statis)
                      onPressed: confirmedStatus
                          ? () {
                              // Navigasi ke halaman hasil (tetap berfungsi)
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ResultPage(),
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
