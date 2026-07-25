import 'package:flutter/material.dart';

import '../../theme/ortha_colors.dart';

/// Kompatibilitätspalette für bereits bestehende ORTHA-Komponenten.
///
/// Neue Oberflächen sollen bevorzugt direkt [OrthaColors] verwenden.
/// Die Bezeichnungen bleiben vorerst bestehen, damit ältere Widgets
/// schrittweise und ohne Funktionsverlust migriert werden können.
abstract final class OrthaDesignColors {
  static const Color cream = OrthaColors.surface;
  static const Color creamSoft = OrthaColors.surfaceElevated;
  static const Color creamDeep = OrthaColors.informationBackground;

  static const Color navy = OrthaColors.primaryText;
  static const Color navySoft = OrthaColors.secondaryText;

  static const Color gold = OrthaColors.accent;
  static const Color goldSoft = Color(0xFFB8913C);

  static const Color blue = Color(0xFF66B7E8);
  static const Color blueDark = Color(0xFF3B91C8);

  static const Color red = Color(0xFFFF6B64);

  static const Color greyLight = Color(0xFFB8C3CD);
  static const Color grey = Color(0xFF81909D);
  static const Color greyDark = OrthaColors.secondaryText;

  static const Color white = OrthaColors.primaryText;
  static const Color black = OrthaColors.primaryText;
}

/// Zentrale dunkle ORTHA-Glass-Card.
///
/// Hintergrund, Rand, Radius und Schatten werden hier einheitlich definiert.
/// Dadurch verwenden Wetter, Radar, Pollen und Warnungen dieselbe Designsprache.
class OrthaPremiumCard extends StatelessWidget {
  const OrthaPremiumCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: OrthaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: OrthaColors.accent.withValues(alpha: 0.42),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: OrthaColors.shadow.withValues(alpha: 0.55),
            blurRadius: 24,
            spreadRadius: 0,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: OrthaColors.accent.withValues(alpha: 0.045),
            blurRadius: 18,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}
