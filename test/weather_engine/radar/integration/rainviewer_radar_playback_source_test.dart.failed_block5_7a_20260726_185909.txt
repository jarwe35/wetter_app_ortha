import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/radar/rainviewer_radar_service.dart';
import 'package:wetter_app_ortha/weather_engine/models/weather_frame.dart';
import 'package:wetter_app_ortha/weather_engine/radar/integration/rainviewer_radar_playback_source.dart';
import 'package:wetter_app_ortha/weather_engine/radar/playback/radar_playback_status.dart';

void main() {
  group('RainViewerRadarPlaybackSource', () {
    test('startet im Status idle', () {
      final client = MockClient((_) async {
        return http.Response('{}', 200);
      });

      final source = RainViewerRadarPlaybackSource(
        radarService: RainViewerRadarService(httpClient: client),
      );

      expect(source.snapshot.status, RadarPlaybackStatus.idle);
      expect(source.snapshot.frames, isEmpty);
      expect(source.snapshot.currentOutput, isNull);
      expect(source.isInitialized, isFalse);
      expect(source.isLoading, isFalse);
      expect(source.isDisposed, isFalse);

      source.dispose();
      client.close();
    });

    test('lädt Timeline und wählt den neuesten Frame', () async {
      final client = MockClient((_) async {
        return http.Response(
          jsonEncode({
            'host': 'https://tilecache.rainviewer.com',
            'generated': 1720000000,
            'radar': {
              'past': [
                {'time': 1719999400, 'path': '/v2/radar/1719999400'},
                {'time': 1720000000, 'path': '/v2/radar/1720000000'},
              ],
            },
          }),
          200,
          headers: const {'content-type': 'application/json'},
        );
      });

      final source = RainViewerRadarPlaybackSource(
        radarService: RainViewerRadarService(httpClient: client),
      );

      final statuses = <RadarPlaybackStatus>[];

      source.addListener(() {
        statuses.add(source.snapshot.status);
      });

      await source.initialize();

      expect(statuses, contains(RadarPlaybackStatus.loadingTimeline));
      expect(source.snapshot.status, RadarPlaybackStatus.ready);
      expect(source.snapshot.frames, hasLength(2));
      expect(source.snapshot.currentIndex, 1);
      expect(source.snapshot.currentOutput, isNotNull);
      expect(source.snapshot.currentOutput?.path, '/v2/radar/1720000000');
      expect(source.snapshot.currentFrame, isNotNull);
      expect(source.isInitialized, isTrue);
      expect(source.isLoading, isFalse);

      final firstFrame = source.snapshot.frames.first;
      final latestFrame = source.snapshot.frames.last;

      expect(firstFrame.id, 'rainviewer-radar-1719999400000');
      expect(firstFrame.layerType, WeatherLayerType.radar);
      expect(firstFrame.providerId, 'rainviewer');
      expect(firstFrame.state, WeatherFrameState.ready);
      expect(firstFrame.sourceReference, '/v2/radar/1719999400');
      expect(
        firstFrame.validTime,
        DateTime.fromMillisecondsSinceEpoch(1719999400 * 1000, isUtc: true),
      );
      expect(
        firstFrame.generatedAt,
        DateTime.fromMillisecondsSinceEpoch(1720000000 * 1000, isUtc: true),
      );

      expect(latestFrame.sourceReference, '/v2/radar/1720000000');

      source.dispose();
      client.close();
    });

    test('initialize führt höchstens einen Netzaufruf aus', () async {
      var requestCount = 0;

      final client = MockClient((_) async {
        requestCount += 1;

        return http.Response(
          jsonEncode({
            'host': 'https://tilecache.rainviewer.com',
            'generated': 1720000000,
            'radar': {
              'past': [
                {'time': 1720000000, 'path': '/v2/radar/1720000000'},
              ],
            },
          }),
          200,
        );
      });

      final source = RainViewerRadarPlaybackSource(
        radarService: RainViewerRadarService(httpClient: client),
      );

      await Future.wait([
        source.initialize(),
        source.initialize(),
        source.initialize(),
      ]);

      expect(requestCount, 1);

      await source.initialize();

      expect(requestCount, 1);

      source.dispose();
      client.close();
    });

    test('refresh erzwingt einen neuen Netzaufruf', () async {
      var requestCount = 0;

      final client = MockClient((_) async {
        requestCount += 1;

        final timestamp = 1720000000 + requestCount;

        return http.Response(
          jsonEncode({
            'host': 'https://tilecache.rainviewer.com',
            'generated': timestamp,
            'radar': {
              'past': [
                {'time': timestamp, 'path': '/v2/radar/$timestamp'},
              ],
            },
          }),
          200,
        );
      });

      final source = RainViewerRadarPlaybackSource(
        radarService: RainViewerRadarService(httpClient: client),
      );

      await source.initialize();
      await source.refresh();

      expect(requestCount, 2);
      expect(source.snapshot.status, RadarPlaybackStatus.ready);
      expect(source.snapshot.currentOutput?.path, '/v2/radar/1720000002');

      source.dispose();
      client.close();
    });

    test('übernimmt Fehler in den Snapshot', () async {
      final client = MockClient((_) async {
        return http.Response('Serverfehler', 500);
      });

      final source = RainViewerRadarPlaybackSource(
        radarService: RainViewerRadarService(httpClient: client),
      );

      await expectLater(
        source.initialize(),
        throwsA(isA<RainViewerRadarException>()),
      );

      expect(source.snapshot.status, RadarPlaybackStatus.failed);
      expect(source.snapshot.error, isA<RainViewerRadarException>());
      expect(source.snapshot.stackTrace, isNotNull);
      expect(source.isInitialized, isFalse);
      expect(source.isLoading, isFalse);

      source.dispose();
      client.close();
    });

    test('dispose setzt Status disposed', () {
      final client = MockClient((_) async {
        return http.Response('{}', 200);
      });

      final source = RainViewerRadarPlaybackSource(
        radarService: RainViewerRadarService(httpClient: client),
      );

      source.dispose();

      expect(source.snapshot.status, RadarPlaybackStatus.disposed);
      expect(source.isDisposed, isTrue);

      expect(() => source.initialize(), throwsStateError);

      expect(() => source.refresh(), throwsStateError);

      client.close();
    });
  });
}
