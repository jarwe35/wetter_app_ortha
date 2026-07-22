import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_shell.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_toolbar.dart';

void main() {
  testWidgets(
    'Kartenwerkzeugleiste bleibt in einem kompakten Kartenbereich sichtbar',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 420));

      addTearDown(() async {
        await tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrthaMapShell(
              safeAreaTop: false,
              safeAreaBottom: false,
              map: const ColoredBox(color: Colors.black),
              topBar: const SizedBox(
                height: 96,
                child: ColoredBox(color: Colors.black54),
              ),
              timeline: const SizedBox(
                height: 84,
                child: ColoredBox(color: Colors.black54),
              ),
              trailingControls: OrthaMapToolbar(
                compact: true,
                onZoomIn: () {},
                onZoomOut: () {},
                onCenter: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(OrthaMapShell), findsOneWidget);
      expect(find.byType(OrthaMapToolbar), findsOneWidget);
      expect(find.byKey(const Key('ortha-map-toolbar-layers')), findsNothing);
      expect(
        find.byKey(const Key('ortha-map-toolbar-zoom-in')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('ortha-map-toolbar-zoom-out')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('ortha-map-toolbar-center')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
