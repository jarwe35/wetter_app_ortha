import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_warning_geometry.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/widgets/warnings/official_warning_polygon_overlay.dart';

OfficialWeatherWarning _warning({
  required OfficialWarningSeverity severity,
  OfficialWarningGeometry? geometry,
}) {
  return OfficialWeatherWarning(
    id: 'warning-${severity.name}',
    title: 'Testwarnung',
    description: 'Beschreibung',
    instruction: 'Hinweis',
    source: 'Testquelle',
    severity: severity,
    validFrom: DateTime.utc(2026, 7, 21, 6),
    validUntil: DateTime.utc(2026, 7, 21, 12),
    geometry: geometry,
  );
}

void main() {
  group('OfficialWarningPolygonOverlay', () {
    test('erzeugt ohne Warngeometrie keine Polygone', () {
      final polygons = OfficialWarningPolygonOverlay.createPolygons([
        _warning(severity: OfficialWarningSeverity.moderate),
      ]);

      expect(polygons, isEmpty);
    });

    test('erzeugt ein Polygon aus gültiger Warngeometrie', () {
      final polygons = OfficialWarningPolygonOverlay.createPolygons([
        _warning(
          severity: OfficialWarningSeverity.severe,
          geometry: const OfficialWarningGeometry(
            polygons: [
              [
                [51.0, 6.0],
                [51.2, 6.0],
                [51.2, 6.3],
                [51.0, 6.0],
              ],
            ],
          ),
        ),
      ]);

      expect(polygons, hasLength(1));
      expect(polygons.single.points, hasLength(4));
      expect(polygons.single.points.first.latitude, 51.0);
      expect(polygons.single.points.first.longitude, 6.0);
      expect(polygons.single.borderStrokeWidth, 3);
    });

    test('ignoriert geometrische Ringe mit weniger als drei Punkten', () {
      final polygons = OfficialWarningPolygonOverlay.createPolygons([
        _warning(
          severity: OfficialWarningSeverity.minor,
          geometry: const OfficialWarningGeometry(
            polygons: [
              [
                [51.0, 6.0],
                [51.2, 6.0],
              ],
            ],
          ),
        ),
      ]);

      expect(polygons, isEmpty);
    });

    test('erzeugt mehrere Polygone aus mehreren Warnungen', () {
      final polygons = OfficialWarningPolygonOverlay.createPolygons([
        _warning(
          severity: OfficialWarningSeverity.moderate,
          geometry: const OfficialWarningGeometry(
            polygons: [
              [
                [51.0, 6.0],
                [51.1, 6.0],
                [51.1, 6.1],
              ],
            ],
          ),
        ),
        _warning(
          severity: OfficialWarningSeverity.extreme,
          geometry: const OfficialWarningGeometry(
            polygons: [
              [
                [52.0, 7.0],
                [52.1, 7.0],
                [52.1, 7.1],
              ],
            ],
          ),
        ),
      ]);

      expect(polygons, hasLength(2));
      expect(polygons.first.borderColor, isNot(polygons.last.borderColor));
    });

    test('liefert eine unveränderbare Polygonliste', () {
      final polygons = OfficialWarningPolygonOverlay.createPolygons([
        _warning(
          severity: OfficialWarningSeverity.severe,
          geometry: const OfficialWarningGeometry(
            polygons: [
              [
                [51.0, 6.0],
                [51.1, 6.0],
                [51.1, 6.1],
              ],
            ],
          ),
        ),
      ]);

      expect(() => polygons.clear(), throwsUnsupportedError);
    });

    test('liefert abgestufte Warnfarben', () {
      const minor = OfficialWarningSeverity.minor;
      const moderate = OfficialWarningSeverity.moderate;
      const severe = OfficialWarningSeverity.severe;
      const extreme = OfficialWarningSeverity.extreme;

      expect(
        OfficialWarningPolygonOverlay.severityColor(minor),
        isNot(OfficialWarningPolygonOverlay.severityColor(moderate)),
      );

      expect(
        OfficialWarningPolygonOverlay.severityColor(severe),
        isNot(OfficialWarningPolygonOverlay.severityColor(extreme)),
      );

      expect(
        OfficialWarningPolygonOverlay.severityColor(extreme),
        const Color(0xFF7F1D1D),
      );
    });
  });
}
