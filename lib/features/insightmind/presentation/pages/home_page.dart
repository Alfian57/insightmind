import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/insightmind_providers.dart';
import 'result_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);
    final totalScore = ref.watch(scoreProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('InsightMind - Home')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Jawaban saat ini: ${answers.join(', ')}'),
            const SizedBox(height: 10),
            Text('Total skor (hitung otomatis): $totalScore'),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: List.generate(5, (index) {
                final value = (index + 1) * 10; // contoh jawaban nilai: 10,20,30...
                return ElevatedButton(
                  onPressed: () {
                    ref.read(answersProvider.notifier).addAnswer(value);
                  },
                  child: Text('Tambah $value'),
                );
              }),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultPage()));
              },
              child: const Text('Lihat Hasil'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                ref.read(answersProvider.notifier).clear();
              },
              child: const Text('Reset Jawaban'),
            ),
          ],
        ),
      ),
    );
