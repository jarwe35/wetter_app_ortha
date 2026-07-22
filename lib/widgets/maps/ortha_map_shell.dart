import 'package:flutter/material.dart';

/// Zentrale visuelle Grundstruktur sämtlicher Kartenmodule von ORTHA METEO Ω.
///
/// Die Karte bildet die vollständige Hintergrundfläche. Alle Informationen
/// und Bedienelemente werden als kompakte, schwebende Ebenen darübergelegt.
///
/// Die Shell enthält keine fachliche Kartenlogik. Satellit, Radar, Wind,
/// Warnungen und weitere Module liefern ihre jeweiligen Inhalte über die
/// vorgesehenen Slots.
class OrthaMapShell extends StatelessWidget {
  const OrthaMapShell({
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

  /// Kompakter oberer Informations- und Navigationsbereich.
  final Widget? topBar;

  /// Optionale schwebende Standort- oder Kartensuche.
  final Widget? search;

  /// Linke Kartensteuerung, beispielsweise Layer oder Legende.
  final Widget? leadingControls;

  /// Rechte Kartensteuerung, beispielsweise Zoom und Standort.
  final Widget? trailingControls;

  /// Zeitachse oder Wiedergabesteuerung über dem unteren Rand.
  final Widget? timeline;

  /// Modulübergreifende untere Navigation.
  final Widget? bottomNavigation;

  /// Frei positionierbare zusätzliche Kartenebene.
  final Widget? overlay;

  final Color backgroundColor;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: backgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: RepaintBoundary(
              key: const Key('ortha-map-shell-map'),
              child: map,
            ),
          ),
          if (overlay != null)
            Positioned.fill(
              child: IgnorePointer(ignoring: false, child: overlay!),
            ),
          if (topBar != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(top: safeAreaTop, bottom: false, child: topBar!),
            ),
          if (search != null)
            Positioned(
              top: 72,
              left: 16,
              right: 16,
              child: SafeArea(top: false, bottom: false, child: search!),
            ),
          if (leadingControls != null)
            Positioned(
              left: 16,
              top: 154,
              bottom: 170,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: leadingControls!,
                ),
              ),
            ),
          if (trailingControls != null)
            Positioned(
              right: 16,
              top: 154,
              bottom: 170,
              child: SafeArea(
                top: false,
                bottom: false,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: trailingControls!,
                ),
              ),
            ),
          if (timeline != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: bottomNavigation == null ? 20 : 88,
              child: SafeArea(
                top: false,
                bottom: bottomNavigation == null && safeAreaBottom,
                child: timeline!,
              ),
            ),
          if (bottomNavigation != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                bottom: safeAreaBottom,
                child: bottomNavigation!,
              ),
            ),
        ],
      ),
    );
  }
}
