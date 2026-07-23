import 'package:flutter/material.dart';

/// Verbindliche Farbwelt der hellen ORTHA-Tageskarten.
abstract final class OrthaDesignColors {
  static const Color cream = Color(0xFFFFFBF3);
  static const Color creamSoft = Color(0xFFFFF4DC);
  static const Color creamDeep = Color(0xFFF4E3BC);

  static const Color navy = Color(0xFF17374E);
  static const Color navySoft = Color(0xFF597080);

  static const Color gold = Color(0xFFD7A330);
  static const Color goldSoft = Color(0xFFE9C978);

  static const Color blue = Color(0xFF65A9D2);
  static const Color blueDark = Color(0xFF327EA9);

  static const Color red = Color(0xFFD75952);

  static const Color greyLight = Color(0xFFD9D9D6);
  static const Color grey = Color(0xFF999B9D);
  static const Color greyDark = Color(0xFF636A70);

  static const Color white = Colors.white;
  static const Color black = Color(0xFF202326);
}

/// Gemeinsame helle ORTHA-Karte.
///
/// Sie definiert Hintergrund, Rand, Radius und Schatten zentral, damit
/// Wetterstatistik, Legenden und weitere Module dieselbe Designsprache nutzen.
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
        color: OrthaDesignColors.cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: OrthaDesignColors.goldSoft.withValues(alpha: 0.58),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: child,
    );
  }
}
