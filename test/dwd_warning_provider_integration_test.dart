import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_cap_download_client.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_warning_provider.dart';

void main() {
  group('DwdWarningProvider Integration', () {
    final sourceUri = Uri.parse('https://example.test/dwd-cap.zip');

    Uint8List createZip(Map<String, String> files) {
      final archive = Archive();

      for (final entry in files.entries) {
        final bytes = utf8.encode(entry.value);

        archive.addFile(ArchiveFile(entry.key, bytes.length, bytes));
      }

      return Uint8List.fromList(ZipEncoder().encode(archive));
    }

    test(
      'verarbeitet ZIP Download Parser und Ortsfilter als Pipeline',
      () async {
        final zipBytes = createZip({
          'duisburg.xml': '''
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>duisburg-warning</identifier>
  <sent>2026-07-10T08:00:00+00:00</sent>
  <info>
    <severity>Severe</severity>
    <effective>2026-07-10T09:00:00+00:00</effective>
    <expires>2026-07-10T12:00:00+00:00</expires>
    <headline>Warnung für Duisburg</headline>
    <description>Testwarnung für Duisburg.</description>
    <instruction>Vorsicht.</instruction>
    <area>
      <areaDesc>Stadt Duisburg</areaDesc>
      <polygon>51.50,6.60 51.50,6.90 51.30,6.90 51.30,6.60 51.50,6.60</polygon>
    </area>
  </info>
</alert>
''',
          'berlin.xml': '''
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
''',
        });

        final mockClient = MockClient((request) async {
          return Response.bytes(zipBytes, 200);
        });

        final provider = DwdWarningProvider(
          downloadClient: DwdCapDownloadClient(
            httpClient: mockClient,
            sourceUri: sourceUri,
          ),
        );

        final warnings = await provider.fetchWarnings(
          latitude: 51.4344,
          longitude: 6.7623,
        );

        expect(warnings, hasLength(1));
        expect(warnings.single.id, 'duisburg-warning');
        expect(warnings.single.title, 'Warnung für Duisburg');
      },
    );

    test('verarbeitet mehrere CAP-Dateien im ZIP-Archiv', () async {
      final zipBytes = createZip({
        'warning-1.xml': '''
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>warning-1</identifier>
  <sent>2026-07-10T08:00:00+00:00</sent>
  <info>
    <severity>Moderate</severity>
    <effective>2026-07-10T09:00:00+00:00</effective>
    <expires>2026-07-10T12:00:00+00:00</expires>
    <headline>Warnung 1</headline>
    <area>
      <areaDesc>Stadt Duisburg</areaDesc>
      <polygon>51.50,6.60 51.50,6.90 51.30,6.90 51.30,6.60 51.50,6.60</polygon>
    </area>
  </info>
</alert>
''',
        'warning-2.xml': '''
<alert xmlns="urn:oasis:names:tc:emergency:cap:1.2">
  <identifier>warning-2</identifier>
  <sent>2026-07-10T08:00:00+00:00</sent>
  <info>
    <severity>Severe</severity>
    <effective>2026-07-10T09:00:00+00:00</effective>
    <expires>2026-07-10T13:00:00+00:00</expires>
    <headline>Warnung 2</headline>
    <area>
      <areaDesc>Stadt Duisburg</areaDesc>
      <polygon>51.50,6.60 51.50,6.90 51.30,6.90 51.30,6.60 51.50,6.60</polygon>
    </area>
  </info>
</alert>
''',
      });

      final provider = DwdWarningProvider(
        downloadClient: DwdCapDownloadClient(
          httpClient: MockClient((request) async {
            return Response.bytes(zipBytes, 200);
          }),
          sourceUri: sourceUri,
        ),
      );

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, hasLength(2));
      expect(
        warnings.map((warning) => warning.id),
        containsAll(['warning-1', 'warning-2']),
      );
    });

    test('gibt ohne Download-Client weiterhin leere Liste zurück', () async {
      const provider = DwdWarningProvider();

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
    });

    test('reicht Downloadfehler kontrolliert weiter', () async {
      final mockClient = MockClient((request) async {
        return Response('Serverfehler', 503);
      });

      final provider = DwdWarningProvider(
        downloadClient: DwdCapDownloadClient(
          httpClient: mockClient,
          sourceUri: sourceUri,
        ),
      );

      expect(
        () => provider.fetchWarnings(latitude: 51.4344, longitude: 6.7623),
        throwsA(isA<DwdCapDownloadException>()),
      );
    });
  });
}
