import 'package:flutter/material.dart';

import '../../widgets/maps/ortha_map_shell.dart';

/// Eigenständige Vollbild-Kartenoberfläche von ORTHA METEO Ω.
///
/// Diese Seite enthält keine fachliche Wetter- oder Kartenlogik.
/// Kartenmodule wie Satellit, Radar, Warnungen oder Wind liefern ihre
/// jeweiligen Inhalte über die vorgesehenen Slots.
///
/// Die Karte füllt den gesamten verfügbaren Seitenbereich. Header,
/// Werkzeugleisten, Zeitachsen und weitere Informationen werden als
/// schwebende Ebenen darüber dargestellt.
class OrthaFullscreenMapPage extends StatelessWidget {
  const OrthaFullscreenMapPage({
    super.key,
    required this.map,
    this.topBar,
    this.search,
    this.leadingControls,
    this.trailingControls,
    this.timeline,
    this.bottomNavigation,
    this.overlay,
    this.backgroundColor = const Color(0xFF071018),
    this.safeAreaTop = true,
    this.safeAreaBottom = true,
  });

  /// Vollflächige Karte oder Kartenkomposition.
  final Widget map;

  /// Oberer schwebender Informations- und Navigationsbereich.
  final Widget? topBar;

  /// Optionale Karten- oder Standortsuche.
  final Widget? search;

  /// Linke Kartensteuerung oder Legende.
  final Widget? leadingControls;

  /// Rechte Kartensteuerung, beispielsweise Zoom und Standort.
  final Widget? trailingControls;

  /// Zeitachse oder Wiedergabesteuerung.
  final Widget? timeline;

  /// Optionale untere Modulnavigation.
  final Widget? bottomNavigation;

  /// Zusätzliche frei positionierbare Kartenebene.
  final Widget? overlay;

  final Color backgroundColor;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('ortha-fullscreen-map-page'),
      backgroundColor: backgroundColor,
      body: OrthaMapShell(
        map: map,
        topBar: topBar,
        search: search,
        leadingControls: leadingControls,
        trailingControls: trailingControls,
        timeline: timeline,
        bottomNavigation: bottomNavigation,
        overlay: overlay,
        backgroundColor: backgroundColor,
        safeAreaTop: safeAreaTop,
        safeAreaBottom: safeAreaBottom,
      ),
    );
  }
}
