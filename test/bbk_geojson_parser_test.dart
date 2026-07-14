import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_geojson_parser.dart';

void main() {
  const parser = BbkGeoJsonParser();

  group('BbkGeoJsonParser', () {
    test('parst reales Polygon-Format', () {
      final result = parser.parse({
        'type': 'FeatureCollection',
        'features': [
          {
            'type': 'Feature',
            'properties': {'warnId': 'mow.test-polygon', 'areaId': 0},
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [6.0, 51.0],
                  [7.0, 51.0],
                  [7.0, 52.0],
                  [6.0, 52.0],
                  [6.0, 51.0],
                ],
              ],
            },
          },
        ],
      });

      expect(result.warningId, 'mow.test-polygon');
      expect(result.polygons, hasLength(1));
      expect(result.contains(latitude: 51.5, longitude: 6.5), isTrue);
    });

    test('parst Polygon mit Loch', () {
      final result = parser.parse({
        'type': 'FeatureCollection',
        'features': [
          {
            'properties': {'warnId': 'mow.test-hole'},
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [6.0, 51.0],
                  [7.0, 51.0],
                  [7.0, 52.0],
                  [6.0, 52.0],
                  [6.0, 51.0],
                ],
                [
                  [6.4, 51.4],
                  [6.6, 51.4],
                  [6.6, 51.6],
                  [6.4, 51.6],
                  [6.4, 51.4],
                ],
              ],
            },
          },
        ],
      });

      expect(result.contains(latitude: 51.5, longitude: 6.5), isFalse);
    });

    test('parst MultiPolygon', () {
      final result = parser.parse({
        'type': 'FeatureCollection',
        'features': [
          {
            'properties': {'warnId': 'mow.test-multi'},
            'geometry': {
              'type': 'MultiPolygon',
              'coordinates': [
                [
                  [
                    [6.0, 51.0],
                    [7.0, 51.0],
                    [7.0, 52.0],
                    [6.0, 52.0],
                    [6.0, 51.0],
                  ],
                ],
                [
                  [
                    [10.0, 53.0],
                    [11.0, 53.0],
                    [11.0, 54.0],
                    [10.0, 54.0],
                    [10.0, 53.0],
                  ],
                ],
              ],
            },
          },
        ],
      });

      expect(result.polygons, hasLength(2));
      expect(result.contains(latitude: 53.5, longitude: 10.5), isTrue);
    });

    test('überspringt ungültige Features', () {
      final result = parser.parse({
        'type': 'FeatureCollection',
        'features': [
          'ungueltig',
          {
            'properties': {'warnId': 'mow.valid'},
            'geometry': null,
          },
          {
            'geometry': {
              'type': 'Polygon',
              'coordinates': [
                [
                  [6.0, 51.0],
                  [7.0, 51.0],
                  [7.0, 52.0],
                  [6.0, 51.0],
                ],
              ],
            },
          },
        ],
      });

      expect(result.warningId, 'mow.valid');
      expect(result.polygons, hasLength(1));
    });

    test('lehnt falschen Root-Typ ab', () {
      expect(() => parser.parse([]), throwsFormatException);
    });

    test('lehnt andere GeoJSON-Typen ab', () {
      expect(
        () => parser.parse({'type': 'Feature', 'features': []}),
        throwsFormatException,
      );
    });

    test('lehnt FeatureCollection ohne Warn-ID ab', () {
      expect(
        () => parser.parse({
          'type': 'FeatureCollection',
          'features': [
            {
              'geometry': {
                'type': 'Polygon',
                'coordinates': [
                  [
                    [6.0, 51.0],
                    [7.0, 51.0],
                    [7.0, 52.0],
                  ],
                ],
              },
            },
          ],
        }),
        throwsFormatException,
      );
    });
  });
}
