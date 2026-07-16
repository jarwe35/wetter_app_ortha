import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/models/saved_location.dart';
import 'package:wetter_app_ortha/services/weather_service.dart';

void main() {
  group('WeatherService mit SavedLocation', () {
    test(
      'fetchWeatherForLocation verwendet direkt gespeicherte Koordinaten',
      () async {
        var requestCount = 0;

        final client = MockClient((request) async {
          requestCount += 1;

          expect(request.url.host, 'api.open-meteo.com');
          expect(request.url.path, '/v1/forecast');
          expect(request.url.queryParameters['forecast_days'], '14');
          expect(request.url.queryParameters['latitude'], '51.4344');
          expect(request.url.queryParameters['longitude'], '6.7623');

          return Response(_weatherResponseJson, 200);
        });

        final service = WeatherService(httpClient: client);

        const location = SavedLocation(
          name: 'Duisburg',
          latitude: 51.4344,
          longitude: 6.7623,
          country: 'Deutschland',
          timezone: 'Europe/Berlin',
        );

        final data = await service.fetchWeatherForLocation(location);

        expect(requestCount, 1);
        expect(data.place, 'Duisburg');
        expect(data.latitude, 51.4344);
        expect(data.longitude, 6.7623);
        expect(data.temperature, 22.5);
        expect(data.hourlyForecast, hasLength(1));
        expect(data.dailyForecast, hasLength(1));
      },
    );

    test('fetchWeather bleibt mit Geocodierung rückwärtskompatibel', () async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        if (request.url.host == 'geocoding-api.open-meteo.com') {
          expect(request.url.queryParameters['name'], 'Oslo');

          return Response('''
{
  "results": [
    {
      "name": "Oslo",
      "latitude": 59.9139,
      "longitude": 10.7522,
      "country": "Norwegen",
      "timezone": "Europe/Oslo"
    }
  ]
}
''', 200);
        }

        expect(request.url.host, 'api.open-meteo.com');
        expect(request.url.queryParameters['latitude'], '59.9139');
        expect(request.url.queryParameters['longitude'], '10.7522');

        return Response(_weatherResponseJson, 200);
      });

      final service = WeatherService(httpClient: client);
      final data = await service.fetchWeather('Oslo');

      expect(requestCount, 2);
      expect(data.place, 'Oslo');
      expect(data.latitude, 59.9139);
      expect(data.longitude, 10.7522);
    });
  });
}

const String _weatherResponseJson = '''
{
  "current": {
    "time": "2026-07-12T14:00",
    "temperature_2m": 22.5,
    "relative_humidity_2m": 61,
    "apparent_temperature": 23.1,
    "precipitation": 0.0,
    "weather_code": 1,
    "cloud_cover": 22,
    "surface_pressure": 1015.2,
    "wind_speed_10m": 12.4,
    "wind_gusts_10m": 20.1
  },
  "hourly": {
    "time": [
      "2026-07-12T14:00"
    ],
    "temperature_2m": [
      22.5
    ],
    "apparent_temperature": [
      23.1
    ],
    "relative_humidity_2m": [
      61
    ],
    "wind_gusts_10m": [
      20.1
    ],
    "uv_index": [
      4.2
    ],
    "weather_code": [
      1
    ],
    "precipitation_probability": [
      10
    ],
    "visibility": [
      24000.0
    ]
  },
  "daily": {
    "time": [
      "2026-07-12"
    ],
    "weather_code": [
      1
    ],
    "temperature_2m_max": [
      25.0
    ],
    "temperature_2m_min": [
      16.0
    ],
    "precipitation_probability_max": [
      20
    ],
    "uv_index_max": [
      4.2
    ]
  }
}
''';
