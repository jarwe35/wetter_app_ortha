import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/saved_location.dart';
import 'package:wetter_app_ortha/widgets/location_search_result_dialog.dart';

void main() {
  Widget buildTestApp({
    required List<SavedLocation> results,
    required ValueChanged<SavedLocation?> onResult,
  }) {
    return MaterialApp(
      home: Builder(
        builder: (context) {
          return Scaffold(
            body: Center(
              child: FilledButton(
                onPressed: () async {
                  final result = await showDialog<SavedLocation>(
                    context: context,
                    builder: (context) {
                      return LocationSearchResultDialog(results: results);
                    },
                  );

                  onResult(result);
                },
                child: const Text('Dialog öffnen'),
              ),
            ),
          );
        },
      ),
    );
  }

  testWidgets('zeigt mehrere Ortsoptionen mit Region und Land', (tester) async {
    const results = [
      SavedLocation(
        name: 'Frankfurt am Main',
        latitude: 50.1109,
        longitude: 8.6821,
        admin1: 'Hessen',
        country: 'Deutschland',
      ),
      SavedLocation(
        name: 'Frankfurt (Oder)',
        latitude: 52.3471,
        longitude: 14.5506,
        admin1: 'Brandenburg',
        country: 'Deutschland',
      ),
    ];

    await tester.pumpWidget(buildTestApp(results: results, onResult: (_) {}));

    await tester.tap(find.text('Dialog öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('Ort auswählen'), findsOneWidget);
    expect(
      find.text('Frankfurt am Main · Hessen · Deutschland'),
      findsOneWidget,
    );
    expect(
      find.text('Frankfurt (Oder) · Brandenburg · Deutschland'),
      findsOneWidget,
    );
    expect(find.text('50.1109, 8.6821'), findsOneWidget);
    expect(find.text('52.3471, 14.5506'), findsOneWidget);
  });

  testWidgets('gibt den ausgewählten Ort zurück', (tester) async {
    const results = [
      SavedLocation(
        name: 'Frankfurt am Main',
        latitude: 50.1109,
        longitude: 8.6821,
        admin1: 'Hessen',
        country: 'Deutschland',
      ),
      SavedLocation(
        name: 'Frankfurt (Oder)',
        latitude: 52.3471,
        longitude: 14.5506,
        admin1: 'Brandenburg',
        country: 'Deutschland',
      ),
    ];

    SavedLocation? selected;

    await tester.pumpWidget(
      buildTestApp(
        results: results,
        onResult: (result) {
          selected = result;
        },
      ),
    );

    await tester.tap(find.text('Dialog öffnen'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Frankfurt (Oder) · Brandenburg · Deutschland'));
    await tester.pumpAndSettle();

    expect(selected, results[1]);
    expect(find.text('Ort auswählen'), findsNothing);
  });

  testWidgets('Abbrechen schließt den Dialog ohne Auswahl', (tester) async {
    const results = [
      SavedLocation(
        name: 'New York',
        latitude: 40.7128,
        longitude: -74.0060,
        admin1: 'New York',
        country: 'Vereinigte Staaten',
      ),
      SavedLocation(
        name: 'York',
        latitude: 40.8681,
        longitude: -97.5920,
        admin1: 'Nebraska',
        country: 'Vereinigte Staaten',
      ),
    ];

    SavedLocation? selected;

    await tester.pumpWidget(
      buildTestApp(
        results: results,
        onResult: (result) {
          selected = result;
        },
      ),
    );

    await tester.tap(find.text('Dialog öffnen'));
    await tester.pumpAndSettle();

    expect(find.text('New York · Vereinigte Staaten'), findsOneWidget);

    await tester.tap(find.text('Abbrechen'));
    await tester.pumpAndSettle();

    expect(selected, isNull);
    expect(find.text('Ort auswählen'), findsNothing);
  });
}
