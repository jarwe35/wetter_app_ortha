import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/pollen_forecast.dart';
import 'package:wetter_app_ortha/services/pollen_service.dart';

void main() {
  group('PollenService.parseForecast', () {
    test('bildet stündliche Werte auf Tagesmaxima ab', () {
      final forecast = PollenService.parseForecast({
        'latitude': 51.2,
        'longitude': 6.8,
        'timezone': 'Europe/Berlin',
        'hourly': {
          'time': ['2026-07-20T00:00', '2026-07-20T01:00', '2026-07-21T00:00'],
          'alder_pollen': [1.0, 4.0, 2.0],
          'birch_pollen': [3.0, 7.0, 1.0],
          'grass_pollen': [20.0, 35.0, 12.0],
          'mugwort_pollen': [2.0, 5.0, 4.0],
          'olive_pollen': [0.0, 0.0, 0.0],
          'ragweed_pollen': [1.0, 2.0, 3.0],
        },
      });

      expect(forecast.days, hasLength(2));
      expect(forecast.timezone, 'Europe/Berlin');

      final firstDay = forecast.days.first;
      final grass = firstDay.values.firstWhere(
        (value) => value.type == PollenType.grass,
      );

      expect(grass.concentration, 35.0);
      expect(firstDay.strongestValue?.type, PollenType.grass);
    });

    test('behandelt null und fehlende Werte als null Belastung', () {
      final forecast = PollenService.parseForecast({
        'latitude': 51.2,
        'longitude': 6.8,
        'timezone': 'Europe/Berlin',
        'hourly': {
          'time': ['2026-07-20T00:00'],
          'alder_pollen': [null],
          'birch_pollen': [null],
          'grass_pollen': [null],
          'mugwort_pollen': [null],
          'olive_pollen': [null],
          'ragweed_pollen': [null],
        },
      });

      expect(forecast.days, hasLength(1));
      expect(
        forecast.days.first.values.every((value) => value.concentration == 0),
        isTrue,
      );
    });

    test('weist Konzentrationen Belastungsstufen zu', () {
      expect(
        const PollenValue(type: PollenType.grass, concentration: 0).level,
        PollenLoadLevel.none,
      );

      expect(
        const PollenValue(type: PollenType.grass, concentration: 25).level,
        PollenLoadLevel.moderate,
      );

      expect(
        const PollenValue(type: PollenType.grass, concentration: 120).level,
        PollenLoadLevel.veryHigh,
      );
    });
  });
}
