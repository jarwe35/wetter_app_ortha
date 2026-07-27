import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('WeatherProviderRequest', () {
    test('copyWith übernimmt bestehende Werte', () {
      const request = WeatherProviderRequest(
        layerType: WeatherLayerType.radar,
        locale: 'de',
        maximumFrameCount: 12,
      );

      final updated = request.copyWith(locale: 'en');

      expect(updated.layerType, WeatherLayerType.radar);
      expect(updated.locale, 'en');
      expect(updated.maximumFrameCount, 12);
    });
  });

  group('RadarProviderRequest', () {
    test('wird korrekt in allgemeine Provideranfrage umgewandelt', () {
      const radarRequest = RadarProviderRequest(
        locale: 'de',
        maximumFrameCount: 10,
        includeForecastFrames: false,
        includeHistoricalFrames: true,
      );

      final request = radarRequest.toWeatherProviderRequest();

      expect(request.layerType, WeatherLayerType.radar);
      expect(request.locale, 'de');
      expect(request.maximumFrameCount, 10);
      expect(request.metadata['includeForecastFrames'], isFalse);
      expect(request.metadata['includeHistoricalFrames'], isTrue);
    });
  });
}
