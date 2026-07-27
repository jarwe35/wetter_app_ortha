import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('RadarPlaybackStatus', () {
    test('enthält alle Orchestrierungszustände', () {
      expect(
        RadarPlaybackStatus.values,
        containsAll(const <RadarPlaybackStatus>[
          RadarPlaybackStatus.idle,
          RadarPlaybackStatus.loadingTimeline,
          RadarPlaybackStatus.ready,
          RadarPlaybackStatus.preloading,
          RadarPlaybackStatus.rendering,
          RadarPlaybackStatus.playing,
          RadarPlaybackStatus.paused,
          RadarPlaybackStatus.completed,
          RadarPlaybackStatus.failed,
          RadarPlaybackStatus.disposed,
        ]),
      );
    });
  });
}
