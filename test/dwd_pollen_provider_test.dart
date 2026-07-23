import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:wetter_app_ortha/models/pollen_forecast.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_download_client.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_provider.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_locator.dart';
import 'package:wetter_app_ortha/pollen/models/pollen_provider.dart';

void main() {
  group('DwdPollenProvider', () {
    final sourceUri = Uri.parse('https://example.test/s31fg.json');

    test('liefert eine ORTHA-Pollenvorhersage', () async {
      final provider = DwdPollenProvider(
        regionLocator: const DwdPollenRegionIdLocator(
          regionId: 40,
          partRegionId: 41,
        ),
        downloadClient: DwdPollenDownloadClient(
          sourceUri: sourceUri,
          httpClient: MockClient((_) async => http.Response(_fixture, 200)),
        ),
        clock: () => DateTime(2026, 7, 23),
      );

      final forecast = await provider.loadForecast(
        latitude: 51.2,
        longitude: 6.8,
      );

      expect(provider.id, 'dwd-pollen');
      expect(provider.displayName, 'Deutscher Wetterdienst');
      expect(forecast.days, hasLength(3));

      final grass = forecast.days.first.values.firstWhere(
        (value) => value.type == PollenType.grass,
      );

      expect(grass.concentration, 40);
    });

    test('kapselt Downloadfehler als PollenProviderException', () {
      final provider = DwdPollenProvider(
        regionLocator: const DwdPollenRegionIdLocator(
          regionId: 40,
          partRegionId: 41,
        ),
        downloadClient: DwdPollenDownloadClient(
          sourceUri: sourceUri,
          httpClient: MockClient((_) async => http.Response('Fehler', 503)),
        ),
      );

      expect(
        () => provider.loadForecast(latitude: 51.2, longitude: 6.8),
        throwsA(
          isA<PollenProviderException>().having(
            (error) => error.providerId,
            'providerId',
            'dwd-pollen',
          ),
        ),
      );
    });

    test('kapselt eine fehlende Region als Providerfehler', () {
      final provider = DwdPollenProvider(
        regionLocator: const DwdPollenRegionIdLocator(
          regionId: 90,
          partRegionId: 91,
        ),
        downloadClient: DwdPollenDownloadClient(
          sourceUri: sourceUri,
          httpClient: MockClient((_) async => http.Response(_fixture, 200)),
        ),
      );

      expect(
        () => provider.loadForecast(latitude: 51.2, longitude: 6.8),
        throwsA(isA<PollenProviderException>()),
      );
    });
  });
}

const _fixture = '''
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
          "today": "2",
          "tomorrow": "2-3",
          "dayafter_to": "3"
        },
        "Roggen": {
          "today": "0",
          "tomorrow": "0",
          "dayafter_to": "0"
        },
        "Beifuss": {
          "today": "1",
          "tomorrow": "1",
          "dayafter_to": "1-2"
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
