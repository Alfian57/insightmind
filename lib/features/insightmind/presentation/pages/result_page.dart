import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultProvider);

    String recommendation;
    switch (result.riskLevel) {
      case 'Tinggi':
        recommendation = 'Pertimbangkan berbicara dengan konselor/psikolog. '
            'Kurangi beban, istirahat cukup, dan hubungi layanan kampus.';
        break;
      case 'Sedang':
        recommendation =
            'Lakukan aktivitas relaksasi (napas dalam, olahraga ringan), '
            'atur waktu, dan evaluasi beban kuliah/kerja.';
        break;
      default:
        recommendation =
            'Pertahankan kebiasaan baik. Jaga tidur, makan, dan olahraga.';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Screening'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Skor Anda: ${result.score}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Tingkat Risiko: ${result.riskLevel}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 24),
            Text(
              recommendation,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Spacer(),
            const Text(
              'Disclaimer: InsightMind bersifat edukatif, bukan alat diagnosis medis.',
              textAlign: TextAlign.center,
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}