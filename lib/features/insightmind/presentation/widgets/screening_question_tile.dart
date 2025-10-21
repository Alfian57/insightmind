import 'package:flutter/material.dart';
import 'package:insightmind/features/insightmind/domain/entities/question.dart';

class ScreeningQuestionTile extends StatelessWidget {
  const ScreeningQuestionTile({
    super.key,
    required this.question,
    required this.selectedScore,
    required this.onSelected,
  });

  final Question question;
  final int? selectedScore;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question.text, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Column(
          children: [
            for (final opt in question.options)
              RadioListTile<int>(
                value: opt.score,
                groupValue: selectedScore,
                onChanged: (value) {
                  if (value != null) onSelected(value);
                },
                title: Text(opt.label),
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
          ],
        ),
      ],
    );
  }
}
