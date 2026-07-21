import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/official_weather_warning.dart';

class OfficialWarningPolygonOverlay extends StatelessWidget {
  final List<OfficialWeatherWarning> warnings;

  const OfficialWarningPolygonOverlay({super.key, required this.warnings});

  static Color severityColor(OfficialWarningSeverity severity) {
    switch (severity) {
      case OfficialWarningSeverity.minor:
        return const Color(0xFFF4D35E);
      case OfficialWarningSeverity.moderate:
        return const Color(0xFFF59E0B);
      case OfficialWarningSeverity.severe:
        return const Color(0xFFDC2626);
      case OfficialWarningSeverity.extreme:
        return const Color(0xFF7F1D1D);
      case OfficialWarningSeverity.unknown:
        return const Color(0xFF64748B);
    }
  }

  static List<Polygon> createPolygons(List<OfficialWeatherWarning> warnings) {
    final polygons = <Polygon>[];

    for (final warning in warnings) {
      final geometry = warning.geometry;

      if (geometry == null || geometry.isEmpty) {
        continue;
      }

      final color = severityColor(warning.severity);

      for (final ring in geometry.polygons) {
        if (ring.length < 3) {
          continue;
        }

        polygons.add(
          Polygon(
            points: ring
                .map((point) => LatLng(point[0], point[1]))
                .toList(growable: false),
            color: color.withValues(alpha: 0.28),
            borderColor: color,
            borderStrokeWidth: 3,
          ),
        );
      }
    }

    return List<Polygon>.unmodifiable(polygons);
  }

  @override
  Widget build(BuildContext context) {
    final polygons = createPolygons(warnings);

    if (polygons.isEmpty) {
      return const SizedBox.shrink();
    }

    return PolygonLayer(polygons: polygons);
  }
}
