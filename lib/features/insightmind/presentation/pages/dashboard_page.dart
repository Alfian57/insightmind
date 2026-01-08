import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/ai_prediction_provider.dart';
import '../providers/history_providers.dart';

/// Dashboard Page - Halaman utama untuk mHealth analytics
///
/// Urutan tampilan:
/// 1. AI Insight Box (rekomendasi/edukasi)
/// 2. Trend Chart (Line Chart riwayat skor)
/// 3. Statistik ringkasan
/// 4. Detail riwayat
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh data
              ref.invalidate(aiPredictionProvider);
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. AI Insight Box
            _AIInsightBox(),
            SizedBox(height: 20),

            // 2. Trend Chart
            _TrendChartSection(),
            SizedBox(height: 20),

            // 3. Statistik
            _StatisticsSection(),
            SizedBox(height: 20),

            // 4. Detail Riwayat
            _HistoryDetailSection(),
          ],
        ),
      ),
    );
  }
}

/// Widget untuk menampilkan AI Insight/Rekomendasi
class _AIInsightBox extends ConsumerWidget {
  const _AIInsightBox();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prediction = ref.watch(aiPredictionProvider);
    final completeness = ref.watch(dataCompletenessProvider);
    final theme = Theme.of(context);

    // Tentukan warna berdasarkan risiko
    Color cardColor;
    Color textColor;
    IconData iconData;

    switch (prediction.riskLevel) {
      case 'Tinggi':
        cardColor = Colors.red[50]!;
        textColor = Colors.red[800]!;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'Sedang':
        cardColor = Colors.orange[50]!;
        textColor = Colors.orange[800]!;
        iconData = Icons.info_outline;
        break;
      case 'Rendah':
        cardColor = Colors.green[50]!;
        textColor = Colors.green[800]!;
        iconData = Icons.check_circle_outline;
        break;
      default:
        cardColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        iconData = Icons.psychology;
    }

    return Card(
      color: cardColor,
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, color: textColor, size: 28),
                const SizedBox(width: 12),
                Text(
                  'AI Insight',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: textColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    prediction.riskLevel,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              prediction.riskDescription,
              style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InsightMetric(
                  label: 'Skor',
                  value: prediction.score.toStringAsFixed(1),
                  color: textColor,
                ),
                const SizedBox(width: 24),
                _InsightMetric(
                  label: 'Confidence',
                  value: prediction.confidencePercentage,
                  color: textColor,
                ),
                const SizedBox(width: 24),
                _InsightMetric(
                  label: 'Data',
                  value:
                      '${(completeness.completenessPercentage * 100).toStringAsFixed(0)}%',
                  color: textColor,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Edukasi singkat
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 Tips Hari Ini',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getEducationalTip(prediction.riskLevel),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getEducationalTip(String riskLevel) {
    switch (riskLevel) {
      case 'Tinggi':
        return 'Pertimbangkan untuk berbicara dengan profesional kesehatan mental. '
            'Ingat, meminta bantuan adalah tanda kekuatan, bukan kelemahan.';
      case 'Sedang':
        return 'Luangkan waktu untuk aktivitas yang Anda nikmati. '
            'Olahraga ringan 30 menit sehari dapat membantu memperbaiki mood.';
      case 'Rendah':
        return 'Pertahankan kebiasaan baik Anda! Tidur yang cukup dan '
            'menjaga koneksi sosial penting untuk kesehatan mental.';
      default:
        return 'Lakukan screening untuk mendapatkan insight personal tentang '
            'kondisi kesehatan mental Anda.';
    }
  }
}

/// Widget untuk metric di insight box
class _InsightMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _InsightMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: color.withOpacity(0.7)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Section untuk Trend Chart
class _TrendChartSection extends ConsumerWidget {
  const _TrendChartSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.show_chart, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Tren Perkembangan',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: historyAsync.when(
                data: (historyList) {
                  if (historyList.isEmpty) {
                    return const Center(
                      child: Text(
                        'Belum ada data riwayat.\nLakukan screening untuk memulai.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  // Ambil 7 data terakhir untuk chart
                  final chartData = historyList
                      .take(7)
                      .toList()
                      .reversed
                      .toList();

                  return _buildLineChart(chartData);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              ),
            ),
            const SizedBox(height: 8),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(color: Colors.green, label: 'Rendah (<12)'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.orange, label: 'Sedang (12-25)'),
                const SizedBox(width: 16),
                _LegendItem(color: Colors.red, label: 'Tinggi (>25)'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List<dynamic> data) {
    final spots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      // Asumsi item memiliki property score
      final score = (item.score as num?)?.toDouble() ?? 0.0;
      spots.add(FlSpot(i.toDouble(), score));
    }

    if (spots.isEmpty) {
      return const Center(child: Text('Tidak ada data'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 10,
          getDrawingHorizontalLine: (value) {
            Color lineColor = Colors.grey[300]!;
            if (value == 12) lineColor = Colors.orange.withOpacity(0.5);
            if (value == 25) lineColor = Colors.red.withOpacity(0.5);
            return FlLine(color: lineColor, strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  final item = data[index];
                  final date = item.timestamp as DateTime?;
                  if (date != null) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        DateFormat('d/M').format(date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 10,
              reservedSize: 35,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: 35,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Colors.blue, Colors.purple],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) {
                Color dotColor;
                if (spot.y > 25) {
                  dotColor = Colors.red;
                } else if (spot.y >= 12) {
                  dotColor = Colors.orange;
                } else {
                  dotColor = Colors.green;
                }
                return FlDotCirclePainter(
                  radius: 5,
                  color: dotColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.2),
                  Colors.purple.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  'Skor: ${spot.y.toStringAsFixed(1)}',
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }
}

/// Legend item widget
class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

/// Section untuk Statistik
class _StatisticsSection extends ConsumerWidget {
  const _StatisticsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.analytics, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  'Statistik',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            historyAsync.when(
              data: (historyList) {
                if (historyList.isEmpty) {
                  return const Center(child: Text('Belum ada data statistik'));
                }

                // Hitung statistik
                final scores = historyList
                    .map((h) => (h.score as num?)?.toDouble() ?? 0.0)
                    .toList();

                final avgScore = scores.reduce((a, b) => a + b) / scores.length;
                final minScore = scores.reduce((a, b) => a < b ? a : b);
                final maxScore = scores.reduce((a, b) => a > b ? a : b);
                final totalScreenings = historyList.length;

                // Hitung distribusi risiko
                int lowCount = 0, medCount = 0, highCount = 0;
                for (final score in scores) {
                  if (score > 25) {
                    highCount++;
                  } else if (score >= 12) {
                    medCount++;
                  } else {
                    lowCount++;
                  }
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.assessment,
                            label: 'Total Screening',
                            value: totalScreenings.toString(),
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.trending_flat,
                            label: 'Rata-rata',
                            value: avgScore.toStringAsFixed(1),
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _StatCard(
                            icon: Icons.arrow_downward,
                            label: 'Terendah',
                            value: minScore.toStringAsFixed(1),
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatCard(
                            icon: Icons.arrow_upward,
                            label: 'Tertinggi',
                            value: maxScore.toStringAsFixed(1),
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Distribusi risiko
                    Text(
                      'Distribusi Risiko',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: lowCount > 0 ? lowCount : 1,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.horizontal(
                                left: const Radius.circular(4),
                                right: medCount == 0 && highCount == 0
                                    ? const Radius.circular(4)
                                    : Radius.zero,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              lowCount > 0 ? '$lowCount' : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: medCount > 0 ? medCount : 1,
                          child: Container(
                            height: 24,
                            color: Colors.orange,
                            alignment: Alignment.center,
                            child: Text(
                              medCount > 0 ? '$medCount' : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: highCount > 0 ? highCount : 1,
                          child: Container(
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.horizontal(
                                left: lowCount == 0 && medCount == 0
                                    ? const Radius.circular(4)
                                    : Radius.zero,
                                right: const Radius.circular(4),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              highCount > 0 ? '$highCount' : '',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stat card widget
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

/// Section untuk Detail Riwayat
class _HistoryDetailSection extends ConsumerWidget {
  const _HistoryDetailSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.teal),
                const SizedBox(width: 8),
                Text(
                  'Riwayat Terbaru',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/history');
                  },
                  child: const Text('Lihat Semua'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            historyAsync.when(
              data: (historyList) {
                if (historyList.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: Text('Belum ada riwayat screening')),
                  );
                }

                // Tampilkan 5 terbaru
                final recentHistory = historyList.take(5).toList();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentHistory.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = recentHistory[index];
                    final score = (item.score as num?)?.toDouble() ?? 0.0;
                    final date = item.timestamp as DateTime?;
                    final riskLevel = item.riskLevel as String? ?? 'Unknown';

                    Color riskColor;
                    if (score > 25) {
                      riskColor = Colors.red;
                    } else if (score >= 12) {
                      riskColor = Colors.orange;
                    } else {
                      riskColor = Colors.green;
                    }

                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: riskColor.withOpacity(0.2),
                        child: Text(
                          score.toStringAsFixed(0),
                          style: TextStyle(
                            color: riskColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        'Risiko $riskLevel',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: riskColor,
                        ),
                      ),
                      subtitle: Text(
                        date != null
                            ? DateFormat('EEEE, d MMMM yyyy HH:mm').format(date)
                            : 'Tanggal tidak tersedia',
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ],
        ),
      ),
    );
  }
}
