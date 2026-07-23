import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_dataset.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_parser.dart';

void main() {
  group('DwdPollenParser', () {
    const parser = DwdPollenParser();

    test('liest Metadaten, Region und Pollendaten', () {
      final dataset = parser.parseString(_fixture);

      expect(dataset.name, 'Pollenflug-Gefahrenindex');
      expect(dataset.sender, 'Deutscher Wetterdienst');
      expect(dataset.lastUpdate, DateTime(2026, 7, 23, 11));
      expect(dataset.nextUpdate, DateTime(2026, 7, 24, 11));
      expect(dataset.regions, hasLength(1));

      final region = dataset.regions.single;

      expect(region.regionId, 40);
      expect(region.partRegionId, 41);
      expect(region.regionName, 'Nordrhein-Westfalen');
      expect(region.displayName, 'Rhein.-Westfäl. Tiefland');

      final grass = region.pollen[DwdPollenType.grass];

      expect(grass, isNotNull);
      expect(grass!.today, DwdPollenIndex.lowToModerate);
      expect(grass.tomorrow, DwdPollenIndex.moderate);
      expect(grass.dayAfterTomorrow, DwdPollenIndex.moderateToHigh);
    });

    test('bildet alle DWD-Belastungsstufen korrekt ab', () {
      expect(DwdPollenParser.parseIndex('0'), DwdPollenIndex.none);
      expect(DwdPollenParser.parseIndex('0-1'), DwdPollenIndex.noneToLow);
      expect(DwdPollenParser.parseIndex('1'), DwdPollenIndex.low);
      expect(DwdPollenParser.parseIndex('1-2'), DwdPollenIndex.lowToModerate);
      expect(DwdPollenParser.parseIndex('2'), DwdPollenIndex.moderate);
      expect(DwdPollenParser.parseIndex('2-3'), DwdPollenIndex.moderateToHigh);
      expect(DwdPollenParser.parseIndex('3'), DwdPollenIndex.high);
    });

    test('behandelt -1 als fehlenden Wert', () {
      expect(DwdPollenParser.parseIndex('-1'), isNull);
    });

    test('ignoriert unbekannte Belastungswerte sicher', () {
      expect(DwdPollenParser.parseIndex('unbekannt'), isNull);
    });

    test('meldet ungültiges JSON', () {
      expect(
        () => parser.parseString('{ungültig'),
        throwsA(isA<DwdPollenParseException>()),
      );
    });

    test('meldet fehlende Regionsdaten', () {
      expect(
        () => parser.parseString('{"name":"Test"}'),
        throwsA(isA<DwdPollenParseException>()),
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
  "legend": {
    "id1": "0",
    "id1_desc": "keine Belastung"
  },
  "content": [
    {
      "region_id": 40,
      "partregion_id": 41,
      "region_name": "Nordrhein-Westfalen",
      "partregion_name": "Rhein.-Westfäl. Tiefland",
      "Pollen": {
        "Hasel": {
          "today": "0",
          "tomorrow": "0-1",
          "dayafter_to": "1"
        },
        "Erle": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Esche": {
          "today": "-1",
          "tomorrow": "-1",
          "dayafter_to": "-1"
        },
        "Birke": {
          "today": "1",
          "tomorrow": "1-2",
          "dayafter_to": "2"
        },
        "Graeser": {
          "today": "1-2",
          "tomorrow": "2",
          "dayafter_to": "2-3"
        },
        "Roggen": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Beifuss": {
          "today": "1",
          "tomorrow": "1",
          "dayafter_to": "1-2"
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
