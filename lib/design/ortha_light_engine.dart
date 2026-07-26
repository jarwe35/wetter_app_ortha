import 'package:flutter/material.dart';

/// Zentrale Licht- und Glow-Definitionen für ORTHA METEO Ω.
///
/// Alle Leuchteffekte werden hier gebündelt, damit Intensität,
/// Farbe und Tiefenwirkung appweit einheitlich bleiben.
abstract final class OrthaLightEngine {
  static const Color gold = Color(0xFFFFB83E);
  static const Color goldHighlight = Color(0xFFFFD77B);
  static const Color goldDeep = Color(0xFFD98A12);

  static const Color white = Color(0xFFF7F9FC);
  static const Color whiteHighlight = Colors.white;

  static const Color silver = Color(0xFFB7C1CF);
  static const Color inactive = Color(0xFF687587);

  static const OrthaGlowLevel subtle = OrthaGlowLevel(
    outerBlur: 12,
    outerOpacity: 0.20,
    middleBlur: 6,
    middleOpacity: 0.34,
    coreBlur: 2,
    coreOpacity: 0.42,
    scale: 1.03,
  );

  static const OrthaGlowLevel normal = OrthaGlowLevel(
    outerBlur: 20,
    outerOpacity: 0.28,
    middleBlur: 10,
    middleOpacity: 0.52,
    coreBlur: 4,
    coreOpacity: 0.68,
    scale: 1.06,
  );

  static const OrthaGlowLevel strong = OrthaGlowLevel(
    outerBlur: 28,
    outerOpacity: 0.36,
    middleBlur: 15,
    middleOpacity: 0.68,
    coreBlur: 6,
    coreOpacity: 0.82,
    scale: 1.09,
  );

  static const OrthaGlowLevel hero = OrthaGlowLevel(
    outerBlur: 36,
    outerOpacity: 0.46,
    middleBlur: 20,
    middleOpacity: 0.82,
    coreBlur: 8,
    coreOpacity: 0.96,
    scale: 1.12,
  );
}

class OrthaGlowLevel {
  final double outerBlur;
  final double outerOpacity;
  final double middleBlur;
  final double middleOpacity;
  final double coreBlur;
  final double coreOpacity;
  final double scale;

  const OrthaGlowLevel({
    required this.outerBlur,
    required this.outerOpacity,
    required this.middleBlur,
    required this.middleOpacity,
    required this.coreBlur,
    required this.coreOpacity,
    required this.scale,
  });
}
