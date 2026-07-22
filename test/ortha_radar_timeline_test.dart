import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_radar_timeline.dart';

void main() {
  Widget createSubject({
    int value = 2,
    int frameCount = 5,
    bool isAnimating = false,
    VoidCallback? onToggleAnimation,
    ValueChanged<int>? onChanged,
    VoidCallback? onChangeStart,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OrthaRadarTimeline(
            value: value,
            frameCount: frameCount,
            currentTimeText: '12:30 Uhr',
            relativeTimeText: 'vor 10 Minuten',
            firstTimeText: '10:30 Uhr',
            lastTimeText: '12:30 Uhr',
            isAnimating: isAnimating,
            onToggleAnimation: onToggleAnimation ?? () {},
            onChanged: onChanged ?? (_) {},
            onChangeStart: onChangeStart,
          ),
        ),
      ),
    );
  }

  testWidgets('zeigt Radarzeit und Zeitbereich', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.byKey(const Key('ortha-radar-timeline')), findsOneWidget);
    expect(find.text('12:30 Uhr'), findsNWidgets(2));
    expect(find.text('vor 10 Minuten'), findsOneWidget);
    expect(find.text('10:30 Uhr'), findsOneWidget);
    expect(find.text('2 Std.'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt während der Animation die Pausenschaltfläche', (
    tester,
  ) async {
    await tester.pumpWidget(createSubject(isAnimating: true));

    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });

  testWidgets('führt die Animationsaktion aus', (tester) async {
    var toggleCount = 0;

    await tester.pumpWidget(
      createSubject(onToggleAnimation: () => toggleCount++),
    );

    await tester.tap(find.byKey(const Key('ortha-radar-timeline-play')));

    expect(toggleCount, 1);
  });

  testWidgets('meldet eine neue Frame-Auswahl', (tester) async {
    int? selectedFrame;

    await tester.pumpWidget(
      createSubject(
        value: 0,
        frameCount: 5,
        onChanged: (value) {
          selectedFrame = value;
        },
      ),
    );

    final slider = tester.widget<Slider>(
      find.byKey(const Key('ortha-radar-timeline-slider')),
    );

    slider.onChanged?.call(3);

    expect(selectedFrame, 3);
  });

  testWidgets('stoppt vor manueller Slider-Bedienung die Animation', (
    tester,
  ) async {
    var startCount = 0;

    await tester.pumpWidget(createSubject(onChangeStart: () => startCount++));

    final slider = tester.widget<Slider>(
      find.byKey(const Key('ortha-radar-timeline-slider')),
    );

    slider.onChangeStart?.call(2);

    expect(startCount, 1);
  });

  testWidgets('funktioniert auch mit nur einem Frame', (tester) async {
    await tester.pumpWidget(createSubject(value: 0, frameCount: 1));

    expect(find.byType(Slider), findsNothing);

    final button = tester.widget<IconButton>(
      find.byKey(const Key('ortha-radar-timeline-play')),
    );

    expect(button.onPressed, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bleibt auf schmalen Displays ohne Overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 220));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: OrthaRadarTimeline(
              value: 2,
              frameCount: 5,
              currentTimeText: '12:30 Uhr',
              relativeTimeText: 'Aktuellster Messstand',
              firstTimeText: '10:30 Uhr',
              lastTimeText: '12:30 Uhr',
              isAnimating: false,
              onToggleAnimation: () {},
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OrthaRadarTimeline), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
