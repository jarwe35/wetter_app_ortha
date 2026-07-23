import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_catalog_region_locator.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_parser.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_catalog.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_locator.dart';

void main() {
  group('DwdPollenCatalogRegionLocator', () {
    test('findet eine katalogisierte Region im DWD-Datensatz', () {
      final dataset = const DwdPollenParser().parseString(_fixture);

      const locator = DwdPollenCatalogRegionLocator(
        key: DwdPollenRegionKey(regionId: 40, partRegionId: 41),
      );

      final result = locator.locate(
        latitude: 51.2254,
        longitude: 6.7763,
        dataset: dataset,
      );

      expect(result.regionId, 40);
      expect(result.partRegionId, 41);
      expect(result.regionName, 'Nordrhein-Westfalen');
    });

    test('weist eine unbekannte Katalogkennung zurück', () {
      final dataset = const DwdPollenParser().parseString(_fixture);

      const locator = DwdPollenCatalogRegionLocator(
        key: DwdPollenRegionKey(regionId: 999, partRegionId: 999),
      );

      expect(
        () => locator.locate(
          latitude: 51.2254,
          longitude: 6.7763,
          dataset: dataset,
        ),
        throwsA(
          isA<DwdPollenRegionLocatorException>().having(
            (error) => error.message,
            'message',
            contains('nicht im Regionskatalog'),
          ),
        ),
      );
    });

    test('meldet eine katalogisierte, aber fehlende Datensatzregion', () {
      final dataset = const DwdPollenParser().parseString(_fixture);

      const locator = DwdPollenCatalogRegionLocator(
        key: DwdPollenRegionKey(regionId: 40, partRegionId: 42),
      );

      expect(
        () => locator.locate(
          latitude: 51.2254,
          longitude: 6.7763,
          dataset: dataset,
        ),
        throwsA(
          isA<DwdPollenRegionLocatorException>().having(
            (error) => error.message,
            'message',
            contains('nicht enthalten'),
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
