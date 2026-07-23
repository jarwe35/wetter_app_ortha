import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/pollen_forecast.dart';
import 'package:wetter_app_ortha/pollen/engine/pollen_fusion_engine.dart';
import 'package:wetter_app_ortha/pollen/models/pollen_provider.dart';

void main() {
  group('PollenFusionEngine', () {
    test('verwendet den ersten erfolgreich antwortenden Provider', () async {
      final expected = PollenForecast(
        latitude: 51.2,
        longitude: 6.8,
        timezone: 'Europe/Berlin',
        days: [
          DailyPollenForecast(
            date: DateTime(2026, 7, 23),
            values: const [
              PollenValue(type: PollenType.grass, concentration: 35),
            ],
          ),
        ],
      );

      final engine = PollenFusionEngine(
        providers: [const _FailingProvider(), _SuccessfulProvider(expected)],
      );

      final result = await engine.loadForecast(latitude: 51.2, longitude: 6.8);

      expect(result, same(expected));
    });

    test('meldet einen Fehler, wenn kein Provider konfiguriert ist', () {
      const engine = PollenFusionEngine(providers: []);

      expect(
        () => engine.loadForecast(latitude: 51.2, longitude: 6.8),
        throwsA(isA<PollenProviderException>()),
      );
    });
  });
}

class _FailingProvider implements PollenProvider {
  const _FailingProvider();

  @override
  String get id => 'failing';

  @override
  String get displayName => 'Fehlerquelle';

  @override
  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) {
    throw const PollenProviderException(
      providerId: 'failing',
      message: 'Testfehler',
    );
  }
}

class _SuccessfulProvider implements PollenProvider {
  const _SuccessfulProvider(this.forecast);

  final PollenForecast forecast;

  @override
  String get id => 'successful';

  @override
  String get displayName => 'Testquelle';

  @override
  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) async {
    return forecast;
  }
}
