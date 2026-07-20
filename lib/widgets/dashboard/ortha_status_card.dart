import 'package:flutter/material.dart';

import '../../models/ortha_status_model.dart';
import '../../theme/ortha_colors.dart';
import '../../theme/ortha_spacing.dart';
import '../../theme/ortha_status_colors.dart';
import '../../theme/ortha_text_styles.dart';
import '../ortha_ui/ortha_card.dart';

class OrthaStatusCard extends StatelessWidget {
  final OrthaStatusModel status;

  const OrthaStatusCard({super.key, required this.status});

  Color get _statusColor => OrthaStatusColors.forLevel(status.level);

  @override
  Widget build(BuildContext context) {
    return OrthaCard(
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
              const SizedBox(width: OrthaSpacing.medium),
              Expanded(
                child: Text(status.title, style: OrthaTextStyles.cardTitle),
              ),
            ],
          ),
          const SizedBox(height: OrthaSpacing.large),
          Text(status.statusText, style: OrthaTextStyles.statusTitle),
          const SizedBox(height: OrthaSpacing.section),
          _InfoRow(label: 'ORTHA-Analyse', value: status.riskText),
          const SizedBox(height: OrthaSpacing.medium),
          _InfoRow(label: 'Amtliche Warnungen', value: status.warningText),
          const SizedBox(height: OrthaSpacing.medium),
          _InfoRow(label: 'Ort', value: status.location),
          const SizedBox(height: OrthaSpacing.section),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(OrthaSpacing.large),
            decoration: BoxDecoration(
              color: OrthaColors.informationBackground,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: OrthaColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kurzbewertung',
                  style: OrthaTextStyles.informationLabel,
                ),
                const SizedBox(height: OrthaSpacing.small),
                Text(status.recommendation, style: OrthaTextStyles.body),
              ],
            ),
          ),
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
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 420) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: OrthaTextStyles.informationLabel),
              const SizedBox(height: OrthaSpacing.xSmall),
              Text(value, style: OrthaTextStyles.informationValue),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 148,
              child: Text(label, style: OrthaTextStyles.informationLabel),
            ),
            const SizedBox(width: OrthaSpacing.small),
            Expanded(
              child: Text(value, style: OrthaTextStyles.informationValue),
            ),
          ],
        );
      },
    );
  }
}
