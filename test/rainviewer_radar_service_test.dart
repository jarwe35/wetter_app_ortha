import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/radar/rainviewer_radar_service.dart';

void main() {
  group('RainViewerRadarService', () {
    test('liest und sortiert Radar-Metadaten', () async {
      final client = MockClient((request) async {
        expect(
          request.url.toString(),
          'https://api.rainviewer.com/public/weather-maps.json',
        );

        return Response('''
{
  "version": "2.0",
  "generated": 1609402525,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": [
      {
        "time": 1609402200,
        "path": "/v2/radar/1609402200"
      },
      {
        "time": 1609401600,
        "path": "/v2/radar/1609401600"
      }
    ]
  }
}
''', 200);
      });

      final service = RainViewerRadarService(httpClient: client);
      final metadata = await service.fetchMetadata();

      expect(metadata.host, 'https://tilecache.rainviewer.com');
      expect(metadata.frames, hasLength(2));
      expect(
        metadata.frames.first.time,
        DateTime.fromMillisecondsSinceEpoch(1609401600 * 1000, isUtc: true),
      );
      expect(metadata.latestFrame.path, '/v2/radar/1609402200');
    });

    test('erzeugt eine gültige XYZ-Kachelvorlage', () {
      final metadata = RainViewerRadarMetadata(
        host: 'https://tilecache.rainviewer.com',
        generatedAt: DateTime.utc(2026),
        frames: [
          RainViewerRadarFrame(
            time: DateTime.utc(2026),
            path: '/v2/radar/1234567890',
          ),
        ],
      );

      final template = metadata.tileUrlTemplate(frame: metadata.latestFrame);

      expect(
        template,
        'https://tilecache.rainviewer.com'
        '/v2/radar/1234567890'
        '/256/{z}/{x}/{y}/2/1_1.png',
      );
    });

    test('meldet Zeitüberschreitung kontrolliert', () async {
      final client = MockClient((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 50));

        return Response('{}', 200);
      });

      final service = RainViewerRadarService(
        httpClient: client,
        requestTimeout: const Duration(milliseconds: 5),
      );

      expect(
        service.fetchMetadata,
        throwsA(
          isA<RainViewerRadarException>().having(
            (error) => error.message,
            'message',
            contains('nicht rechtzeitig'),
          ),
        ),
      );
    });

    test('verwendet gültige Metadaten aus dem Cache', () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        return Response('''
{
  "generated": 1710000300,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": [
      {
        "time": 1710000000,
        "path": "/v2/radar/1710000000"
      }
    ]
  }
}
''', 200);
      });

      final service = RainViewerRadarService(httpClient: client);

      final first = await service.fetchMetadata();
      final second = await service.fetchMetadata();

      expect(requestCount, 1);
      expect(identical(first, second), isTrue);
    });

    test('lädt Metadaten nach Ablauf des Cache erneut', () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        return Response('''
{
  "generated": 1710000300,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": [
      {
        "time": 1710000000,
        "path": "/v2/radar/1710000000"
      }
    ]
  }
}
''', 200);
      });

      final service = RainViewerRadarService(
        httpClient: client,
        cacheDuration: const Duration(milliseconds: 5),
      );

      await service.fetchMetadata();

      await Future<void>.delayed(const Duration(milliseconds: 20));

      await service.fetchMetadata();

      expect(requestCount, 2);
    });

    test('forceRefresh umgeht den Metadaten-Cache', () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        return Response('''
{
  "generated": 1710000300,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": [
      {
        "time": 1710000000,
        "path": "/v2/radar/1710000000"
      }
    ]
  }
}
''', 200);
      });

      final service = RainViewerRadarService(httpClient: client);

      await service.fetchMetadata();
      await service.fetchMetadata(forceRefresh: true);

      expect(requestCount, 2);
    });

    test('fasst parallele Metadaten-Abrufe zusammen', () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        await Future<void>.delayed(const Duration(milliseconds: 20));

        return Response('''
{
  "generated": 1710000300,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": [
      {
        "time": 1710000000,
        "path": "/v2/radar/1710000000"
      }
    ]
  }
}
''', 200);
      });

      final service = RainViewerRadarService(httpClient: client);

      final results = await Future.wait([
        service.fetchMetadata(),
        service.fetchMetadata(),
      ]);

      expect(requestCount, 1);
      expect(identical(results[0], results[1]), isTrue);
    });

    test('verwendet abgelaufenen Cache bei Radarserver-Ausfall', () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        if (requestCount == 1) {
          return Response('''
{
  "generated": 1710000300,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": [
      {
        "time": 1710000000,
        "path": "/v2/radar/1710000000"
      }
    ]
  }
}
''', 200);
        }

        return Response('Serverfehler', 503);
      });

      final service = RainViewerRadarService(
        httpClient: client,
        cacheDuration: Duration.zero,
      );

      final first = await service.fetchMetadata();
      final fallback = await service.fetchMetadata();

      expect(requestCount, 2);
      expect(identical(first, fallback), isTrue);
    });

    test(
      'forceRefresh verwendet bei Serverfehler keinen alten Cache',
      () async {
        var requestCount = 0;

        final client = MockClient((request) async {
          requestCount += 1;

          if (requestCount == 1) {
            return Response('''
{
  "generated": 1710000300,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": [
      {
        "time": 1710000000,
        "path": "/v2/radar/1710000000"
      }
    ]
  }
}
''', 200);
          }

          return Response('Serverfehler', 503);
        });

        final service = RainViewerRadarService(
          httpClient: client,
          cacheDuration: Duration.zero,
        );

        await service.fetchMetadata();

        await expectLater(
          service.fetchMetadata(forceRefresh: true),
          throwsA(isA<RainViewerRadarException>()),
        );

        expect(requestCount, 2);
      },
    );

    test('meldet HTTP-Fehler kontrolliert', () async {
      final client = MockClient((request) async {
        return Response('Serverfehler', 503);
      });

      final service = RainViewerRadarService(httpClient: client);

      expect(service.fetchMetadata, throwsA(isA<RainViewerRadarException>()));
    });

    test('meldet ungültiges JSON kontrolliert', () async {
      final client = MockClient((request) async {
        return Response('kein JSON', 200);
      });

      final service = RainViewerRadarService(httpClient: client);

      expect(service.fetchMetadata, throwsA(isA<RainViewerRadarException>()));
    });

    test('meldet fehlende Radarframes kontrolliert', () async {
      final client = MockClient((request) async {
        return Response('''
{
  "generated": 1609402525,
  "host": "https://tilecache.rainviewer.com",
  "radar": {
    "past": []
  }
}
''', 200);
      });

      final service = RainViewerRadarService(httpClient: client);

      expect(service.fetchMetadata, throwsA(isA<RainViewerRadarException>()));
    });
  });
}
