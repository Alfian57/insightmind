import 'package:flutter/material.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_stat_chip.dart';

class SummaryHeader extends StatelessWidget {
  const SummaryHeader({super.key, required this.total, required this.answered});

  final int total;
  final int answered;

  @override
  Widget build(BuildContext context) {
    final totalStr = total.toString();
    final dijawabStr = answered.toString();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            SummaryStatChip(
              label: 'Total Pertanyaan',
              value: totalStr,
              color: Colors.indigo,
            ),
            SummaryStatChip(
              label: 'Dijawab',
              value: dijawabStr,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}
