import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Zentraler Premium-Hintergrund von ORTHA METEO Ω.
///
/// Der Hintergrund besteht vollständig aus skalierbaren Flutter-Layern:
///
/// - tiefes Navy als Grundfläche,
/// - weiche blaue Lichtfelder,
/// - dezente goldene Reflexe,
/// - eine leichte Randabdunklung,
/// - feines, statisches Filmkorn.
///
/// Dadurch bleibt die Darstellung auf Android, iOS, macOS und Web
/// unabhängig von Auflösung und Seitenverhältnis hochwertig.
class OrthaMeteoBackground extends StatelessWidget {
  const OrthaMeteoBackground({required this.child, super.key});

  final Widget child;

  static const Color _deepNavy = Color(0xFF020A12);
  static const Color _navy = Color(0xFF061522);
  static const Color _midnightBlue = Color(0xFF0A2032);
  static const Color _orthaGold = Color(0xFFFFB536);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _deepNavy,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const _BaseGradient(),

          // Kühler Lichtschein im oberen Bereich.
          const Positioned(
            top: -190,
            left: -100,
            right: -100,
            height: 520,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.15),
                    radius: 0.82,
                    colors: [
                      Color(0x3D164A72),
                      Color(0x1F0D304B),
                      Color(0x00020A12),
                    ],
                    stops: [0, 0.48, 1],
                  ),
                ),
              ),
            ),
          ),

          // Linkes, blaues Umgebungslicht.
          const Positioned(
            top: 250,
            left: -230,
            width: 540,
            height: 720,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.75,
                    colors: [
                      Color(0x291B5D88),
                      Color(0x120E3855),
                      Color(0x00020A12),
                    ],
                    stops: [0, 0.5, 1],
                  ),
                ),
              ),
            ),
          ),

          // Rechtes, sehr dezentes Lichtfeld.
          const Positioned(
            top: 150,
            right: -260,
            width: 600,
            height: 780,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.78,
                    colors: [
                      Color(0x24144262),
                      Color(0x0F0B2B42),
                      Color(0x00020A12),
                    ],
                    stops: [0, 0.52, 1],
                  ),
                ),
              ),
            ),
          ),

          // Goldener Lichtschein unterhalb des Headers.
          const Positioned(
            top: 300,
            left: -40,
            right: -40,
            height: 280,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0.35),
                    radius: 0.82,
                    colors: [
                      Color(0x24FFB536),
                      Color(0x0CFFB536),
                      Color(0x00020A12),
                    ],
                    stops: [0, 0.42, 1],
                  ),
                ),
              ),
            ),
          ),

          // Goldener Reflex im unteren Inhaltsbereich.
          const Positioned(
            bottom: -250,
            left: -100,
            right: -100,
            height: 630,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, 0.3),
                    radius: 0.82,
                    colors: [
                      Color(0x1FFFAC2F),
                      Color(0x0BFFAC2F),
                      Color(0x00020A12),
                    ],
                    stops: [0, 0.4, 1],
                  ),
                ),
              ),
            ),
          ),

          // Sehr feine diagonale Lichtstruktur.
          const Positioned.fill(
            child: IgnorePointer(child: _AtmosphericLines()),
          ),

          // Statisches Filmkorn, verhindert sterile Farbflächen.
          const Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _NoisePainter()),
              ),
            ),
          ),

          // Sanfte Vignette zur optischen Zentrierung.
          const Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -0.12),
                    radius: 1.04,
                    colors: [
                      Colors.transparent,
                      Color(0x15000000),
                      Color(0x52000000),
                    ],
                    stops: [0, 0.68, 1],
                  ),
                ),
              ),
            ),
          ),

          // Inhalt der App.
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _BaseGradient extends StatelessWidget {
  const _BaseGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            OrthaMeteoBackground._midnightBlue,
            OrthaMeteoBackground._navy,
            OrthaMeteoBackground._deepNavy,
            Color(0xFF03101A),
          ],
          stops: [0, 0.34, 0.72, 1],
        ),
      ),
    );
  }
}

class _AtmosphericLines extends StatelessWidget {
  const _AtmosphericLines();

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x00FFFFFF), Color(0x0DFFFFFF), Color(0x00FFFFFF)],
          stops: [0.12, 0.5, 0.88],
        ).createShader(bounds);
      },
      child: CustomPaint(painter: _AtmosphericLinePainter()),
    );
  }
}

class _AtmosphericLinePainter extends CustomPainter {
  const _AtmosphericLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.45
      ..style = PaintingStyle.stroke;

    const double spacing = 72;

    for (double offset = -size.height; offset < size.width; offset += spacing) {
      canvas.drawLine(
        Offset(offset, size.height),
        Offset(offset + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AtmosphericLinePainter oldDelegate) => false;
}

class _NoisePainter extends CustomPainter {
  const _NoisePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(27072026);
    final Paint paint = Paint();

    final int particleCount = math.min(
      560,
      math.max(260, (size.width * size.height / 1900).round()),
    );

    for (int index = 0; index < particleCount; index++) {
      final double x = random.nextDouble() * size.width;
      final double y = random.nextDouble() * size.height;
      final double radius = 0.18 + random.nextDouble() * 0.55;
      final int alpha = 4 + random.nextInt(9);

      paint.color = index.isEven
          ? Colors.white.withAlpha(alpha)
          : OrthaMeteoBackground._orthaGold.withAlpha(alpha ~/ 2);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _NoisePainter oldDelegate) => false;
}
