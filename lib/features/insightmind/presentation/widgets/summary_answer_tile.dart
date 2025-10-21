import 'package:flutter/material.dart';
import 'package:insightmind/features/insightmind/presentation/widgets/summary_answer.dart';

class SummaryAnswerTile extends StatelessWidget {
  const SummaryAnswerTile({super.key, required this.summary});

  final SummaryAnswer summary;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withAlpha((0.12 * 255).toInt()),
          child: Text(
            '${summary.number}',
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        title: Text(summary.question),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text('Jawaban Anda: ${summary.answer}'),
        ),
      ),
    );
  }
}
