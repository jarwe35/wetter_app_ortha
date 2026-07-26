import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('WeatherPreloadQueue', () {
    test('verarbeitet Elemente in stabiler Reihenfolge', () async {
      final processed = <String>[];

      final queue = WeatherPreloadQueue<String>(
        operation: (item) async {
          processed.add(item);
        },
      );

      queue.addAll(const <String>['frame-1', 'frame-2', 'frame-3']);

      final results = await queue.process();

      expect(processed, const <String>['frame-1', 'frame-2', 'frame-3']);

      expect(results, hasLength(3));
      expect(results.every((result) => result.isSuccessful), isTrue);
      expect(queue.pendingCount, 0);
      expect(queue.isProcessing, isFalse);
    });

    test('ignoriert doppelte Elemente', () async {
      var callCount = 0;

      final queue = WeatherPreloadQueue<String>(
        operation: (_) async {
          callCount++;
        },
      );

      queue.add('frame-1');
      queue.add('frame-1');
      queue.add('frame-1');

      final results = await queue.process();

      expect(callCount, 1);
      expect(results, hasLength(1));
    });

    test('Fehler eines Elements stoppt Queue nicht', () async {
      final processed = <String>[];

      final queue = WeatherPreloadQueue<String>(
        operation: (item) async {
          processed.add(item);

          if (item == 'frame-2') {
            throw StateError('Preload fehlgeschlagen');
          }
        },
      );

      queue.addAll(const <String>['frame-1', 'frame-2', 'frame-3']);

      final results = await queue.process();

      expect(processed, hasLength(3));
      expect(results[0].status, WeatherPreloadStatus.completed);
      expect(results[1].status, WeatherPreloadStatus.failed);
      expect(results[2].status, WeatherPreloadStatus.completed);
    });

    test('cancel markiert noch offene Elemente als abgebrochen', () async {
      final queue = WeatherPreloadQueue<String>(operation: (_) async {});

      queue.addAll(const <String>['frame-1', 'frame-2']);

      queue.cancel();

      final results = await queue.process();

      expect(
        results.every(
          (result) => result.status == WeatherPreloadStatus.cancelled,
        ),
        isTrue,
      );
    });

    test('reset aktiviert abgebrochene Queue erneut', () async {
      final processed = <String>[];

      final queue = WeatherPreloadQueue<String>(
        operation: (item) async {
          processed.add(item);
        },
      );

      queue.add('frame-1');
      queue.cancel();
      queue.reset();
      queue.add('frame-2');

      final results = await queue.process();

      expect(processed, const <String>['frame-2']);
      expect(results.single.isSuccessful, isTrue);
      expect(queue.isCancelled, isFalse);
    });
  });
}
