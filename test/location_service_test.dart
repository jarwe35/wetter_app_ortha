import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/location_service.dart';

void main() {
  group('LocationService', () {
    test('löst einen Ort vollständig auf', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.path, '/v1/search');
        expect(request.url.queryParameters['name'], 'Duisburg');
        expect(request.url.queryParameters['count'], '1');
        expect(request.url.queryParameters['language'], 'de');
        expect(request.url.queryParameters['format'], 'json');

        return Response('''
{
  "results": [
    {
      "name": "Duisburg",
      "latitude": 51.4344,
      "longitude": 6.7623,
      "country": "Deutschland",
      "timezone": "Europe/Berlin"
    }
  ]
}
''', 200);
      });

      final service = LocationService(httpClient: client);
      final location = await service.resolveLocation('Duisburg');

      expect(location.name, 'Duisburg');
      expect(location.latitude, 51.4344);
      expect(location.longitude, 6.7623);
      expect(location.country, 'Deutschland');
      expect(location.timezone, 'Europe/Berlin');
    });

    test('entfernt Leerzeichen aus der Suchanfrage', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['name'], 'Oslo');

        return Response('''
{
  "results": [
    {
      "name": "Oslo",
      "latitude": 59.9139,
      "longitude": 10.7522
    }
  ]
}
''', 200);
      });

      final service = LocationService(httpClient: client);
      final location = await service.resolveLocation('  Oslo  ');

      expect(location.name, 'Oslo');
    });

    test('unterstützt fehlende optionale Felder', () async {
      final client = MockClient((request) async {
        return Response('''
{
  "results": [
    {
      "name": "Bali",
      "latitude": -8.4095,
      "longitude": 115.1889
    }
  ]
}
''', 200);
      });

      final service = LocationService(httpClient: client);
      final location = await service.resolveLocation('Bali');

      expect(location.country, isNull);
      expect(location.timezone, isNull);
    });

    test('lehnt einen leeren Ortsnamen ab', () async {
      final service = LocationService(
        httpClient: MockClient((request) async {
          fail('Bei leerem Ortsnamen darf kein HTTP-Abruf erfolgen.');
        }),
      );

      expect(
        () => service.resolveLocation('   '),
        throwsA(isA<LocationServiceException>()),
      );
    });

    test('meldet nicht gefundenen Ort kontrolliert', () async {
      final client = MockClient((request) async {
        return Response('{"results":[]}', 200);
      });

      final service = LocationService(httpClient: client);

      expect(
        () => service.resolveLocation('Unbekannter Ort'),
        throwsA(
          isA<LocationServiceException>().having(
            (error) => error.message,
            'message',
            contains('nicht gefunden'),
          ),
        ),
      );
    });

    test('meldet HTTP-Fehler kontrolliert', () async {
      final client = MockClient((request) async {
        return Response('Serverfehler', 503);
      });

      final service = LocationService(httpClient: client);

      expect(
        () => service.resolveLocation('Duisburg'),
        throwsA(
          isA<LocationServiceException>().having(
            (error) => error.message,
            'message',
            contains('HTTP 503'),
          ),
        ),
      );
    });

    test('meldet ungültiges JSON kontrolliert', () async {
      final client = MockClient((request) async {
        return Response('kein JSON', 200);
      });

      final service = LocationService(httpClient: client);

      expect(
        () => service.resolveLocation('Duisburg'),
        throwsA(isA<LocationServiceException>()),
      );
    });

    test('meldet unvollständige Standortdaten kontrolliert', () async {
      final client = MockClient((request) async {
        return Response('''
{
  "results": [
    {
      "name": "Duisburg"
    }
  ]
}
''', 200);
      });

      final service = LocationService(httpClient: client);

      expect(
        () => service.resolveLocation('Duisburg'),
        throwsA(
          isA<LocationServiceException>().having(
            (error) => error.message,
            'message',
            contains('unvollständige Standortdaten'),
          ),
        ),
      );
    });
  });
}
