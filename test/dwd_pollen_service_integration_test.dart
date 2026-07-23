import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/models/pollen_forecast.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_download_client.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_provider.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_locator.dart';
import 'package:wetter_app_ortha/services/pollen_service.dart';

void main() {
  group('DWD PollenService Integration', () {
    test('verwendet DWD für eine bekannte konfigurierte Region', () async {
      final dwdProvider = DwdPollenProvider(
        regionLocator: const DwdPollenRegionIdLocator(
          regionId: 40,
          partRegionId: 41,
        ),
        downloadClient: DwdPollenDownloadClient(
          sourceUri: Uri.parse('https://example.test/dwd.json'),
          httpClient: MockClient((_) async => http.Response(_dwdFixture, 200)),
        ),
      );

      final service = PollenService(
        preferredProviders: [dwdProvider],
        client: MockClient((_) async {
          fail(
            'Open-Meteo darf bei erfolgreichem DWD-Provider '
            'nicht aufgerufen werden.',
          );
        }),
      );

      final forecast = await service.loadForecast(
        latitude: 51.2254,
        longitude: 6.7763,
      );

      expect(forecast.days, hasLength(3));

      final grass = forecast.days.first.values.firstWhere(
        (value) => value.type == PollenType.grass,
      );

      expect(grass.concentration, 70);
    });

    test(
      'fällt bei nicht gefundener DWD-Region auf Open-Meteo zurück',
      () async {
        final dwdProvider = DwdPollenProvider(
          regionLocator: const DwdPollenRegionIdLocator(
            regionId: 99,
            partRegionId: 99,
          ),
          downloadClient: DwdPollenDownloadClient(
            sourceUri: Uri.parse('https://example.test/dwd.json'),
            httpClient: MockClient(
              (_) async => http.Response(_dwdFixture, 200),
            ),
          ),
        );

        var fallbackWasCalled = false;

        final service = PollenService(
          preferredProviders: [dwdProvider],
          client: MockClient((_) async {
            fallbackWasCalled = true;
            return http.Response(_openMeteoFixture, 200);
          }),
        );

        final forecast = await service.loadForecast(
          latitude: 51.2254,
          longitude: 6.7763,
        );

        expect(fallbackWasCalled, isTrue);
        expect(forecast.days, hasLength(1));

        final grass = forecast.days.first.values.firstWhere(
          (value) => value.type == PollenType.grass,
        );

        expect(grass.concentration, 35);
      },
    );
  });
}

const _dwdFixture = '''
{
  "name": "Pollenflug-Gefahrenindex",
  "sender": "Deutscher Wetterdienst",
  "last_update": "2026-07-23 11:00 Uhr",
  "next_update": "2026-07-24 11:00 Uhr",
  "legend": {},
  "content": [
    {
      "region_id": 40,
      "partregion_id": 41,
      "region_name": "Nordrhein-Westfalen",
      "partregion_name": "Rhein.-Westfäl. Tiefland",
      "Pollen": {
        "Hasel": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Erle": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Esche": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Birke": {
          "today": "1",
          "tomorrow": "1-2",
          "dayafter_to": "2"
        },
        "Graeser": {
          "today": "2-3",
          "tomorrow": "3",
          "dayafter_to": "2"
        },
        "Roggen": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Beifuss": {
          "today": "1",
          "tomorrow": "1-2",
          "dayafter_to": "2"
        },
        "Ambrosia": {
          "today": "0-1",
          "tomorrow": "1",
          "dayafter_to": "1-2"
        }
      }
    }
  ]
}
''';

const _openMeteoFixture = '''
{
  "latitude": 51.2254,
  "longitude": 6.7763,
  "timezone": "Europe/Berlin",
  "hourly": {
    "time": ["2026-07-23T00:00"],
    "alder_pollen": [1.0],
    "birch_pollen": [3.0],
    "grass_pollen": [35.0],
    "mugwort_pollen": [2.0],
    "olive_pollen": [0.0],
    "ragweed_pollen": [1.0]
  }
}
''';
