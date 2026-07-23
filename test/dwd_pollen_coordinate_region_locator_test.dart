import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_coordinate_region_locator.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_coordinate_region_resolver.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_parser.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_locator.dart';

void main() {
  group('DwdPollenCoordinateRegionLocator', () {
    test('findet für Düsseldorf die passende Datensatzregion', () {
      final dataset = const DwdPollenParser().parseString(_fixture);

      final locator = DwdPollenCoordinateRegionLocator(
        resolver: DwdPollenCoordinateRegionResolver.nrwDemonstrator(),
      );

      final result = locator.locate(
        latitude: 51.2254,
        longitude: 6.7763,
        dataset: dataset,
      );

      expect(result.regionId, 40);
      expect(result.partRegionId, 41);
    });

    test('weist einen nicht geprüften Standort zurück', () {
      final dataset = const DwdPollenParser().parseString(_fixture);

      final locator = DwdPollenCoordinateRegionLocator(
        resolver: DwdPollenCoordinateRegionResolver.nrwDemonstrator(),
      );

      expect(
        () => locator.locate(
          latitude: 52.5200,
          longitude: 13.4050,
          dataset: dataset,
        ),
        throwsA(
          isA<DwdPollenRegionLocatorException>().having(
            (error) => error.message,
            'message',
            contains('keine kontrolliert geprüfte'),
          ),
        ),
      );
    });
  });
}

const _fixture = '''
{
  "name": "Pollenflug-Gefahrenindex",
  "sender": "Deutscher Wetterdienst",
  "last_update": "2026-07-23 11:00 Uhr",
  "next_update": "2026-07-24 11:00 Uhr",
  "legend": {},
  "content": [
    {
      "region_id": 40,
      "partregion_id": 41,
      "region_name": "Nordrhein-Westfalen",
      "partregion_name": "Rhein.-Westfäl. Tiefland",
      "Pollen": {
        "Hasel": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Erle": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Esche": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Birke": {
          "today": "1",
          "tomorrow": "1-2",
          "dayafter_to": "2"
        },
        "Graeser": {
          "today": "2-3",
          "tomorrow": "3",
          "dayafter_to": "2"
        },
        "Roggen": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Beifuss": {
          "today": "1",
          "tomorrow": "1-2",
          "dayafter_to": "2"
        },
        "Ambrosia": {
          "today": "0-1",
          "tomorrow": "1",
          "dayafter_to": "1-2"
        }
      }
    }
  ]
}
''';
