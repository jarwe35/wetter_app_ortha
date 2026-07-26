import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:wetter_app_ortha/services/radar/rainviewer_radar_service.dart';
import 'package:wetter_app_ortha/weather_engine/radar/integration/rainviewer_radar_playback_source.dart';

void main() {
  group('RainViewerRadarPlaybackSource Metadaten', () {
    test('stellt vollständige Metadaten nach Initialisierung bereit', () async {
      final metadataUri = Uri.parse(
        'https://example.test/rainviewer/weather-maps.json',
      );

      final client = MockClient((request) async {
        expect(request.url, metadataUri);

        return http.Response(
          jsonEncode({
            'host': 'https://tilecache.rainviewer.com',
            'generated': 1722000000,
            'radar': {
              'past': [
                {'time': 1721999400, 'path': '/v2/radar/1721999400'},
                {'time': 1722000000, 'path': '/v2/radar/1722000000'},
              ],
            },
          }),
          200,
          headers: const {'content-type': 'application/json'},
        );
      });

      final service = RainViewerRadarService(
        httpClient: client,
        metadataUri: metadataUri,
      );

      final source = RainViewerRadarPlaybackSource(radarService: service);

      expect(source.metadata, isNull);

      await source.initialize();

      final metadata = source.metadata;

      expect(metadata, isNotNull);
      expect(metadata?.host, 'https://tilecache.rainviewer.com');
      expect(metadata?.frames, hasLength(2));
      expect(metadata?.frames.last.path, '/v2/radar/1722000000');
      expect(metadata?.isStale, isFalse);

      source.dispose();
      client.close();
    });

    test('ersetzt Metadaten bei einem erzwungenen Refresh', () async {
      final metadataUri = Uri.parse(
        'https://example.test/rainviewer/weather-maps.json',
      );

      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        final generated = requestCount == 1 ? 1722000000 : 1722000600;

        final frameTime = requestCount == 1 ? 1722000000 : 1722000600;

        return http.Response(
          jsonEncode({
            'host': 'https://tilecache.rainviewer.com',
            'generated': generated,
            'radar': {
              'past': [
                {'time': frameTime, 'path': '/v2/radar/$frameTime'},
              ],
            },
          }),
          200,
        );
      });

      final service = RainViewerRadarService(
        httpClient: client,
        metadataUri: metadataUri,
      );

      final source = RainViewerRadarPlaybackSource(radarService: service);

      await source.initialize();

      final firstMetadata = source.metadata;
      final firstGeneratedAt = firstMetadata?.generatedAt;

      await source.refresh();

      final refreshedMetadata = source.metadata;

      expect(requestCount, 2);
      expect(refreshedMetadata, isNotNull);
      expect(refreshedMetadata?.generatedAt, isNot(firstGeneratedAt));
      expect(refreshedMetadata?.frames.single.path, '/v2/radar/1722000600');

      source.dispose();
      client.close();
    });

    test(
      'behält letzte erfolgreiche Metadaten bei einem Refresh-Fehler',
      () async {
        final metadataUri = Uri.parse(
          'https://example.test/rainviewer/weather-maps.json',
        );

        var requestCount = 0;

        final client = MockClient((request) async {
          requestCount += 1;

          if (requestCount == 1) {
            return http.Response(
              jsonEncode({
                'host': 'https://tilecache.rainviewer.com',
                'generated': 1722000000,
                'radar': {
                  'past': [
                    {'time': 1722000000, 'path': '/v2/radar/1722000000'},
                  ],
                },
              }),
              200,
            );
          }

          return http.Response('Serverfehler', 500);
        });

        final service = RainViewerRadarService(
          httpClient: client,
          metadataUri: metadataUri,
        );

        final source = RainViewerRadarPlaybackSource(radarService: service);

        await source.initialize();

        final successfulMetadata = source.metadata;

        expect(successfulMetadata, isNotNull);

        await expectLater(
          source.refresh(),
          throwsA(isA<RainViewerRadarException>()),
        );

        expect(source.metadata, same(successfulMetadata));

        source.dispose();
        client.close();
      },
    );

    test('entfernt Metadaten beim Dispose', () async {
      final metadataUri = Uri.parse(
        'https://example.test/rainviewer/weather-maps.json',
      );

      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'host': 'https://tilecache.rainviewer.com',
            'generated': 1722000000,
            'radar': {
              'past': [
                {'time': 1722000000, 'path': '/v2/radar/1722000000'},
              ],
            },
          }),
          200,
        );
      });

      final service = RainViewerRadarService(
        httpClient: client,
        metadataUri: metadataUri,
      );

      final source = RainViewerRadarPlaybackSource(radarService: service);

      await source.initialize();

      expect(source.metadata, isNotNull);

      source.dispose();

      expect(source.metadata, isNull);

      client.close();
    });
  });
}
