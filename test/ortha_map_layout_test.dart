import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_layout.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_shell.dart';

void main() {
  Widget createSubject({
    Widget? header,
    Widget? footer,
    Widget? controls,
    bool expandMap = true,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: OrthaMapLayout(
          header: header,
          footer: footer,
          mapControls: controls,
          expandMap: expandMap,
          map: const ColoredBox(key: Key('map-surface'), color: Colors.black),
        ),
      ),
    );
  }

  testWidgets('verwendet die zentrale ORTHA Map Shell', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.byType(OrthaMapLayout), findsOneWidget);
    expect(find.byType(OrthaMapShell), findsOneWidget);
    expect(find.byKey(const Key('map-surface')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-shell-map')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('übersetzt den Kopf in die obere Kartenebene', (tester) async {
    await tester.pumpWidget(
      createSubject(header: const Text('Karteninformation')),
    );

    expect(find.byKey(const Key('ortha-map-layout-header')), findsOneWidget);
    expect(find.text('Karteninformation'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('übersetzt den Fuß in die Kartenzeitleiste', (tester) async {
    await tester.pumpWidget(createSubject(footer: const Text('Zeitleiste')));

    expect(find.byKey(const Key('ortha-map-layout-footer')), findsOneWidget);
    expect(find.text('Zeitleiste'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('übersetzt Kartenbedienelemente in die Steuerungsebene', (
    tester,
  ) async {
    await tester.pumpWidget(
      createSubject(controls: const Icon(Icons.my_location)),
    );

    expect(find.byKey(const Key('ortha-map-layout-controls')), findsOneWidget);
    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('funktioniert weiterhin ohne optionale Ebenen', (tester) async {
    await tester.pumpWidget(createSubject(expandMap: false));

    expect(find.byType(OrthaMapShell), findsOneWidget);
    expect(find.byKey(const Key('map-surface')), findsOneWidget);
    expect(find.byKey(const Key('ortha-map-layout-header')), findsNothing);
    expect(find.byKey(const Key('ortha-map-layout-footer')), findsNothing);
    expect(find.byKey(const Key('ortha-map-layout-controls')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
