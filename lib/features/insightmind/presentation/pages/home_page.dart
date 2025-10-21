import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/score_provider.dart';
import 'screening_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InsightMind - Home'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Selamat datang di aplikasi InsightMind\n\n'
              'Latihan Mindful di mana saja dan kapanpun.\n'
              'Fokus, meditasi, dan kembangkan diri sekarang.\n'
              'Instruksi yang mudah dan sederhana dan cepat.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            // Tombol menuju ScreeningPage
            SizedBox(
              width: double.infinity,
              height: 50, // Ukuran tombol
              child: FilledButton.icon(
                icon: const Icon(Icons.psychology_alt),
                label: const Text('Mulai Tes Kesiapan Diri'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (__) => const ScreeningPage()),
                  );
                },
              ),
            ),

            const SizedBox(height: 32),
            const Divider(thickness: 1),

            // Text untuk hasil terakhir
            const Text(
              'Latihan Minggu 2 - Simulasi Jawaban',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Wrap(
              spacing: 8,
              children: [
                for (int i = 0; i < answers.length; i++)
                  Chip(label: Text('${answers[i]}')),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        onPressed: () {
          // Tambah data dummy (latihan minggu)
          final newValue = (DateTime.now().millisecondsSinceEpoch % 4).toInt();
          final current = [...ref.read(answersProvider)];
          current.add(newValue);
          ref.read(answersProvider.notifier).setAnswers(current);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
