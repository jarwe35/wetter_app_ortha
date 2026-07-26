import 'package:flutter/material.dart';

import '../../design/ortha_light_engine.dart';

enum OrthaGlowIconStyle { gold, white, silver }

class OrthaGlowIcon extends StatelessWidget {
  final IconData icon;
  final double size;
  final OrthaGlowIconStyle style;
  final OrthaGlowLevel glow;
  final double intensity;
  final bool enabled;
  final Color? color;
  final String? semanticLabel;

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

  Color get _highlightColor {
    return switch (style) {
      OrthaGlowIconStyle.gold => OrthaLightEngine.goldHighlight,
      OrthaGlowIconStyle.white => OrthaLightEngine.whiteHighlight,
      OrthaGlowIconStyle.silver => OrthaLightEngine.white,
    };
  }

  double _opacity(double value) {
    return (value * intensity).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = _mainColor;

    if (!enabled || intensity == 0) {
      return Icon(
        icon,
        size: size,
        color: mainColor,
        semanticLabel: semanticLabel,
      );
    }
    return SizedBox(
      width: size,
      height: size,

      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Ebene 1: großflächiger, diffuser Lichtschein.
          Icon(
            icon,
            size: size * glow.scale,
            color: mainColor.withValues(
              alpha: _opacity(glow.outerOpacity * 0.48),
            ),
            shadows: [
              Shadow(
                color: mainColor.withValues(alpha: _opacity(glow.outerOpacity)),
                blurRadius: glow.outerBlur,
              ),
            ],
          ),

          // Ebene 2: konzentrierter Lichtkörper.
          Icon(
            icon,
            size: size * 1.035,
            color: mainColor.withValues(
              alpha: _opacity(glow.middleOpacity * 0.55),
            ),
            shadows: [
              Shadow(
                color: mainColor.withValues(
                  alpha: _opacity(glow.middleOpacity),
                ),
                blurRadius: glow.middleBlur,
              ),
            ],
          ),

          // Ebene 3: scharfer und klarer Symbolkern.
          Icon(
            icon,
            size: size,
            color: mainColor,
            semanticLabel: semanticLabel,
            shadows: [
              Shadow(
                color: mainColor.withValues(alpha: _opacity(glow.coreOpacity)),
                blurRadius: glow.coreBlur,
              ),
              Shadow(
                color: _highlightColor.withValues(alpha: _opacity(0.48)),
                blurRadius: 2.4,
                offset: const Offset(0, -0.7),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
