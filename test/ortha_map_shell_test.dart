import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_shell.dart';

void main() {
  Widget createSubject({
    Widget? topBar,
    Widget? search,
    Widget? leadingControls,
    Widget? trailingControls,
    Widget? timeline,
    Widget? bottomNavigation,
    Widget? overlay,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OrthaMapShell(
          map: const ColoredBox(key: Key('test-map'), color: Colors.black),
          topBar: topBar,
          search: search,
          leadingControls: leadingControls,
          trailingControls: trailingControls,
          timeline: timeline,
          bottomNavigation: bottomNavigation,
          overlay: overlay,
        ),
      ),
    );
  }

  testWidgets('zeigt die Karte vollflächig als Hintergrund', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.byKey(const Key('test-map')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-shell-map')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt kompakte Kartenebenen über der Karte', (tester) async {
    await tester.pumpWidget(
      createSubject(
        topBar: const Text('ORTHA METEO'),
        search: const Text('Ort suchen'),
        leadingControls: const Icon(Icons.layers_outlined),
        trailingControls: const Icon(Icons.my_location),
        timeline: const Text('Zeitleiste'),
        overlay: const Text('NOVA'),
      ),
    );

    expect(find.text('ORTHA METEO'), findsOneWidget);
    expect(find.text('Ort suchen'), findsOneWidget);
    expect(find.byIcon(Icons.layers_outlined), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(find.text('Zeitleiste'), findsOneWidget);
    expect(find.text('NOVA'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ordnet die Zeitachse oberhalb der unteren Navigation an', (
    tester,
  ) async {
    await tester.pumpWidget(
      createSubject(
        timeline: const SizedBox(
          key: Key('timeline'),
          height: 52,
          child: Text('Zeitleiste'),
        ),
        bottomNavigation: const SizedBox(
          key: Key('bottom-navigation'),
          height: 64,
          child: Text('Navigation'),
        ),
      ),
    );

    final timelineBottom = tester
        .getBottomLeft(find.byKey(const Key('timeline')))
        .dy;
    final navigationTop = tester
        .getTopLeft(find.byKey(const Key('bottom-navigation')))
        .dy;

    expect(timelineBottom, lessThanOrEqualTo(navigationTop));
    expect(tester.takeException(), isNull);
  });

  testWidgets('funktioniert ohne optionale Bedienelemente', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.byType(OrthaMapShell), findsOneWidget);
    expect(find.byType(Stack), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
