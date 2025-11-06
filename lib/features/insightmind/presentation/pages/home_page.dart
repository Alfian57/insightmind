import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:insightmind/features/insightmind/presentation/pages/history_page.dart';
import '../providers/score_provider.dart';
import 'screening_page.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final answers = ref.watch(answersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('InsightMind'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (__) => const HistoryPage()),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.psychology_alt,
                        size: 60,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Selamat datang di aplikasi InsightMind',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Mulai screening sederhana untuk memprediksi resiko kesehatan mental Anda secara cepat dan mudah.',
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      FilledButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (__) => const ScreeningPage(),
                            ),
                          );
                        },
                        child: const Text('Mulai Screening'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (answers.isNotEmpty) ...[
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(
                          'Riwayat Simulasi:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            for (final a in answers)
                              Chip(label: Text(a.toString())),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        onPressed: () {
          final newValue = (DateTime.now().millisecondsSinceEpoch % 4).toInt();
          final current = [...ref.read(answersProvider)];
          current.add(newValue);
          // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
          ref.read(answersProvider.notifier).state = current;
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
