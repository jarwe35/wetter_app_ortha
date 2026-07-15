import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_warning_geometry.dart';

void main() {
  const geometry = OfficialWarningGeometry(
    polygons: [
      [
        [51.0, 6.0],
        [52.0, 6.0],
        [52.0, 7.0],
        [51.0, 7.0],
        [51.0, 6.0],
      ],
    ],
  );

  group('OfficialWarningGeometry', () {
    test('erkennt Standort innerhalb eines Warnpolygons', () {
      expect(geometry.contains(latitude: 51.5, longitude: 6.5), isTrue);
    });

    test('erkennt Standort außerhalb eines Warnpolygons', () {
      expect(geometry.contains(latitude: 50.0, longitude: 6.5), isFalse);
    });

    test('wertet Punkt auf Polygonrand als enthalten', () {
      expect(geometry.contains(latitude: 51.5, longitude: 6.0), isTrue);
    });

    test('leere Geometrie enthält keinen Standort', () {
      const empty = OfficialWarningGeometry(polygons: []);

      expect(empty.contains(latitude: 51.5, longitude: 6.5), isFalse);
    });

    test('überspringt beschädigte Koordinaten kontrolliert', () {
      const damaged = OfficialWarningGeometry(
        polygons: [
          [
            [51.0],
            [52.0],
            [53.0],
          ],
        ],
      );

      expect(damaged.contains(latitude: 51.5, longitude: 6.5), isFalse);
    });
  });
}
