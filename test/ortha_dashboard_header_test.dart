import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/dashboard/ortha_dashboard_header.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    required Size size,
    required VoidCallback onOpenLocations,
    required VoidCallback onOpenUnitSettings,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;

    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: size.width,
            child: OrthaDashboardHeader(
              onOpenLocations: onOpenLocations,
              onOpenUnitSettings: onOpenUnitSettings,
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
  }

  testWidgets('zeigt alle wesentlichen Header-Inhalte auf kleinem Display', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      size: const Size(360, 800),
      onOpenLocations: () {},
      onOpenUnitSettings: () {},
    );

    expect(find.text('ORTHA METEO Ω'), findsOneWidget);
    expect(find.text('Wetter · Warnungen · Risiko'), findsOneWidget);
    expect(find.text('Meine Orte'), findsOneWidget);
    expect(find.byIcon(Icons.cloud_outlined), findsOneWidget);
    expect(find.byIcon(Icons.straighten_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt alle wesentlichen Header-Inhalte auf breitem Display', (
    tester,
  ) async {
    await pumpHeader(
      tester,
      size: const Size(1000, 800),
      onOpenLocations: () {},
      onOpenUnitSettings: () {},
    );

    expect(find.text('ORTHA METEO Ω'), findsOneWidget);
    expect(find.text('Meine Orte'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('führt beide Header-Aktionen aus', (tester) async {
    var locationsOpened = false;
    var settingsOpened = false;

    await pumpHeader(
      tester,
      size: const Size(390, 844),
      onOpenLocations: () {
        locationsOpened = true;
      },
      onOpenUnitSettings: () {
        settingsOpened = true;
      },
    );

    await tester.tap(find.text('Meine Orte'));
    await tester.pump();

    await tester.tap(find.byTooltip('Einheiten'));
    await tester.pump();

    expect(locationsOpened, isTrue);
    expect(settingsOpened, isTrue);
  });
}
