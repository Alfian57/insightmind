import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/insightmind_providers.dart';

class ResultPage extends ConsumerWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(resultProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Analisis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Total Skor: ${result.score}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Level Risiko: ${result.riskLevel}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (result.riskLevel == 'Tinggi')
              const Text('Rekomendasi: Segera konsultasi ke profesional.', style: TextStyle(color: Colors.red)),
            if (result.riskLevel == 'Sedang')
              const Text('Rekomendasi: Perhatikan gejala dan pertimbangkan saran lebih lanjut.'),
            if (result.riskLevel == 'Rendah')
              const Text('Rekomendasi: Tetap jaga kesehatan mental.'),
          ],
        ),
      ),
    );
  }
}
