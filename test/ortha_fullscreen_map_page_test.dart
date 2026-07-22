import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/pages/maps/ortha_fullscreen_map_page.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_shell.dart';

void main() {
  testWidgets('Fullscreen Map Page zeigt Karte und schwebende Bedienelemente', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 720));

    addTearDown(() async {
      await tester.binding.setSurfaceSize(null);
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: OrthaFullscreenMapPage(
          safeAreaTop: false,
          safeAreaBottom: false,
          map: ColoredBox(
            key: Key('test-fullscreen-map'),
            color: Colors.blueGrey,
          ),
          topBar: SizedBox(key: Key('test-map-header'), height: 72),
          trailingControls: SizedBox(
            key: Key('test-map-controls'),
            width: 44,
            height: 140,
          ),
          timeline: SizedBox(key: Key('test-map-timeline'), height: 84),
        ),
      ),
    );

    expect(find.byKey(const Key('ortha-fullscreen-map-page')), findsOneWidget);
    expect(find.byType(OrthaMapShell), findsOneWidget);
    expect(find.byKey(const Key('test-fullscreen-map')), findsOneWidget);
    expect(find.byKey(const Key('test-map-header')), findsOneWidget);
    expect(find.byKey(const Key('test-map-controls')), findsOneWidget);
    expect(find.byKey(const Key('test-map-timeline')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Fullscreen Map Page funktioniert auch ausschließlich mit Karte',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OrthaFullscreenMapPage(
            map: ColoredBox(
              key: Key('minimal-fullscreen-map'),
              color: Colors.black,
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('ortha-fullscreen-map-page')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('minimal-fullscreen-map')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
