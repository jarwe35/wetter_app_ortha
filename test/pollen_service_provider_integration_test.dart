import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/models/pollen_forecast.dart';
import 'package:wetter_app_ortha/pollen/models/pollen_provider.dart';
import 'package:wetter_app_ortha/services/pollen_service.dart';

void main() {
  group('PollenService Multi-Provider-Integration', () {
    test('verwendet einen bevorzugten Provider vor Open-Meteo', () async {
      final expected = _forecast(concentration: 70);

      final service = PollenService(
        preferredProviders: [_SuccessfulProvider(expected)],
        client: MockClient((_) async {
          fail(
            'Open-Meteo darf bei erfolgreichem Erstprovider nicht '
            'aufgerufen werden.',
          );
        }),
      );

      final result = await service.loadForecast(
        latitude: 51.2254,
        longitude: 6.7763,
      );

      expect(result, same(expected));
    });

    test('verwendet Open-Meteo als Fallback', () async {
      var openMeteoWasCalled = false;

      final service = PollenService(
        preferredProviders: const [_FailingProvider()],
        client: MockClient((request) async {
          openMeteoWasCalled = true;

          expect(request.url.host, 'air-quality-api.open-meteo.com');

          return http.Response(_openMeteoFixture, 200);
        }),
      );

      final result = await service.loadForecast(
        latitude: 51.2254,
        longitude: 6.7763,
      );

      expect(openMeteoWasCalled, isTrue);
      expect(result.days, hasLength(1));

      final grass = result.days.single.values.firstWhere(
        (value) => value.type == PollenType.grass,
      );

      expect(grass.concentration, 35);
    });

    test('bestehender Standardkonstruktor bleibt funktionsfähig', () async {
      final service = PollenService(
        client: MockClient((_) async => http.Response(_openMeteoFixture, 200)),
      );

      final result = await service.loadForecast(
        latitude: 51.2254,
        longitude: 6.7763,
      );

      expect(result.latitude, 51.2254);
      expect(result.longitude, 6.7763);
    });

    test('meldet zusammengefassten Fehler aller Provider', () {
      final service = PollenService(
        preferredProviders: const [_FailingProvider()],
        client: MockClient((_) async => http.Response('Serverfehler', 503)),
      );

      expect(
        () => service.loadForecast(latitude: 51.2254, longitude: 6.7763),
        throwsA(
          isA<PollenServiceException>().having(
            (error) => error.message,
            'message',
            allOf(
              contains('Keine Pollendatenquelle'),
              contains('Testquelle'),
              contains('Open-Meteo'),
            ),
          ),
        ),
      );
    });
  });
}

class _FailingProvider implements PollenProvider {
  const _FailingProvider();

  @override
  String get id => 'failing-test-provider';

  @override
  String get displayName => 'Testquelle';

  @override
  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) {
    throw const PollenProviderException(
      providerId: 'failing-test-provider',
      message: 'Geplanter Testfehler',
    );
  }
}

class _SuccessfulProvider implements PollenProvider {
  const _SuccessfulProvider(this.forecast);

  final PollenForecast forecast;

  @override
  String get id => 'successful-test-provider';

  @override
  String get displayName => 'Erfolgreiche Testquelle';

  @override
  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) async {
    return forecast;
  }
}

PollenForecast _forecast({required double concentration}) {
  return PollenForecast(
    latitude: 51.2254,
    longitude: 6.7763,
    timezone: 'Europe/Berlin',
    days: [
      DailyPollenForecast(
        date: DateTime(2026, 7, 23),
        values: [
          PollenValue(type: PollenType.grass, concentration: concentration),
        ],
      ),
    ],
  );
}

const _openMeteoFixture = '''
{
  "latitude": 51.2254,
  "longitude": 6.7763,
  "timezone": "Europe/Berlin",
  "hourly": {
    "time": [
      "2026-07-23T00:00",
      "2026-07-23T01:00"
    ],
    "alder_pollen": [1.0, 2.0],
    "birch_pollen": [3.0, 5.0],
    "grass_pollen": [20.0, 35.0],
    "mugwort_pollen": [2.0, 4.0],
    "olive_pollen": [0.0, 0.0],
    "ragweed_pollen": [1.0, 2.0]
  }
}
''';
