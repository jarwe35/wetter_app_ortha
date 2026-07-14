import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/models/warning_bridge/bbk_warning.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_converter.dart';

BbkWarning createWarning({
  String identifier = 'bbk-1',
  String headline = 'Amtliche Warnung',
  String sender = 'BBK',
  String severity = 'Severe',
  String messageType = 'Alert',
  DateTime? sent,
  DateTime? effective,
  DateTime? expires,
  List<String> areaDescriptions = const ['Duisburg'],
  Map<String, String> geocodes = const {'ARS': '051120000000'},
  List<String> polygons = const ['51.4,6.7 51.5,6.7 51.4,6.7'],
}) {
  return BbkWarning(
    identifier: identifier,
    headline: headline,
    description: 'Beschreibung',
    instruction: 'Handlungsempfehlung',
    sender: sender,
    severity: severity,
    urgency: 'Immediate',
    certainty: 'Observed',
    messageType: messageType,
    sent: sent,
    effective: effective,
    expires: expires,
    areaDescriptions: areaDescriptions,
    geocodes: geocodes,
    polygons: polygons,
  );
}

void main() {
  const converter = BbkWarningConverter();

  group('BbkWarningConverter', () {
    test('konvertiert vollständige BBK-Warnung', () {
      final warning = createWarning(
        sent: DateTime.utc(2026, 7, 14, 7),
        effective: DateTime.utc(2026, 7, 14, 8),
        expires: DateTime.utc(2026, 7, 14, 12),
      );

      final result = converter.convert(warning);

      expect(result.id, 'bbk-1');
      expect(result.title, 'Amtliche Warnung');
      expect(result.description, 'Beschreibung');
      expect(result.instruction, 'Handlungsempfehlung');
      expect(result.source, 'BBK');
      expect(result.severity, OfficialWarningSeverity.severe);
      expect(result.validFrom, DateTime.utc(2026, 7, 14, 8));
      expect(result.validUntil, DateTime.utc(2026, 7, 14, 12));
      expect(result.areaDescriptions, ['Duisburg']);
      expect(result.geocodes['ARS'], '051120000000');
      expect(result.polygons, hasLength(1));
    });

    test('verwendet sent wenn effective fehlt', () {
      final warning = createWarning(
        sent: DateTime.utc(2026, 7, 14, 8),
        expires: DateTime.utc(2026, 7, 14, 12),
      );

      final result = converter.convert(warning);

      expect(result.validFrom, DateTime.utc(2026, 7, 14, 8));
    });

    test('verwendet 24 Stunden Standardgültigkeit wenn expires fehlt', () {
      final start = DateTime.utc(2026, 7, 14, 8);

      final result = converter.convert(createWarning(sent: start));

      expect(
        result.validUntil,
        start.add(BbkWarningConverter.defaultValidityDuration),
      );
    });

    test('mappt alle bekannten Schweregrade', () {
      final start = DateTime.utc(2026, 7, 14, 8);

      final cases = {
        'Minor': OfficialWarningSeverity.minor,
        'Moderate': OfficialWarningSeverity.moderate,
        'Severe': OfficialWarningSeverity.severe,
        'Extreme': OfficialWarningSeverity.extreme,
        'Unbekannt': OfficialWarningSeverity.unknown,
      };

      for (final entry in cases.entries) {
        final result = converter.convert(
          createWarning(severity: entry.key, sent: start),
        );

        expect(result.severity, entry.value);
      }
    });

    test('lehnt Warnung ohne Startzeitpunkt ab', () {
      expect(() => converter.convert(createWarning()), throwsFormatException);
    });

    test('lehnt ungültigen Gültigkeitszeitraum ab', () {
      final start = DateTime.utc(2026, 7, 14, 12);

      expect(
        () => converter.convert(
          createWarning(
            effective: start,
            expires: DateTime.utc(2026, 7, 14, 8),
          ),
        ),
        throwsFormatException,
      );
    });

    test('lehnt Entwarnung ab', () {
      expect(
        () => converter.convert(
          createWarning(
            messageType: 'Cancel',
            sent: DateTime.utc(2026, 7, 14, 8),
          ),
        ),
        throwsFormatException,
      );
    });

    test('convertAll überspringt nicht konvertierbare Warnungen', () {
      final warnings = [
        createWarning(
          identifier: 'valid-1',
          sent: DateTime.utc(2026, 7, 14, 8),
        ),
        createWarning(identifier: 'invalid-no-time'),
        createWarning(
          identifier: 'cancel-1',
          messageType: 'Cancel',
          sent: DateTime.utc(2026, 7, 14, 8),
        ),
      ];

      final result = converter.convertAll(warnings);

      expect(result, hasLength(1));
      expect(result.single.id, 'valid-1');
    });

    test('kopiert Geometrie und Gebietsdaten unverändert', () {
      final warning = createWarning(
        sent: DateTime.utc(2026, 7, 14, 8),
        areaDescriptions: const ['Duisburg-Mitte', 'Duisburg-Süd'],
        geocodes: const {'ARS': '051120000000', 'WARNCELLID': '105112000000'},
        polygons: const [
          '51.40,6.70 51.50,6.70 51.40,6.70',
          '51.30,6.60 51.35,6.60 51.30,6.60',
        ],
      );

      final result = converter.convert(warning);

      expect(result.areaDescriptions, warning.areaDescriptions);
      expect(result.geocodes, warning.geocodes);
      expect(result.polygons, warning.polygons);
    });
  });
}
