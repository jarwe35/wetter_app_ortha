import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('RadarPlaybackView', () {
    testWidgets('initialisiert Controller beim Einhängen', (tester) async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      await tester.pumpWidget(
        MaterialApp(
          home: RadarPlaybackView<String>(
            controller: controller,
            builder: (context, snapshot, controller) {
              return const Text('Radar');
            },
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      expect(source.initializeCalls, 1);
      expect(find.text('Radar'), findsOneWidget);

      controller.dispose();
      source.dispose();
    });

    testWidgets('reagiert auf Änderungen der Quelle', (tester) async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      await tester.pumpWidget(
        MaterialApp(
          home: RadarPlaybackView<String>(
            controller: controller,
            initializeOnMount: false,
            builder: (context, snapshot, controller) {
              return Text(snapshot.currentOutput ?? 'leer');
            },
          ),
        ),
      );

      expect(find.text('leer'), findsOneWidget);

      source.setOutput('Radarbild');
      await tester.pump();

      expect(find.text('Radarbild'), findsOneWidget);

      controller.dispose();
      source.dispose();
    });

    testWidgets('kann den Controller beim Entfernen freigeben', (tester) async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      await tester.pumpWidget(
        MaterialApp(
          home: RadarPlaybackView<String>(
            controller: controller,
            initializeOnMount: false,
            disposeController: true,
            builder: (context, snapshot, controller) {
              return const Text('Radar');
            },
          ),
        ),
      );

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

      expect(controller.isDisposed, isTrue);

      source.dispose();
    });
  });

  group('RadarPlaybackStatusView', () {
    testWidgets('zeigt Ladeanzeige', (tester) async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      await tester.pumpWidget(
        MaterialApp(
          home: RadarPlaybackStatusView<String>(
            snapshot: RadarPlaybackSnapshot<String>(
              status: RadarPlaybackStatus.loadingTimeline,
            ),
            controller: controller,
            contentBuilder: (context, output, snapshot) {
              return Text(output);
            },
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      controller.dispose();
      source.dispose();
    });

    testWidgets('zeigt vorhandenen Radarinhalt', (tester) async {
      final source = _FakeRadarPlaybackSource();
      final controller = RadarPlaybackViewController<String>(source: source);

      await tester.pumpWidget(
        MaterialApp(
          home: RadarPlaybackStatusView<String>(
            snapshot: RadarPlaybackSnapshot<String>(
              status: RadarPlaybackStatus.ready,
              currentOutput: 'Radarbild',
            ),
            controller: controller,
            contentBuilder: (context, output, snapshot) {
              return Text(output);
            },
          ),
        ),
      );

      expect(find.text('Radarbild'), findsOneWidget);

      controller.dispose();
      source.dispose();
    });
  });
}

class _FakeRadarPlaybackSource extends ChangeNotifier
    implements RadarPlaybackSource<String> {
  int initializeCalls = 0;
  int refreshCalls = 0;

  @override
  RadarPlaybackSnapshot<String> snapshot = RadarPlaybackSnapshot<String>(
    status: RadarPlaybackStatus.idle,
  );

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<void> refresh() async {
    refreshCalls++;
  }

  void setOutput(String output) {
    snapshot = RadarPlaybackSnapshot<String>(
      status: RadarPlaybackStatus.ready,
      currentOutput: output,
    );

    notifyListeners();
  }
}
