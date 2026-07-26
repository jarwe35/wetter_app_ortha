import 'package:flutter/material.dart';

import '../../theme/ortha_colors.dart';

class OfficialWarningInstruction extends StatelessWidget {
  final String instruction;

  const OfficialWarningInstruction({super.key, required this.instruction});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: OrthaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: OrthaColors.border.withValues(alpha: 0.72)),
      ),
      child: Text(
        'Amtliche Handlungsempfehlung:\n$instruction',
        style: const TextStyle(
          color: OrthaColors.primaryText,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
