import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../insightmind/data/local/screening_record.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(historyListProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: historyAsync.when(
        data: (records) => _DashboardContent(records: records),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final List<ScreeningRecord> records;

  const _DashboardContent({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (records.isEmpty) {
      return _EmptyDashboard();
    }

    // Calculate statistics
    final latestRecord = records.first;
    final averageScore = records.isEmpty
        ? 0.0
        : records.map((r) => r.score).reduce((a, b) => a + b) / records.length;
    final highRiskCount =
        records.where((r) => r.riskLevel == 'Tinggi').length;
    final trend = _calculateTrend(records);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Latest Result Card
          _LatestResultCard(record: latestRecord),
          const SizedBox(height: 20),

          // Statistics Grid
          Text('Statistik', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Total Screening',
                  value: '${records.length}',
                  icon: Icons.quiz_outlined,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Rata-rata Skor',
                  value: averageScore.toStringAsFixed(1),
                  icon: Icons.analytics_outlined,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: 'Risiko Tinggi',
                  value: '$highRiskCount',
                  icon: Icons.warning_amber_outlined,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: 'Tren',
                  value: trend,
                  icon: trend == 'Membaik'
                      ? Icons.trending_up
                      : trend == 'Menurun'
                          ? Icons.trending_down
                          : Icons.trending_flat,
                  color: trend == 'Membaik'
                      ? AppColors.success
                      : trend == 'Menurun'
                          ? AppColors.error
                          : AppColors.info,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Trend Chart
          if (records.length >= 2) ...[
            Text('Grafik Tren', style: theme.textTheme.titleMedium),
            const SizedBox(height: 12),
            _TrendChart(records: records),
            const SizedBox(height: 24),
          ],

          // Risk Distribution
          Text('Distribusi Risiko', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          _RiskDistributionChart(records: records),
          const SizedBox(height: 24),

          // Recent History
          Text('Riwayat Terbaru', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          ...records.take(5).map((r) => _HistoryItem(record: r)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  String _calculateTrend(List<ScreeningRecord> records) {
    if (records.length < 2) return 'Stabil';

    final recent = records.take(3).map((r) => r.score).toList();
    final older = records.skip(3).take(3).map((r) => r.score).toList();

    if (older.isEmpty) return 'Stabil';

    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;
    final olderAvg = older.reduce((a, b) => a + b) / older.length;

    if (recentAvg < olderAvg - 2) return 'Membaik';
    if (recentAvg > olderAvg + 2) return 'Menurun';
    return 'Stabil';
  }
}

class _EmptyDashboard extends StatelessWidget {
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
                Icons.dashboard_outlined,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Data',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Lakukan screening pertama Anda untuk melihat statistik dan insight di dashboard.',
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

class _LatestResultCard extends StatelessWidget {
  final ScreeningRecord record;

  const _LatestResultCard({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final riskColor = _getRiskColor(record.riskLevel);

    return AppCard(
      gradientColors: [
        riskColor.withOpacity(0.15),
        riskColor.withOpacity(0.05),
      ],
      borderColor: riskColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: riskColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getRiskIcon(record.riskLevel),
                  color: riskColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hasil Terakhir',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(record.timestamp),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              AppRiskBadge(riskLevel: record.riskLevel),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skor',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      '${record.score}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                _getEncouragement(record.riskLevel),
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ],
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

  String _getEncouragement(String riskLevel) {
    switch (riskLevel) {
      case 'Rendah':
        return '🎉 Pertahankan!';
      case 'Sedang':
        return '💪 Tetap semangat!';
      case 'Tinggi':
        return '🤗 Anda tidak sendiri';
      default:
        return '';
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: color),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TrendChart extends StatelessWidget {
  final List<ScreeningRecord> records;

  const _TrendChart({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chartRecords = records.take(10).toList().reversed.toList();

    return AppCard(
      child: SizedBox(
        height: 200,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 5,
              getDrawingHorizontalLine: (value) => FlLine(
                color: theme.colorScheme.outlineVariant,
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) => Text(
                    value.toInt().toString(),
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ),
              rightTitles: const AxisTitles(),
              topTitles: const AxisTitles(),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= chartRecords.length) {
                      return const SizedBox();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('d/M')
                            .format(chartRecords[index].timestamp),
                        style: theme.textTheme.labelSmall,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: chartRecords.asMap().entries.map((entry) {
                  return FlSpot(
                    entry.key.toDouble(),
                    entry.value.score.toDouble(),
                  );
                }).toList(),
                isCurved: true,
                color: theme.colorScheme.primary,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: theme.colorScheme.primary,
                      strokeWidth: 2,
                      strokeColor: theme.colorScheme.surface,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: theme.colorScheme.primary.withOpacity(0.1),
                ),
              ),
            ],
            minY: 0,
            maxY: 30,
          ),
        ),
      ),
    );
  }
}

class _RiskDistributionChart extends StatelessWidget {
  final List<ScreeningRecord> records;

  const _RiskDistributionChart({required this.records});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final lowCount = records.where((r) => r.riskLevel == 'Rendah').length;
    final mediumCount = records.where((r) => r.riskLevel == 'Sedang').length;
    final highCount = records.where((r) => r.riskLevel == 'Tinggi').length;
    final total = records.length;

    return AppCard(
      child: Column(
        children: [
          _RiskBar(
            label: 'Rendah',
            count: lowCount,
            total: total,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _RiskBar(
            label: 'Sedang',
            count: mediumCount,
            total: total,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _RiskBar(
            label: 'Tinggi',
            count: highCount,
            total: total,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}

class _RiskBar extends StatelessWidget {
  final String label;
  final int count;
  final int total;
  final Color color;

  const _RiskBar({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = total > 0 ? count / total : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(label, style: theme.textTheme.bodySmall),
        ),
        Expanded(
          child: Container(
            height: 24,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            '$count',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final ScreeningRecord record;

  const _HistoryItem({required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getRiskColor(record.riskLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '${record.score}',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: _getRiskColor(record.riskLevel),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMMM yyyy').format(record.timestamp),
                  style: theme.textTheme.bodyMedium,
                ),
                Text(
                  DateFormat('HH:mm').format(record.timestamp),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          AppBadge(
            text: record.riskLevel,
            type: _getBadgeType(record.riskLevel),
            small: true,
          ),
        ],
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

  BadgeType _getBadgeType(String riskLevel) {
    switch (riskLevel) {
      case 'Rendah':
        return BadgeType.success;
      case 'Sedang':
        return BadgeType.warning;
      case 'Tinggi':
        return BadgeType.error;
      default:
        return BadgeType.info;
    }
  }
}
