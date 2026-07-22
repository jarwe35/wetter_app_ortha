import 'package:flutter/material.dart';

import 'ortha_map_shell.dart';

/// Übergangsadapter für bestehende Kartenansichten von ORTHA METEO Ω.
///
/// Neue Kartenmodule sollen unmittelbar [OrthaMapShell] verwenden.
/// Bestehende Seiten können vorübergehend weiterhin [OrthaMapLayout] nutzen.
///
/// Der Adapter übersetzt:
///
/// - [map] in die vollflächige Kartenebene
/// - [header] in die schwebende obere Informationsleiste
/// - [footer] in die schwebende Zeit- oder Detailsteuerung
/// - [mapControls] in die rechte Kartensteuerung
///
/// Fachliche Kartenlogik wird hier nicht verarbeitet.
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

  /// Eigentliche Kartenansicht.
  final Widget map;

  /// Schwebender Informationsbereich oberhalb der Karte.
  final Widget? header;

  /// Schwebende Zeitachse, Legende oder Detailsteuerung.
  final Widget? footer;

  /// Unmittelbar erforderliche Kartenbedienelemente.
  final Widget? mapControls;

  /// Für die Übergangsphase beibehaltene API-Eigenschaften.
  ///
  /// Die vollflächige [OrthaMapShell] verwendet eigene feste Positionierungen.
  final EdgeInsetsGeometry padding;
  final double sectionSpacing;
  final double borderRadius;
  final double minimumMapHeight;
  final double maximumContentWidth;
  final bool expandMap;

  @override
  Widget build(BuildContext context) {
    return OrthaMapShell(
      safeAreaTop: true,
      safeAreaBottom: true,
      map: map,
      topBar: header == null
          ? null
          : Padding(
              key: const Key('ortha-map-layout-header'),
              padding: _topBarPadding,
              child: _constrainContent(header!),
            ),
      trailingControls: mapControls == null
          ? null
          : KeyedSubtree(
              key: const Key('ortha-map-layout-controls'),
              child: mapControls!,
            ),
      timeline: footer == null
          ? null
          : Padding(
              key: const Key('ortha-map-layout-footer'),
              padding: _timelinePadding,
              child: _constrainContent(footer!),
            ),
    );
  }

  EdgeInsetsGeometry get _topBarPadding {
    return EdgeInsets.only(
      left: _horizontalPadding,
      top: _verticalPadding,
      right: _horizontalPadding,
    );
  }

  EdgeInsetsGeometry get _timelinePadding {
    return EdgeInsets.only(
      left: _horizontalPadding,
      right: _horizontalPadding,
      bottom: _verticalPadding,
    );
  }

  double get _horizontalPadding {
    if (padding is EdgeInsets) {
      final resolvedPadding = padding as EdgeInsets;
      return resolvedPadding.left > resolvedPadding.right
          ? resolvedPadding.left
          : resolvedPadding.right;
    }

    return 16;
  }

  double get _verticalPadding {
    if (padding is EdgeInsets) {
      final resolvedPadding = padding as EdgeInsets;
      return resolvedPadding.top > resolvedPadding.bottom
          ? resolvedPadding.top
          : resolvedPadding.bottom;
    }

    return 16;
  }

  Widget _constrainContent(Widget child) {
    if (!maximumContentWidth.isFinite) {
      return child;
    }

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maximumContentWidth),
        child: child,
      ),
    );
  }
}
