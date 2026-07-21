import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/saved_location.dart';
import 'package:wetter_app_ortha/widgets/dashboard/place_selector.dart';

void main() {
  const duesseldorf = SavedLocation(
    name: 'Düsseldorf',
    latitude: 51.2277,
    longitude: 6.7735,
  );

  const duisburg = SavedLocation(
    name: 'Duisburg',
    latitude: 51.4344,
    longitude: 6.7623,
  );

  Widget buildSubject({
    List<SavedLocation> locations = const [duesseldorf, duisburg],
    SavedLocation? selectedLocation = duesseldorf,
    ValueChanged<SavedLocation>? onSelect,
    ValueChanged<SavedLocation>? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: PlaceSelector(
          locations: locations,
          selectedLocation: selectedLocation,
          onSelect: onSelect ?? (_) {},
          onDelete: onDelete ?? (_) {},
        ),
      ),
    );
  }

  testWidgets('zeigt alle gespeicherten Orte an', (tester) async {
    await tester.pumpWidget(buildSubject());

    expect(find.text('Düsseldorf'), findsOneWidget);
    expect(find.text('Duisburg'), findsOneWidget);
    expect(find.byType(InputChip), findsNWidgets(2));
  });

  testWidgets('markiert den ausgewählten Ort', (tester) async {
    await tester.pumpWidget(buildSubject());

    final firstChip = tester.widget<InputChip>(find.byType(InputChip).first);
    final secondChip = tester.widget<InputChip>(find.byType(InputChip).at(1));

    expect(firstChip.selected, isTrue);
    expect(secondChip.selected, isFalse);
  });

  testWidgets('übergibt Auswahl und Löschvorgang', (tester) async {
    SavedLocation? selected;
    SavedLocation? deleted;

    await tester.pumpWidget(
      buildSubject(
        onSelect: (location) {
          selected = location;
        },
        onDelete: (location) {
          deleted = location;
        },
      ),
    );

    final duisburgChip = tester.widget<InputChip>(find.byType(InputChip).at(1));

    duisburgChip.onPressed?.call();
    expect(selected, duisburg);

    duisburgChip.onDeleted?.call();
    expect(deleted, duisburg);
  });

  testWidgets('deaktiviert Löschen beim letzten Ort', (tester) async {
    await tester.pumpWidget(
      buildSubject(
        locations: const [duesseldorf],
        selectedLocation: duesseldorf,
      ),
    );

    final chip = tester.widget<InputChip>(find.byType(InputChip));

    expect(chip.onDeleted, isNull);
  });
}
