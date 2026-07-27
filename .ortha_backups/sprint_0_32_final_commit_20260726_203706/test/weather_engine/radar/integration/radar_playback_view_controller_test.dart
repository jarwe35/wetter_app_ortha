import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('RadarPlaybackViewController', () {
    test('initialisiert die Radarquelle nur einmal', () async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      await controller.initialize();
      await controller.initialize();

      expect(source.initializeCalls, 1);
      expect(controller.isInitialized, isTrue);
      expect(controller.isInitializing, isFalse);

      controller.dispose();
      source.dispose();
    });

    test(
      'verwendet bei paralleler Initialisierung dieselbe Operation',
      () async {
        final source = _FakeRadarPlaybackSource();
        final controller = RadarPlaybackViewController<String>(source: source);

        final first = controller.initialize();
        final second = controller.initialize();

        await Future.wait(<Future<void>>[first, second]);

        expect(source.initializeCalls, 1);
        expect(controller.isInitialized, isTrue);

        controller.dispose();
        source.dispose();
      },
    );

    test('reicht Aktualisierung an die Radarquelle weiter', () async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      await controller.refresh();

      expect(source.refreshCalls, 1);

      controller.dispose();
      source.dispose();
    });

    test('meldet Zustandsänderungen der Radarquelle weiter', () {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      var notifications = 0;
      controller.addListener(() {
        notifications++;
      });

      source.emitChange();

      expect(notifications, 1);

      controller.dispose();
      source.dispose();
    });

    test('entfernt Listener beim Dispose', () {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      var notifications = 0;
      controller.addListener(() {
        notifications++;
      });

      controller.dispose();
      source.emitChange();

      expect(notifications, 0);

      source.dispose();
    });

    test('kann Eigentum an der Radarquelle übernehmen', () {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(
        source: source,
        disposeSource: true,
      );

      controller.dispose();

      expect(source.disposeCalls, 1);
    });

    test('weist Nutzung nach Dispose zurück', () async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      controller.dispose();

      expect(controller.initialize, throwsStateError);

      expect(controller.refresh, throwsStateError);

      source.dispose();
    });
  });
}

class _FakeRadarPlaybackSource extends ChangeNotifier
    implements RadarPlaybackSource<String> {
  int initializeCalls = 0;
  int refreshCalls = 0;
  int disposeCalls = 0;

  @override
  RadarPlaybackSnapshot<String> snapshot = RadarPlaybackSnapshot<String>(
    status: RadarPlaybackStatus.idle,
  );

  @override
  Future<void> initialize() async {
    initializeCalls++;
    await Future<void>.delayed(Duration.zero);
    notifyListeners();
  }

  @override
  Future<void> refresh() async {
    refreshCalls++;
    notifyListeners();
  }

  void emitChange() {
    notifyListeners();
  }

  @override
  void dispose() {
    disposeCalls++;
    super.dispose();
  }
}
