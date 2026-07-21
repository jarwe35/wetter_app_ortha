import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/models/satellite_layer.dart';
import 'package:wetter_app_ortha/services/radar/rainviewer_radar_service.dart';
import 'package:wetter_app_ortha/services/satellite/rainviewer_satellite_source.dart';

void main() {
  group('RainViewerSatelliteSource', () {
    test('stellt eindeutige Quellenmetadaten bereit', () {
      final source = RainViewerSatelliteSource(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(source.id, 'rainviewer');
      expect(source.name, 'RainViewer');
      expect(source.supportedLayerIds, const ['rainviewer-radar']);
    });

    test('unterstützt ausschließlich den Radar-Layer', () {
      final source = RainViewerSatelliteSource(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      expect(source.supportsLayer('rainviewer-radar'), isTrue);
      expect(source.supportsLayer('esri-world-imagery'), isFalse);
      expect(source.supportsLayer('official-warnings'), isFalse);
    });

    test('liefert verfügbaren Layer bei gültigen Metadaten', () async {
      final client = MockClient(
        (_) async => http.Response(
          '''
          {
            "host": "https://tilecache.rainviewer.com",
            "generated": 1784613600,
            "radar": {
              "past": [
                {
                  "time": 1784613300,
                  "path": "/v2/radar/1784613300"
                }
              ],
              "nowcast": []
            }
          }
          ''',
          200,
          headers: const {'content-type': 'application/json'},
        ),
      );

      final source = RainViewerSatelliteSource(httpClient: client);
      final states = await source.load(latitude: 51.2277, longitude: 6.7735);

      expect(states, hasLength(1));

      final state = states.single;

      expect(state.definition.id, 'rainviewer-radar');
      expect(state.availability, SatelliteLayerAvailability.available);
      expect(state.observationTimeUtc, isNotNull);
      expect(state.lastUpdatedUtc, isNotNull);
      expect(state.statusMessage?.toLowerCase(), contains('radar'));
    });

    test('liefert Fehlerzustand bei Radarfehler', () async {
      final service = RainViewerRadarService(
        httpClient: MockClient((_) async => http.Response('Serverfehler', 500)),
      );

      final source = RainViewerSatelliteSource(radarService: service);

      final states = await source.load(latitude: 51.2277, longitude: 6.7735);

      expect(states, hasLength(1));
      expect(states.single.availability, SatelliteLayerAvailability.error);
      expect(states.single.statusMessage, isNotEmpty);
    });

    test('erzeugt Kachel-URL für neuesten Radarframe', () {
      final source = RainViewerSatelliteSource(
        httpClient: MockClient((_) async => http.Response('{}', 200)),
      );

      final metadata = RainViewerRadarMetadata(
        host: 'https://tilecache.rainviewer.com',
        generatedAt: DateTime.utc(2026, 7, 21, 6),
        frames: [
          RainViewerRadarFrame(
            time: DateTime.utc(2026, 7, 21, 5, 50),
            path: '/v2/radar/test-frame',
          ),
        ],
      );

      final template = source.tileUrlTemplate(metadata);

      expect(template, contains('tilecache.rainviewer.com'));
      expect(template, contains('/v2/radar/test-frame/'));
      expect(template, contains('{z}/{x}/{y}'));
      expect(template, endsWith('.png'));
    });
  });
}
