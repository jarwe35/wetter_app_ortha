import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  WeatherFrame createFrame(String id, int minute) {
    return WeatherFrame(
      id: id,
      layerType: WeatherLayerType.radar,
      validTime: DateTime.utc(2026, 7, 26, 10, minute),
      generatedAt: DateTime.utc(2026, 7, 26, 9, 55),
      providerId: 'test-provider',
      state: WeatherFrameState.ready,
    );
  }

  group('WeatherTimeline', () {
    test('sortiert Frames chronologisch', () {
      final timeline = WeatherTimeline(
        frames: [
          createFrame('frame-3', 30),
          createFrame('frame-1', 10),
          createFrame('frame-2', 20),
        ],
      );

      expect(timeline.frames.map((frame) => frame.id), [
        'frame-1',
        'frame-2',
        'frame-3',
      ]);
    });

    test('verwendet standardmäßig den neuesten Frame', () {
      final timeline = WeatherTimeline(
        frames: [createFrame('frame-1', 10), createFrame('frame-2', 20)],
      );

      expect(timeline.initialFrame?.id, 'frame-2');
    });

    test('liefert vorherigen und nächsten Frame', () {
      final timeline = WeatherTimeline(
        frames: [
          createFrame('frame-1', 10),
          createFrame('frame-2', 20),
          createFrame('frame-3', 30),
        ],
      );

      expect(timeline.previousOf('frame-2')?.id, 'frame-1');

      expect(timeline.nextOf('frame-2')?.id, 'frame-3');
    });

    test('ermittelt den zeitlich nächsten Frame', () {
      final timeline = WeatherTimeline(
        frames: [
          createFrame('frame-1', 10),
          createFrame('frame-2', 20),
          createFrame('frame-3', 30),
        ],
      );

      final result = timeline.closestTo(DateTime.utc(2026, 7, 26, 10, 24));

      expect(result?.id, 'frame-2');
    });

    test('weist doppelte Frame-IDs zurück', () {
      expect(
        () => WeatherTimeline(
          frames: [createFrame('duplicate', 10), createFrame('duplicate', 20)],
        ),
        throwsArgumentError,
      );
    });
  });
}
