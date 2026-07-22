import 'package:flutter/material.dart';

/// Einheitliches Layout für sämtliche Kartenansichten in ORTHA METEO Ω.
///
/// Aufbau:
/// 1. Informationsbereich oberhalb der Karte
/// 2. freie Kartenfläche
/// 3. Zeitsteuerung, Legende oder Detailsteuerung unterhalb der Karte
///
/// Innerhalb der Karte dürfen nur unmittelbar notwendige Bedienelemente
/// eingeblendet werden, beispielsweise Zoom, Standort und Layer-Auswahl.
class OrthaMapLayout extends StatelessWidget {
  const OrthaMapLayout({
    super.key,
    required this.map,
    this.header,
    this.footer,
    this.mapControls,
    this.padding = const EdgeInsets.all(16),
    this.sectionSpacing = 12,
    this.borderRadius = 18,
    this.minimumMapHeight = 320,
    this.maximumContentWidth = 1100,
    this.expandMap = true,
  });

  /// Eigentliche Kartenansicht, beispielsweise ein [FlutterMap]-Widget.
  final Widget map;

  /// Informationsbereich oberhalb der Karte.
  final Widget? header;

  /// Zeitachse, Legende oder Detailsteuerung unterhalb der Karte.
  final Widget? footer;

  /// Ausschließlich kleine, unmittelbar notwendige Bedienelemente.
  final Widget? mapControls;

  final EdgeInsetsGeometry padding;
  final double sectionSpacing;
  final double borderRadius;
  final double minimumMapHeight;
  final double maximumContentWidth;
  final bool expandMap;

  @override
  Widget build(BuildContext context) {
    final mapSurface = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Stack(fit: StackFit.expand, children: [map, ?mapControls]),
    );

    final mapSection = expandMap
        ? Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minimumMapHeight),
              child: mapSurface,
            ),
          )
        : Flexible(
            fit: FlexFit.loose,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minimumMapHeight),
              child: AspectRatio(aspectRatio: 4 / 3, child: mapSurface),
            ),
          );

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maximumContentWidth),
          child: Padding(
            padding: padding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (header != null) ...[
                  header!,
                  SizedBox(height: sectionSpacing),
                ],
                mapSection,
                if (footer != null) ...[
                  SizedBox(height: sectionSpacing),
                  footer!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
