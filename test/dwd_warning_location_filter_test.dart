import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_cap_parser.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_warning_location_filter.dart';

void main() {
  group('DwdWarningLocationFilter', () {
    const parser = DwdCapParser();
    const filter = DwdWarningLocationFilter();

    test('liefert nur Warnung deren Polygon den Ort enthält', () {
      const xml = '''
<alerts>
  <alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
    <identifier>duisburg-warning</identifier>
    <sent>2026-07-10T08:00:00+00:00</sent>
    <info>
      <severity>Severe</severity>
      <effective>2026-07-10T09:00:00+00:00</effective>
      <expires>2026-07-10T12:00:00+00:00</expires>
      <headline>Warnung für Duisburg</headline>
      <area>
        <areaDesc>Stadt Duisburg</areaDesc>
        <polygon>51.50,6.60 51.50,6.90 51.30,6.90 51.30,6.60 51.50,6.60</polygon>
      </area>
    </info>
  </alert>

  <alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
    <identifier>berlin-warning</identifier>
    <sent>2026-07-10T08:00:00+00:00</sent>
    <info>
      <severity>Extreme</severity>
      <effective>2026-07-10T09:00:00+00:00</effective>
      <expires>2026-07-10T12:00:00+00:00</expires>
      <headline>Warnung für Berlin</headline>
      <area>
        <areaDesc>Berlin</areaDesc>
        <polygon>52.60,13.20 52.60,13.60 52.40,13.60 52.40,13.20 52.60,13.20</polygon>
      </area>
    </info>
  </alert>
</alerts>
''';

      final warnings = parser.parse(xml);

      final result = filter.filterForLocation(
        warnings: warnings,
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(result, hasLength(1));
      expect(result.single.id, 'duisburg-warning');
    });

    test('liefert leere Liste wenn kein Warnpolygon den Ort enthält', () {
      final warning = OfficialWeatherWarning(
        id: 'other-location',
        title: 'Andere Region',
        description: 'Test',
        instruction: 'Test',
        source: 'Deutscher Wetterdienst',
        severity: OfficialWarningSeverity.moderate,
        validFrom: DateTime.parse('2026-07-10T09:00:00+00:00'),
        validUntil: DateTime.parse('2026-07-10T12:00:00+00:00'),
        polygons: const [
          '52.60,13.20 52.60,13.60 52.40,13.60 52.40,13.20 52.60,13.20',
        ],
      );

      final result = filter.filterForLocation(
        warnings: [warning],
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(result, isEmpty);
    });

    test('ignoriert Warnung ohne Polygon', () {
      final warning = OfficialWeatherWarning(
        id: 'without-polygon',
        title: 'Warnung ohne Polygon',
        description: 'Test',
        instruction: 'Test',
        source: 'Deutscher Wetterdienst',
        severity: OfficialWarningSeverity.minor,
        validFrom: DateTime.parse('2026-07-10T09:00:00+00:00'),
        validUntil: DateTime.parse('2026-07-10T12:00:00+00:00'),
      );

      final result = filter.filterForLocation(
        warnings: [warning],
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(result, isEmpty);
    });

    test('erkennt Ort wenn eines von mehreren Polygonen passt', () {
      final warning = OfficialWeatherWarning(
        id: 'multiple-polygons',
        title: 'Warnung mit mehreren Gebieten',
        description: 'Test',
        instruction: 'Test',
        source: 'Deutscher Wetterdienst',
        severity: OfficialWarningSeverity.severe,
        validFrom: DateTime.parse('2026-07-10T09:00:00+00:00'),
        validUntil: DateTime.parse('2026-07-10T12:00:00+00:00'),
        polygons: const [
          '52.60,13.20 52.60,13.60 52.40,13.60 52.40,13.20 52.60,13.20',
          '51.50,6.60 51.50,6.90 51.30,6.90 51.30,6.60 51.50,6.60',
        ],
      );

      final result = filter.filterForLocation(
        warnings: [warning],
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(result, hasLength(1));
      expect(result.single.id, 'multiple-polygons');
    });
  });
}
