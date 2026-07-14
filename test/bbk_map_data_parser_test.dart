import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_map_data_parser.dart';

void main() {
  const parser = BbkMapDataParser();

  group('BbkMapDataParser', () {
    test('parst realistische MoWaS-MapData', () {
      final result = parser.parse([
        {
          'id': 'mow.DE-SL-SLS-W038-20260113-000',
          'version': 11,
          'startDate': '2026-01-13T12:09:37+01:00',
          'severity': 'Minor',
          'urgency': 'Immediate',
          'type': 'Update',
          'i18nTitle': {
            'de': 'Beeinträchtigung des Trinkwassers',
            'en': 'Contaminated drinking water',
          },
          'transKeys': {'event': 'BBK-EVC-069'},
        },
      ]);

      expect(result, hasLength(1));

      final warning = result.single;

      expect(warning.id, 'mow.DE-SL-SLS-W038-20260113-000');
      expect(warning.version, 11);
      expect(warning.startDate.year, 2026);
      expect(warning.severity, 'Minor');
      expect(warning.urgency, 'Immediate');
      expect(warning.type, 'Update');
      expect(warning.germanTitle, 'Beeinträchtigung des Trinkwassers');
      expect(warning.translationKeys['event'], 'BBK-EVC-069');
    });

    test('lehnt Root-Objekt statt Liste ab', () {
      expect(() => parser.parse({'warnings': []}), throwsFormatException);
    });

    test('überspringt Nicht-Objekte', () {
      final result = parser.parse([
        'ungueltig',
        42,
        null,
        {
          'id': 'mow.valid',
          'version': 1,
          'startDate': '2026-07-14T12:00:00+02:00',
          'type': 'Alert',
        },
      ]);

      expect(result, hasLength(1));
      expect(result.single.id, 'mow.valid');
    });

    test('überspringt Eintrag mit ungültigem Datum', () {
      final result = parser.parse([
        {'id': 'mow.invalid-date', 'version': 1, 'startDate': 'kein-datum'},
      ]);

      expect(result, isEmpty);
    });

    test('überspringt Eintrag mit ungültiger Version', () {
      final result = parser.parse([
        {
          'id': 'mow.invalid-version',
          'version': 'abc',
          'startDate': '2026-07-14T12:00:00+02:00',
        },
      ]);

      expect(result, isEmpty);
    });

    test('akzeptiert numerische Version als String', () {
      final result = parser.parse([
        {
          'id': 'mow.string-version',
          'version': '12',
          'startDate': '2026-07-14T12:00:00+02:00',
          'i18nTitle': {'de': 'Testwarnung'},
        },
      ]);

      expect(result.single.version, 12);
    });

    test('übernimmt nur String-Werte aus Sprachkarten', () {
      final result = parser.parse([
        {
          'id': 'mow.maps',
          'version': 1,
          'startDate': '2026-07-14T12:00:00+02:00',
          'i18nTitle': {'de': 'Deutscher Titel', 'invalid': 42},
          'transKeys': {'event': 'BBK-EVC-077', 'invalid': true},
        },
      ]);

      expect(result.single.titles, {'de': 'Deutscher Titel'});
      expect(result.single.translationKeys, {'event': 'BBK-EVC-077'});
    });
  });
}
