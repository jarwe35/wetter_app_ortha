import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_toolbar.dart';

void main() {
  Widget createSubject({VoidCallback? onLayers, bool compact = false}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: OrthaMapToolbar(
            compact: compact,
            onLayers: onLayers,
            onZoomIn: () {},
            onZoomOut: () {},
            onCenter: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('zeigt die grundlegenden Kartenwerkzeuge', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.byKey(const Key('ortha-map-toolbar')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-toolbar-zoom-in')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-toolbar-zoom-out')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-toolbar-center')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt Ebenensteuerung nur bei vorhandenem Callback', (
    tester,
  ) async {
    await tester.pumpWidget(createSubject());

    expect(find.byKey(const Key('ortha-map-toolbar-layers')), findsNothing);

    await tester.pumpWidget(createSubject(onLayers: () {}));

    expect(find.byKey(const Key('ortha-map-toolbar-layers')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bleibt auf einer kompakten Kartenhöhe ohne Overflow', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 320));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 230,
              child: OrthaMapToolbar(
                compact: true,
                onLayers: () {},
                onZoomIn: () {},
                onZoomOut: () {},
                onCenter: () {},
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(OrthaMapToolbar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('führt die zugeordneten Aktionen aus', (tester) async {
    var zoomInCount = 0;
    var zoomOutCount = 0;
    var centerCount = 0;
    var layersCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrthaMapToolbar(
            onLayers: () => layersCount++,
            onZoomIn: () => zoomInCount++,
            onZoomOut: () => zoomOutCount++,
            onCenter: () => centerCount++,
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const Key('ortha-map-toolbar-layers')));
    await tester.tap(find.byKey(const Key('ortha-map-toolbar-zoom-in')));
    await tester.tap(find.byKey(const Key('ortha-map-toolbar-zoom-out')));
    await tester.tap(find.byKey(const Key('ortha-map-toolbar-center')));

    expect(layersCount, 1);
    expect(zoomInCount, 1);
    expect(zoomOutCount, 1);
    expect(centerCount, 1);
  });
}
