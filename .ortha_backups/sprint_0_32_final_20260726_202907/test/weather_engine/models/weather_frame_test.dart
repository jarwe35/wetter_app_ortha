import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('WeatherFrame', () {
    test('erkennt einen einsatzbereiten Frame', () {
      final frame = WeatherFrame(
        id: 'radar-20260726-1000',
        layerType: WeatherLayerType.radar,
        validTime: DateTime.utc(2026, 7, 26, 10),
        generatedAt: DateTime.utc(2026, 7, 26, 9, 55),
        providerId: 'dwd',
        state: WeatherFrameState.ready,
      );

      expect(frame.isReady, isTrue);
      expect(frame.hasError, isFalse);
    });

    test('copyWith verändert nur ausgewählte Werte', () {
      final frame = WeatherFrame(
        id: 'radar-1',
        layerType: WeatherLayerType.radar,
        validTime: DateTime.utc(2026, 7, 26, 10),
        generatedAt: DateTime.utc(2026, 7, 26, 9, 55),
        providerId: 'dwd',
        state: WeatherFrameState.loading,
      );

      final updated = frame.copyWith(state: WeatherFrameState.ready);

      expect(updated.id, frame.id);
      expect(updated.providerId, frame.providerId);
      expect(updated.state, WeatherFrameState.ready);
    });
  });
}
