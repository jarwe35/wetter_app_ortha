import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/warning_bridge/bbk_warning_geometry.dart';

void main() {
  BbkWarningGeometry createGeometry({
    List<List<BbkGeoPoint>> holes = const [],
  }) {
    return BbkWarningGeometry(
      warningId: 'mow.test',
      polygons: [
        BbkWarningPolygon(
          outerRing: const [
            BbkGeoPoint(longitude: 6.0, latitude: 51.0),
            BbkGeoPoint(longitude: 7.0, latitude: 51.0),
            BbkGeoPoint(longitude: 7.0, latitude: 52.0),
            BbkGeoPoint(longitude: 6.0, latitude: 52.0),
            BbkGeoPoint(longitude: 6.0, latitude: 51.0),
          ],
          holes: holes,
        ),
      ],
    );
  }

  group('BbkWarningGeometry', () {
    test('erkennt Punkt innerhalb eines Polygons', () {
      final geometry = createGeometry();

      expect(geometry.contains(latitude: 51.5, longitude: 6.5), isTrue);
    });

    test('erkennt Punkt außerhalb eines Polygons', () {
      final geometry = createGeometry();

      expect(geometry.contains(latitude: 50.0, longitude: 6.5), isFalse);
    });

    test('behandelt Punkt auf Außenkante als enthalten', () {
      final geometry = createGeometry();

      expect(geometry.contains(latitude: 51.5, longitude: 6.0), isTrue);
    });

    test('schließt Punkt innerhalb eines Polygonlochs aus', () {
      final geometry = createGeometry(
        holes: const [
          [
            BbkGeoPoint(longitude: 6.4, latitude: 51.4),
            BbkGeoPoint(longitude: 6.6, latitude: 51.4),
            BbkGeoPoint(longitude: 6.6, latitude: 51.6),
            BbkGeoPoint(longitude: 6.4, latitude: 51.6),
            BbkGeoPoint(longitude: 6.4, latitude: 51.4),
          ],
        ],
      );

      expect(geometry.contains(latitude: 51.5, longitude: 6.5), isFalse);

      expect(geometry.contains(latitude: 51.8, longitude: 6.5), isTrue);
    });

    test('erkennt Punkt in einem von mehreren Polygonen', () {
      final geometry = BbkWarningGeometry(
        warningId: 'mow.multi',
        polygons: const [
          BbkWarningPolygon(
            outerRing: [
              BbkGeoPoint(longitude: 6.0, latitude: 51.0),
              BbkGeoPoint(longitude: 7.0, latitude: 51.0),
              BbkGeoPoint(longitude: 7.0, latitude: 52.0),
              BbkGeoPoint(longitude: 6.0, latitude: 52.0),
            ],
          ),
          BbkWarningPolygon(
            outerRing: [
              BbkGeoPoint(longitude: 10.0, latitude: 53.0),
              BbkGeoPoint(longitude: 11.0, latitude: 53.0),
              BbkGeoPoint(longitude: 11.0, latitude: 54.0),
              BbkGeoPoint(longitude: 10.0, latitude: 54.0),
            ],
          ),
        ],
      );

      expect(geometry.contains(latitude: 53.5, longitude: 10.5), isTrue);
    });

    test('leere Polygonliste enthält keinen Punkt', () {
      const geometry = BbkWarningGeometry(warningId: 'mow.empty', polygons: []);

      expect(geometry.contains(latitude: 51.4344, longitude: 6.7623), isFalse);
    });
  });
}
