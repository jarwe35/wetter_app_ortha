import 'package:flutter/material.dart';

import '../../theme/ortha_colors.dart';

class OfficialWarningSummary extends StatelessWidget {
  final String summary;

  const OfficialWarningSummary({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: OrthaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: OrthaColors.border.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.summarize_outlined,
                size: 18,
                color: OrthaColors.accent,
              ),
              SizedBox(width: 8),
              Text(
                'Kurzinfo',
                style: TextStyle(
                  color: OrthaColors.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary,
            style: const TextStyle(color: OrthaColors.primaryText, height: 1.4),
          ),
        ],
      ),
    );
  }
}
