import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/maps/ortha_map_layout.dart';

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

  testWidgets('zeigt die Kartenfläche an', (tester) async {
    await tester.pumpWidget(createSubject());

    expect(find.byKey(const Key('map-surface')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ordnet Kopf und Fuß außerhalb der Karte an', (tester) async {
    await tester.pumpWidget(
      createSubject(
        header: const Text('Karteninformation'),
        footer: const Text('Zeitleiste'),
      ),
    );

    expect(find.text('Karteninformation'), findsOneWidget);
    expect(find.text('Zeitleiste'), findsOneWidget);

    final headerTop = tester.getTopLeft(find.text('Karteninformation')).dy;
    final mapTop = tester.getTopLeft(find.byKey(const Key('map-surface'))).dy;
    final mapBottom = tester
        .getBottomLeft(find.byKey(const Key('map-surface')))
        .dy;
    final footerTop = tester.getTopLeft(find.text('Zeitleiste')).dy;

    expect(headerTop, lessThan(mapTop));
    expect(footerTop, greaterThanOrEqualTo(mapBottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('erlaubt kleine Bedienelemente innerhalb der Karte', (
    tester,
  ) async {
    await tester.pumpWidget(
      createSubject(
        controls: const Align(
          alignment: Alignment.bottomRight,
          child: Icon(Icons.my_location),
        ),
      ),
    );

    expect(find.byIcon(Icons.my_location), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('funktioniert auch mit fester Kartenproportion', (tester) async {
    await tester.pumpWidget(createSubject(expandMap: false));

    expect(find.byType(AspectRatio), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
