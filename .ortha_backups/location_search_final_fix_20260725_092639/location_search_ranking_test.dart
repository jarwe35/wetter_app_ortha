import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/services/location_service.dart';

void main() {
  group('LocationService Suchreihenfolge', () {
    test('New York wird vor dem unscharfen Treffer York einsortiert', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.queryParameters['name'], 'New York');
        expect(request.url.queryParameters['count'], '10');

        return http.Response(
          jsonEncode({
            'results': [
              {
                'name': 'York',
                'latitude': 40.86807,
                'longitude': -97.592,
                'admin1': 'Nebraska',
                'country': 'Vereinigte Staaten',
                'timezone': 'America/Chicago',
              },
              {
                'name': 'New York',
                'latitude': 40.7128,
                'longitude': -74.0060,
                'admin1': 'New York',
                'country': 'Vereinigte Staaten',
                'timezone': 'America/New_York',
              },
            ],
          }),
          200,
          headers: const {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final service = LocationService(httpClient: client);

      final results = await service.searchLocations('New York');

      expect(results, hasLength(2));

      expect(results.first.name, 'New York');
      expect(results.first.latitude, closeTo(40.7128, 0.0001));
      expect(results.first.longitude, closeTo(-74.0060, 0.0001));

      expect(results.last.name, 'York');
      expect(results.last.admin1, 'Nebraska');
    });

    test(
      'Mehrteilige Suchbegriffe bevorzugen Treffer mit allen Wörtern',
      () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'results': [
                {
                  'name': 'York',
                  'latitude': 40.86807,
                  'longitude': -97.592,
                  'admin1': 'Nebraska',
                  'country': 'Vereinigte Staaten',
                },
                {
                  'name': 'New York',
                  'latitude': 40.7128,
                  'longitude': -74.0060,
                  'admin1': 'New York',
                  'country': 'Vereinigte Staaten',
                },
                {
                  'name': 'New York Mills',
                  'latitude': 43.1053,
                  'longitude': -75.2913,
                  'admin1': 'New York',
                  'country': 'Vereinigte Staaten',
                },
              ],
            }),
            200,
            headers: const {'content-type': 'application/json; charset=utf-8'},
          );
        });

        final service = LocationService(httpClient: client);

        final results = await service.searchLocations('New York');

        expect(results.first.name, 'New York');
        expect(results[1].name, 'New York Mills');
        expect(results.last.name, 'York');
      },
    );
  });
}
