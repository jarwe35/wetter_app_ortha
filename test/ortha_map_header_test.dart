import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_header.dart';

void main() {
  Widget createSubject({
    VoidCallback? onBack,
    VoidCallback? onLayers,
    VoidCallback? onRefresh,
    bool isRefreshing = false,
    bool coordinatesAvailable = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 390,
            child: OrthaMapHeader(
              place: 'Düsseldorf',
              mode: 'Niederschlagsradar',
              statusText: 'RainViewer · verfügbar',
              novaStatus: 'Normal',
              onBack: onBack,
              onLayers: onLayers,
              onRefresh: onRefresh,
              isRefreshing: isRefreshing,
              coordinatesAvailable: coordinatesAvailable,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('zeigt die zentralen Karteninformationen', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.byKey(const Key('ortha-map-header')), findsOneWidget);
    expect(find.text('Düsseldorf'), findsOneWidget);
    expect(find.text('Niederschlagsradar'), findsOneWidget);
    expect(find.text('RainViewer · verfügbar'), findsOneWidget);
    expect(find.text('NOVA Normal'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt optionale Aktionen nur bei vorhandenem Callback', (
    tester,
  ) async {
    await tester.pumpWidget(createSubject());

    expect(find.byKey(const Key('ortha-map-header-back')), findsNothing);
    expect(find.byKey(const Key('ortha-map-header-layers')), findsNothing);
    expect(find.byKey(const Key('ortha-map-header-refresh')), findsNothing);

    await tester.pumpWidget(
      createSubject(onBack: () {}, onLayers: () {}, onRefresh: () {}),
    );

    expect(find.byKey(const Key('ortha-map-header-back')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-header-layers')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-header-refresh')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('führt die Header-Aktionen aus', (tester) async {
    var backCount = 0;
    var layerCount = 0;
    var refreshCount = 0;

    await tester.pumpWidget(
      createSubject(
        onBack: () => backCount++,
        onLayers: () => layerCount++,
        onRefresh: () => refreshCount++,
      ),
    );

    await tester.tap(find.byKey(const Key('ortha-map-header-back')));
    await tester.tap(find.byKey(const Key('ortha-map-header-layers')));
    await tester.tap(find.byKey(const Key('ortha-map-header-refresh')));

    expect(backCount, 1);
    expect(layerCount, 1);
    expect(refreshCount, 1);
  });

  testWidgets('zeigt während der Aktualisierung einen Fortschrittsindikator', (
    tester,
  ) async {
    await tester.pumpWidget(
      createSubject(onRefresh: () {}, isRefreshing: true),
    );

    expect(
      find.byKey(const Key('ortha-map-header-refreshing')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('ortha-map-header-refresh')), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('weist auf fehlende Standortkoordinaten hin', (tester) async {
    await tester.pumpWidget(createSubject(coordinatesAvailable: false));

    expect(
      find.text('RainViewer · verfügbar · Keine Standortkoordinaten'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('bleibt auf kleinen Displays ohne Overflow', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 240));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(8),
            child: OrthaMapHeader(
              place: 'Ein sehr langer Ortsname für einen kleinen Bildschirm',
              mode: 'Satellit und Niederschlagsradar',
              statusText: 'Esri und RainViewer · Kartendaten verfügbar',
              onLayers: () {},
              onRefresh: () {},
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OrthaMapHeader), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
