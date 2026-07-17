import 'package:flutter/material.dart';

import '../../models/ortha_status_model.dart';

class OrthaStatusCard extends StatelessWidget {
  final OrthaStatusModel status;

  const OrthaStatusCard({super.key, required this.status});

  Color get _statusColor {
    switch (status.level) {
      case OrthaStatusLevel.green:
        return const Color(0xFF4CAF50);

      case OrthaStatusLevel.yellow:
        return const Color(0xFFFBC02D);

      case OrthaStatusLevel.orange:
        return const Color(0xFFFF9800);

      case OrthaStatusLevel.red:
        return const Color(0xFFD32F2F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFD3E2EC)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _statusColor,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                status.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            status.statusText,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          _InfoRow(label: 'Risiko', value: status.riskText),
          const SizedBox(height: 8),
          _InfoRow(label: 'Warnungen', value: status.warningText),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }
}
