import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:wetter_app_ortha/services/radar/ortha_radar_frame_cache.dart';

void main() {
  group('OrthaRadarFrameCache', () {
    test(
      'lädt eine Kachel und liefert sie anschließend aus dem Cache',
      () async {
        var requestCount = 0;

        final client = MockClient((request) async {
          requestCount++;

          return http.Response.bytes(utf8.encode('radar-tile'), 200);
        });

        final cache = OrthaRadarFrameCache(httpClient: client);
        final uri = Uri.parse('https://example.test/radar/1.png');

        final first = await cache.loadTile(uri);
        final second = await cache.loadTile(uri);

        expect(first, isNotNull);
        expect(second, isNotNull);
        expect(cache.contains(uri), isTrue);
        expect(cache.cachedTileCount, 1);
        expect(requestCount, 1);

        cache.dispose();
        client.close();
      },
    );

    test('entfernt doppelte URLs während der Vorladephase', () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount++;

        return http.Response.bytes(utf8.encode(request.url.toString()), 200);
      });

      final cache = OrthaRadarFrameCache(
        httpClient: client,
        maximumConcurrentRequests: 2,
      );

      final first = Uri.parse('https://example.test/radar/1.png');
      final second = Uri.parse('https://example.test/radar/2.png');

      final result = await cache.preload([first, first, second, second]);

      expect(result.requestedTileCount, 2);
      expect(result.loadedTileCount, 2);
      expect(result.failedTileCount, 0);
      expect(result.isComplete, isTrue);
      expect(requestCount, 2);

      cache.dispose();
      client.close();
    });

    test('registriert fehlerhafte Antworten', () async {
      final client = MockClient((request) async {
        return http.Response('nicht verfügbar', 503);
      });

      final cache = OrthaRadarFrameCache(httpClient: client);

      final result = await cache.preload([
        Uri.parse('https://example.test/radar/error.png'),
      ]);

      expect(result.requestedTileCount, 1);
      expect(result.loadedTileCount, 0);
      expect(result.failedTileCount, 1);
      expect(result.isComplete, isFalse);

      cache.dispose();
      client.close();
    });

    test('behält nur noch benötigte Kacheln', () async {
      final client = MockClient((request) async {
        return http.Response.bytes(utf8.encode(request.url.toString()), 200);
      });

      final cache = OrthaRadarFrameCache(httpClient: client);

      final first = Uri.parse('https://example.test/radar/1.png');
      final second = Uri.parse('https://example.test/radar/2.png');

      await cache.preload([first, second]);

      cache.retainOnly([second]);

      expect(cache.contains(first), isFalse);
      expect(cache.contains(second), isTrue);
      expect(cache.cachedTileCount, 1);

      cache.dispose();
      client.close();
    });
  });
}
