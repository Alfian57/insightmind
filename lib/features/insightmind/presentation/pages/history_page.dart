import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:insightmind/features/insightmind/data/local/screening_record.dart';
import 'package:insightmind/features/insightmind/presentation/providers/history_providers.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Screening')),
      body: historyAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(child: Text('Belum ada riwayat screening.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final ScreeningRecord r = items[i];
              return Card(
                child: ListTile(
                  title: Text('Skor: ${r.score} - ${r.riskLevel}'),
                  subtitle: Text(
                    'Waktu: ${r.timestamp}\nID: ${r.id}',
                    maxLines: 2,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      ref.read(historyRepositoryProvider).deleteById(r.id);
                      // ignore: unused_result
                      ref.refresh(historyListProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Riwayat dihapus')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Terjadi kesalahan: $error')),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          icon: const Icon(Icons.delete_sweep),
          label: const Text('Kosongkan Semua Riwayat'),
          onPressed: () async {
            final ok = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Konfirmasi'),
                content: const Text('Yakin ingin menghapus semua riwayat?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Batal'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            );

            if (ok == true) {
              await ref.read(historyRepositoryProvider).clearAll();
              // ignore: unused_result
              ref.refresh(historyListProvider);
            }
          },
        ),
      ),
    );
  }
}
