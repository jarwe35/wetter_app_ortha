import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_parser.dart';

void main() {
  preferredLanguageTests();
  const parser = BbkWarningParser();

  group('BbkWarningParser', () {
    test('parst verschachtelte CAP-ähnliche BBK-Warnung', () {
      final warning = parser.parse({
        'identifier': 'mow.DE-NW-DU-001',
        'sender': 'mowas@stadt-duisburg.de',
        'senderName': 'Stadt Duisburg',
        'sent': '2026-07-14T08:00:00Z',
        'msgType': 'Alert',
        'info': [
          {
            'headline': 'Rauchentwicklung in Duisburg',
            'description': 'Im Stadtgebiet kommt es zu Rauchentwicklung.',
            'instruction': 'Fenster und Türen geschlossen halten.',
            'severity': 'Severe',
            'urgency': 'Immediate',
            'certainty': 'Observed',
            'effective': '2026-07-14T08:00:00Z',
            'expires': '2026-07-14T12:00:00Z',
            'area': [
              {
                'areaDesc': 'Stadt Duisburg',
                'geocode': [
                  {'valueName': 'ARS', 'value': '051120000000'},
                ],
                'polygon': ['51.40,6.70 51.50,6.70 51.50,6.85 51.40,6.70'],
              },
            ],
          },
        ],
      });

      expect(warning.identifier, 'mow.DE-NW-DU-001');
      expect(warning.headline, 'Rauchentwicklung in Duisburg');
      expect(warning.sender, 'Stadt Duisburg');
      expect(warning.severity, 'Severe');
      expect(warning.messageType, 'Alert');
      expect(warning.sent, DateTime.utc(2026, 7, 14, 8));
      expect(warning.expires, DateTime.utc(2026, 7, 14, 12));
      expect(warning.areaDescriptions, ['Stadt Duisburg']);
      expect(warning.geocodes['ARS'], '051120000000');
      expect(warning.polygons, hasLength(1));
    });

    test('parst vereinfachte direkte JSON-Struktur', () {
      final warning = parser.parse({
        'id': 'bbk-direct-1',
        'title': 'Gefahrstoffaustritt',
        'description': 'Ein Gefahrstoff ist ausgetreten.',
        'recommendation': 'Gebiet meiden.',
        'sender': 'Feuerwehr',
        'severity': 'Extreme',
        'urgency': 'Immediate',
        'certainty': 'Observed',
        'messageType': 'Alert',
        'start': '2026-07-14T10:00:00+02:00',
        'end': '2026-07-14T14:00:00+02:00',
        'info': {
          'areaDesc': 'Duisburg-Mitte',
          'geocodes': {'ARS': '051120000000'},
          'polygon': '51.42,6.74 51.45,6.74 51.45,6.79 51.42,6.74',
        },
      });

      expect(warning.identifier, 'bbk-direct-1');
      expect(warning.headline, 'Gefahrstoffaustritt');
      expect(warning.instruction, 'Gebiet meiden.');
      expect(warning.areaDescriptions, ['Duisburg-Mitte']);
      expect(warning.geocodes['ARS'], '051120000000');
      expect(warning.hasGeometry, isTrue);
    });

    test('verwendet sichere Standardwerte für optionale Felder', () {
      final warning = parser.parse({'identifier': 'minimal-1'});

      expect(warning.headline, 'Amtliche Warnung');
      expect(warning.description, isEmpty);
      expect(warning.instruction, isEmpty);
      expect(warning.sender, 'BBK / warnung.bund.de');
      expect(warning.severity, 'Unknown');
      expect(warning.sent, isNull);
    });

    test('lehnt Warnung ohne Kennung ab', () {
      expect(
        () => parser.parse({'headline': 'Warnung ohne ID'}),
        throwsFormatException,
      );
    });

    test('parseList überspringt beschädigte Datensätze', () {
      final warnings = parser.parseList({
        'warnings': [
          {'identifier': 'valid-1', 'headline': 'Gültige Warnung'},
          {'headline': 'Ungültig ohne Kennung'},
          'kein Objekt',
        ],
      });

      expect(warnings, hasLength(1));
      expect(warnings.single.identifier, 'valid-1');
    });

    test('parseList akzeptiert direkte Liste und items-Struktur', () {
      final directWarnings = parser.parseList([
        {'identifier': 'direct-list-1'},
      ]);

      final itemWarnings = parser.parseList({
        'items': [
          {'identifier': 'items-list-1'},
        ],
      });

      expect(directWarnings.single.identifier, 'direct-list-1');
      expect(itemWarnings.single.identifier, 'items-list-1');
    });
  });
}

void preferredLanguageTests() {
  const parser = BbkWarningParser();

  test('bevorzugt deutschen info-Block unabhängig von Reihenfolge', () {
    final warning = parser.parse({
      'identifier': 'mow.language-order',
      'sender': 'DE-BBK',
      'sent': '2026-07-14T12:00:00+02:00',
      'msgType': 'Alert',
      'info': [
        {
          'language': 'en',
          'headline': 'English headline',
          'description': 'English description',
          'severity': 'Minor',
        },
        {
          'language': 'de',
          'headline': 'Deutsche Überschrift',
          'description': 'Deutsche Beschreibung',
          'severity': 'Severe',
        },
      ],
    });

    expect(warning.headline, 'Deutsche Überschrift');
    expect(warning.description, 'Deutsche Beschreibung');
    expect(warning.severity, 'Severe');
  });

  test('bevorzugt de vor de-DE', () {
    final warning = parser.parse({
      'identifier': 'mow.language-priority',
      'sender': 'DE-BBK',
      'sent': '2026-07-14T12:00:00+02:00',
      'msgType': 'Alert',
      'info': [
        {'language': 'de-DE', 'headline': 'Deutsch Deutschland'},
        {'language': 'de', 'headline': 'Deutsch bevorzugt'},
      ],
    });

    expect(warning.headline, 'Deutsch bevorzugt');
  });

  test('verwendet andere deutsche Sprachvariante vor fremder Sprache', () {
    final warning = parser.parse({
      'identifier': 'mow.language-variant',
      'sender': 'DE-BBK',
      'sent': '2026-07-14T12:00:00+02:00',
      'msgType': 'Alert',
      'info': [
        {'language': 'en', 'headline': 'English headline'},
        {'language': 'de-LS', 'headline': 'Deutscher Landesblock'},
      ],
    });

    expect(warning.headline, 'Deutscher Landesblock');
  });

  test('verwendet ersten info-Block wenn keine deutsche Sprache existiert', () {
    final warning = parser.parse({
      'identifier': 'mow.language-fallback',
      'sender': 'DE-BBK',
      'sent': '2026-07-14T12:00:00+02:00',
      'msgType': 'Alert',
      'info': [
        {'language': 'en', 'headline': 'First fallback'},
        {'language': 'fr', 'headline': 'Second fallback'},
      ],
    });

    expect(warning.headline, 'First fallback');
  });

  test('liest Gebiete und Geocodes aus allen Areas des deutschen Blocks', () {
    final warning = parser.parse({
      'identifier': 'mow.multiple-areas',
      'sender': 'DE-BBK',
      'sent': '2026-07-14T12:00:00+02:00',
      'msgType': 'Alert',
      'info': [
        {
          'language': 'de',
          'headline': 'Warnung',
          'area': [
            {
              'areaDesc': 'Gebiet A',
              'geocode': [
                {'valueName': 'ARS', 'value': '051120000000'},
              ],
            },
            {
              'areaDesc': 'Gebiet B',
              'geocode': [
                {'valueName': 'WARNCELLID', 'value': 'DE123456'},
              ],
            },
          ],
        },
      ],
    });

    expect(warning.areaDescriptions, ['Gebiet A', 'Gebiet B']);
    expect(warning.geocodes['ARS'], '051120000000');
    expect(warning.geocodes['WARNCELLID'], 'DE123456');
  });
}
