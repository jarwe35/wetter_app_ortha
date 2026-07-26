import 'package:flutter/material.dart';

import '../../design/ortha_light_engine.dart';

enum OrthaGlowIconStyle { gold, white, silver }

/// Scharfes ORTHA-Leuchtsymbol.
///
/// Der Effekt besteht bewusst nur aus:
/// 1. einem sehr dezenten äußeren Halo,
/// 2. einer engen farbigen Lichtkante,
/// 3. einem klaren und scharfen Symbolkern.
///
/// Dadurch entsteht sichtbares Licht, ohne dass das Symbol verschwimmt.
class OrthaGlowIcon extends StatelessWidget {
  const OrthaGlowIcon({
    super.key,
    required this.icon,
    this.size = 28,
    this.style = OrthaGlowIconStyle.gold,
    this.glow = OrthaLightEngine.normal,
    this.intensity = 1,
    this.enabled = true,
    this.color,
    this.semanticLabel,
  }) : assert(size > 0),
       assert(intensity >= 0);

  final IconData icon;
  final double size;
  final OrthaGlowIconStyle style;
  final OrthaGlowLevel glow;
  final double intensity;
  final bool enabled;
  final Color? color;
  final String? semanticLabel;

  Color get _mainColor {
    if (!enabled) {
      return OrthaLightEngine.inactive;
    }

    if (color != null) {
      return color!;
    }

    return switch (style) {
      OrthaGlowIconStyle.gold => OrthaLightEngine.gold,
      OrthaGlowIconStyle.white => OrthaLightEngine.white,
      OrthaGlowIconStyle.silver => OrthaLightEngine.silver,
    };
  }

  Color get _coreColor {
    if (!enabled) {
      return OrthaLightEngine.inactive;
    }

    return switch (style) {
      OrthaGlowIconStyle.gold => OrthaLightEngine.goldHighlight,
      OrthaGlowIconStyle.white => Colors.white,
      OrthaGlowIconStyle.silver => OrthaLightEngine.white,
    };
  }

  Color get _edgeColor {
    if (!enabled) {
      return OrthaLightEngine.inactive;
    }

    return switch (style) {
      OrthaGlowIconStyle.gold => OrthaLightEngine.gold,
      OrthaGlowIconStyle.white => OrthaLightEngine.white,
      OrthaGlowIconStyle.silver => OrthaLightEngine.silver,
    };
  }

  double _opacity(double value) {
    return (value * intensity).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = _mainColor;
    final coreColor = _coreColor;
    final edgeColor = _edgeColor;

    if (!enabled || intensity == 0) {
      return Icon(
        icon,
        size: size,
        color: mainColor,
        semanticLabel: semanticLabel,
      );
    }

    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Sehr kleiner äußerer Halo.
          //
          // Er bleibt bewusst eng am Symbol und darf nicht wie Nebel wirken.
          Icon(
            icon,
            size: size * 1.015,
            color: Colors.transparent,
            shadows: [
              Shadow(
                color: mainColor.withValues(
                  alpha: _opacity(glow.outerOpacity * 0.42),
                ),
                blurRadius: size * 0.16,
              ),
            ],
          ),

          // Enge farbige Lichtkante direkt am Symbol.
          Icon(
            icon,
            size: size * 1.01,
            color: edgeColor.withValues(alpha: _opacity(0.82)),
            shadows: [
              Shadow(
                color: edgeColor.withValues(alpha: _opacity(0.72)),
                blurRadius: size * 0.075,
              ),
            ],
          ),

          // Klarer Symbolkern.
          //
          // Nur kleine Schattenradien, damit die Kontur scharf bleibt.
          Icon(
            icon,
            size: size,
            color: coreColor,
            semanticLabel: semanticLabel,
            shadows: [
              Shadow(
                color: mainColor.withValues(alpha: _opacity(0.78)),
                blurRadius: size * 0.045,
              ),
              Shadow(
                color: Colors.white.withValues(alpha: _opacity(0.34)),
                blurRadius: 0.9,
                offset: const Offset(0, -0.45),
              ),
              Shadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 0.8,
                offset: const Offset(0, 0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
