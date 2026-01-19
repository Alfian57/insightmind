import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../insightmind/data/local/screening_record.dart';
import '../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Screening'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () => _showClearAllDialog(context, ref),
            tooltip: 'Hapus Semua',
          ),
        ],
      ),
      body: historyAsync.when(
        data: (records) {
          if (records.isEmpty) {
            return _EmptyHistory();
          }
          return _HistoryList(records: records);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) async {
    final confirm = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Hapus Semua Riwayat?',
      message:
          'Semua data riwayat screening akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
      confirmText: 'Hapus Semua',
      isDangerous: true,
    );

    if (confirm == true) {
      await ref.read(historyRepositoryProvider).clearAll();
      ref.invalidate(historyListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Semua riwayat telah dihapus')),
        );
      }
    }
  }
}

class _EmptyHistory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Riwayat',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Hasil screening Anda akan tersimpan di sini.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryList extends ConsumerWidget {
  final List<ScreeningRecord> records;

  const _HistoryList({required this.records});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Group records by month
    final groupedRecords = _groupByMonth(records);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedRecords.length,
      itemBuilder: (context, index) {
        final entry = groupedRecords.entries.elementAt(index);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 4),
              child: Text(
                entry.key,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ...entry.value.map((record) => _HistoryCard(
                  record: record,
                  onDelete: () => _deleteRecord(context, ref, record),
                )),
          ],
        );
      },
    );
  }

  Map<String, List<ScreeningRecord>> _groupByMonth(
      List<ScreeningRecord> records) {
    final grouped = <String, List<ScreeningRecord>>{};

    for (final record in records) {
      final key = DateFormat('MMMM yyyy').format(record.timestamp);
      grouped.putIfAbsent(key, () => []).add(record);
    }

    return grouped;
  }

  void _deleteRecord(
    BuildContext context,
    WidgetRef ref,
    ScreeningRecord record,
  ) async {
    final confirm = await AppBottomSheet.showConfirm(
      context: context,
      title: 'Hapus Riwayat?',
      message: 'Yakin ingin menghapus riwayat screening ini?',
      confirmText: 'Hapus',
      isDangerous: true,
    );

    if (confirm == true) {
      await ref.read(historyRepositoryProvider).deleteById(record.id);
      ref.invalidate(historyListProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat telah dihapus')),
        );
      }
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final ScreeningRecord record;
  final VoidCallback onDelete;

  const _HistoryCard({
    required this.record,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor(record.riskLevel);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        onTap: () => _showDetail(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Score circle
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: riskColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${record.score}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: riskColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Skor',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: riskColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          AppRiskBadge(
                            riskLevel: record.riskLevel,
                            showIcon: false,
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: onDelete,
                            icon: Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: theme.colorScheme.error,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor:
                                  theme.colorScheme.error.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(record.timestamp),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('HH:mm').format(record.timestamp),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor(record.riskLevel);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),

                // Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: riskColor, width: 3),
                  ),
                  child: Icon(
                    _getRiskIcon(record.riskLevel),
                    size: 40,
                    color: riskColor,
                  ),
                ),
                const SizedBox(height: 16),

                Text(
                  'Skor: ${record.score}',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                AppRiskBadge(riskLevel: record.riskLevel, large: true),
                const SizedBox(height: 16),

                Text(
                  DateFormat('EEEE, dd MMMM yyyy').format(record.timestamp),
                  style: theme.textTheme.bodyLarge,
                ),
                Text(
                  'Pukul ${DateFormat('HH:mm').format(record.timestamp)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),

                AppOutlinedButton(
                  text: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRiskColor(String riskLevel) {
    switch (riskLevel) {
      case 'Rendah':
        return AppColors.success;
      case 'Sedang':
        return AppColors.warning;
      case 'Tinggi':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  IconData _getRiskIcon(String riskLevel) {
    switch (riskLevel) {
      case 'Rendah':
        return Icons.sentiment_very_satisfied;
      case 'Sedang':
        return Icons.sentiment_neutral;
      case 'Tinggi':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.psychology;
    }
  }
}
