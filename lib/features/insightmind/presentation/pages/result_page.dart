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
        recommendation =
            'Pertimbangkan berbicara dengan konselor/psikolog. '
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
      appBar: AppBar(title: const Text('Hasil Screening')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.emoji_objects,
                    size: 60,
                    color: Colors.indigo,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Skor Anda: ${result.score}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    'Tingkat Risiko: ${result.riskLevel}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: result.riskLevel == 'Tinggi'
                          ? Colors.red
                          : result.riskLevel == 'Sedang'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(recommendation, textAlign: TextAlign.center),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Kembali'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
