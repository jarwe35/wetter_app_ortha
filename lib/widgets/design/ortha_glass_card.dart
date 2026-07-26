import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wetter_app_ortha/theme/ortha_design_system.dart';

/// Dunkle, halbtransparente Premium-Karte von ORTHA METEO Ω.
class OrthaGlassCard extends StatelessWidget {
  const OrthaGlassCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = OrthaRadii.large,
    this.blur = 18,
    this.highlighted = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double blur;
  final bool highlighted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(borderRadius);

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(82),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          if (highlighted)
            BoxShadow(
              color: OrthaColors.gold.withAlpha(30),
              blurRadius: 30,
              spreadRadius: -8,
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: radius,
              splashColor: OrthaColors.gold.withAlpha(18),
              highlightColor: OrthaColors.gold.withAlpha(8),
              child: Ink(
                padding: padding,
                decoration: BoxDecoration(
                  borderRadius: radius,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      highlighted
                          ? const Color(0xD11A2B39)
                          : OrthaColors.glassStrong,
                      const Color(0xB50B1823),
                      const Color(0xD1051019),
                    ],
                    stops: const [0, 0.58, 1],
                  ),
                  border: Border.all(
                    color: highlighted
                        ? OrthaColors.borderGold
                        : OrthaColors.border,
                    width: highlighted ? 1.05 : 0.75,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -42,
                      left: -18,
                      right: -18,
                      height: 92,
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              radius: 0.9,
                              colors: [
                                Colors.white.withAlpha(14),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
