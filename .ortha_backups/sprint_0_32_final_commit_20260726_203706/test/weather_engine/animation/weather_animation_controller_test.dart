import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('WeatherAnimationController', () {
    test('startet mit erstem Frame', () {
      final controller = WeatherAnimationController<String>(
        frames: const <String>['frame-1', 'frame-2', 'frame-3'],
      );

      expect(controller.currentIndex, 0);
      expect(controller.currentFrame, 'frame-1');
      expect(controller.frameCount, 3);
      expect(controller.state, WeatherAnimationState.stopped);

      controller.dispose();
    });

    test('next und previous wechseln Frames', () {
      final controller = WeatherAnimationController<String>(
        frames: const <String>['frame-1', 'frame-2', 'frame-3'],
      );

      controller.next();

      expect(controller.currentIndex, 1);
      expect(controller.currentFrame, 'frame-2');

      controller.previous();

      expect(controller.currentIndex, 0);
      expect(controller.currentFrame, 'frame-1');

      controller.dispose();
    });

    test('loop springt vom letzten zum ersten Frame', () {
      final controller = WeatherAnimationController<String>(
        frames: const <String>['frame-1', 'frame-2'],
        loop: true,
      );

      controller.seekTo(1);
      controller.next();

      expect(controller.currentIndex, 0);
      expect(controller.currentFrame, 'frame-1');

      controller.dispose();
    });

    test('ohne loop wird Animation abgeschlossen', () {
      final controller = WeatherAnimationController<String>(
        frames: const <String>['frame-1', 'frame-2'],
        loop: false,
      );

      controller.seekTo(1);
      controller.next();

      expect(controller.currentIndex, 1);
      expect(controller.state, WeatherAnimationState.completed);

      controller.dispose();
    });

    test('replaceFrames kann aktuellen Frame erhalten', () {
      final controller = WeatherAnimationController<String>(
        frames: const <String>['frame-1', 'frame-2'],
      );

      controller.seekTo(1);

      controller.replaceFrames(const <String>['frame-0', 'frame-2', 'frame-3']);

      expect(controller.currentFrame, 'frame-2');
      expect(controller.currentIndex, 1);

      controller.dispose();
    });

    test('seekTo weist ungültigen Index zurück', () {
      final controller = WeatherAnimationController<String>(
        frames: const <String>['frame-1', 'frame-2'],
      );

      expect(() => controller.seekTo(5), throwsRangeError);

      controller.dispose();
    });

    testWidgets('play wechselt Frames zeitgesteuert', (tester) async {
      final controller = WeatherAnimationController<String>(
        frames: const <String>['frame-1', 'frame-2', 'frame-3'],
        frameDuration: const Duration(milliseconds: 100),
      );

      controller.play();

      expect(controller.isPlaying, isTrue);
      expect(controller.currentIndex, 0);

      await tester.pump(const Duration(milliseconds: 110));

      expect(controller.currentIndex, 1);

      controller.pause();

      expect(controller.state, WeatherAnimationState.paused);

      controller.dispose();
    });
  });
}
