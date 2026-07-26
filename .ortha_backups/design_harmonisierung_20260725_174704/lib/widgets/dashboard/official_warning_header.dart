import 'package:flutter/material.dart';

import '../../models/official_weather_warning.dart';
import '../../theme/ortha_colors.dart';

class OfficialWarningHeader extends StatelessWidget {
  final OfficialWeatherWarning warning;
  final Color color;
  final IconData sourceIcon;
  final String sourceLabel;
  final String severityLabel;

  const OfficialWarningHeader({
    super.key,
    required this.warning,
    required this.color,
    required this.sourceIcon,
    required this.sourceLabel,
    required this.severityLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.16),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Icon(Icons.warning_amber_rounded, color: color, size: 30),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: OrthaColors.surfaceElevated,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: color.withValues(alpha: 0.55)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(sourceIcon, size: 15, color: color),
                        const SizedBox(width: 6),
                        Text(
                          sourceLabel,
                          style: TextStyle(
                            color: color,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    severityLabel,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                warning.title,
                style: const TextStyle(
                  color: OrthaColors.primaryText,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
