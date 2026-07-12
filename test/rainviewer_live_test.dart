// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:wetter_app_ortha/services/radar/rainviewer_radar_service.dart';

void main() {
  test(
    'lädt echte RainViewer-Radar-Metadaten',
    () async {
      final client = http.Client();

      try {
        final service = RainViewerRadarService(httpClient: client);

        final metadata = await service.fetchMetadata();
        final latestFrame = metadata.latestFrame;
        final tileTemplate = metadata.tileUrlTemplate(frame: latestFrame);

        print('RainViewer-Live-Test erfolgreich.');
        print('Kachelserver: ${metadata.host}');
        print('Radarframes: ${metadata.frames.length}');
        print('Neuester Frame: ${latestFrame.time.toLocal()}');
        print('Kachelvorlage: $tileTemplate');

        expect(metadata.frames, isNotEmpty);
        expect(metadata.host, startsWith('https://'));
        expect(tileTemplate, contains('{z}'));
        expect(tileTemplate, contains('{x}'));
        expect(tileTemplate, contains('{y}'));
      } finally {
        client.close();
      }
    },
    skip: 'Nur für kontrollierte RainViewer-Live-Tests ausführen.',
  );
}
