import 'package:flutter/material.dart';

/// Eigenständiges Informationsfenster für die Niederschlagsintensität.
///
/// Die Legende befindet sich außerhalb der Karte und überlagert weder
/// Karteninhalt noch Timeline oder Kartensteuerung.
class OrthaRadarLegend extends StatelessWidget {
  const OrthaRadarLegend({super.key});

  static const List<_RadarLegendItem> _items = [
    _RadarLegendItem(color: Color(0xFFB8ECF4), label: 'Sehr schwach'),
    _RadarLegendItem(color: Color(0xFF48C8E8), label: 'Schwach'),
    _RadarLegendItem(color: Color(0xFF078CCB), label: 'Mäßig'),
    _RadarLegendItem(color: Color(0xFFFFE044), label: 'Stark'),
    _RadarLegendItem(color: Color(0xFFFF9D24), label: 'Sehr stark'),
    _RadarLegendItem(color: Color(0xFFE84A3C), label: 'Extrem'),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF153149),
      elevation: 7,
      shadowColor: Colors.black45,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.palette_outlined, size: 19, color: Colors.white),
                SizedBox(width: 8),
                Text(
                  'Niederschlagsintensität',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Wrap(spacing: 16, runSpacing: 10, children: _items),
            SizedBox(height: 11),
            Text(
              'Die Farben zeigen die relative Radarintensität. '
              'Sie entsprechen keiner direkten Niederschlagsmengen-Prognose.',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RadarLegendItem extends StatelessWidget {
  const _RadarLegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 20,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
