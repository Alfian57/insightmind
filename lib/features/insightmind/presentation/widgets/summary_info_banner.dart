import 'package:flutter/material.dart';

class SummaryInfoBanner extends StatelessWidget {
  const SummaryInfoBanner({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.indigo.withAlpha((0.08 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.indigo.withAlpha((0.25 * 255).toInt()),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: Colors.indigo),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(color: scheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
