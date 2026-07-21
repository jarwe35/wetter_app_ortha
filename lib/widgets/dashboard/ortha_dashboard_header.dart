import 'package:flutter/material.dart';

import '../ortha_ui/ortha_responsive.dart';

class OrthaDashboardHeader extends StatelessWidget {
  final VoidCallback onOpenLocations;
  final VoidCallback onOpenUnitSettings;

  const OrthaDashboardHeader({
    super.key,
    required this.onOpenLocations,
    required this.onOpenUnitSettings,
  });

  static const Color _surface = Color(0xFFFFFFFF);
  static const Color _primaryText = Color(0xFF163247);
  static const Color _secondaryText = Color(0xFF587080);
  static const Color _accent = Color(0xFFD5A84A);
  static const Color _border = Color(0xFFD3E2EC);

  @override
  Widget build(BuildContext context) {
    final ui = OrthaResponsive.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(ui.cardPadding),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(ui.cardRadius),
        border: Border.all(color: _border.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 430;

          final identity = Row(
            children: [
              Container(
                width: ui.sectionIconSize,
                height: ui.sectionIconSize,
                decoration: BoxDecoration(
                  color: _accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(ui.cardRadius * 0.6),
                  border: Border.all(color: _accent.withValues(alpha: 0.35)),
                ),
                child: Icon(
                  Icons.cloud_outlined,
                  color: _accent,
                  size: ui.iconSize,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ORTHA METEO Ω',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        color: _primaryText,
                      ),
                    ),
                    Text(
                      'Wetter · Warnungen · Risiko',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: _secondaryText),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Einheiten',
                onPressed: onOpenUnitSettings,
                icon: const Icon(Icons.straighten_outlined),
              ),
            ],
          );

          final locationsButton = OutlinedButton.icon(
            onPressed: onOpenLocations,
            icon: const Icon(Icons.location_city_outlined),
            label: const Text('Meine Orte'),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                identity,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: locationsButton),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16),
              locationsButton,
            ],
          );
        },
      ),
    );
  }
}
