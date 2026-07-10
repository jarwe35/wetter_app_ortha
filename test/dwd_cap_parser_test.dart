import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_cap_parser.dart';

void main() {
  group('DwdCapParser', () {
    const parser = DwdCapParser();

    test('liest eine amtliche CAP-Warnung', () {
      const xml = '''
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>dwd-test-1</identifier>
  <sent>2026-07-10T08:00:00+00:00</sent>
  <info>
    <severity>Severe</severity>
    <effective>2026-07-10T09:00:00+00:00</effective>
    <expires>2026-07-10T12:00:00+00:00</expires>
    <headline>Amtliche Warnung vor schweren Sturmböen</headline>
    <description>Es treten schwere Sturmböen auf.</description>
    <instruction>Meiden Sie den Aufenthalt im Freien.</instruction>
  </info>
</alert>
''';

      final warnings = parser.parse(xml);

      expect(warnings, hasLength(1));

      final warning = warnings.single;

      expect(warning.id, 'dwd-test-1');
      expect(warning.title, 'Amtliche Warnung vor schweren Sturmböen');
      expect(warning.description, 'Es treten schwere Sturmböen auf.');
      expect(warning.instruction, 'Meiden Sie den Aufenthalt im Freien.');
      expect(warning.source, 'Deutscher Wetterdienst');
      expect(warning.severity, OfficialWarningSeverity.severe);
      expect(warning.validFrom, DateTime.parse('2026-07-10T09:00:00+00:00'));
      expect(warning.validUntil, DateTime.parse('2026-07-10T12:00:00+00:00'));
    });

    test('ordnet unbekannte Warnstufe unknown zu', () {
      const xml = '''
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>dwd-test-2</identifier>
  <sent>2026-07-10T08:00:00+00:00</sent>
  <info>
    <severity>Undefined</severity>
    <effective>2026-07-10T09:00:00+00:00</effective>
    <expires>2026-07-10T12:00:00+00:00</expires>
    <headline>Testwarnung</headline>
  </info>
</alert>
''';

      final warning = parser.parse(xml).single;

      expect(warning.severity, OfficialWarningSeverity.unknown);
    });

    test('liest Gebietsbeschreibung Geocode und Polygon', () {
      const xml = '''
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>dwd-area-test</identifier>
  <sent>2026-07-10T08:00:00+00:00</sent>
  <info>
    <severity>Moderate</severity>
    <effective>2026-07-10T09:00:00+00:00</effective>
    <expires>2026-07-10T12:00:00+00:00</expires>
    <headline>Gebietstest</headline>
    <area>
      <areaDesc>Stadt Duisburg</areaDesc>
      <polygon>51.50,6.60 51.50,6.90 51.30,6.90 51.30,6.60 51.50,6.60</polygon>
      <geocode>
        <valueName>WARNCELLID</valueName>
        <value>105112000</value>
      </geocode>
    </area>
  </info>
</alert>
''';

      final warning = parser.parse(xml).single;

      expect(warning.areaDescriptions, ['Stadt Duisburg']);
      expect(warning.geocodes['WARNCELLID'], '105112000');
      expect(warning.polygons, hasLength(1));
      expect(warning.polygons.single, contains('51.50,6.60'));
    });
  });
}
