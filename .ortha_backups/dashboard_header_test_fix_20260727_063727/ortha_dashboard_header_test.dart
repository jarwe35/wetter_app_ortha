import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/dashboard/ortha_dashboard_header.dart';

void main() {
  Future<void> pumpHeader(
    WidgetTester tester, {
    Size size = const Size(390, 844),
    OrthaWarningBeaconState warningState = OrthaWarningBeaconState.green,
    VoidCallback? onHome,
    VoidCallback? onOpenWarnings,
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
              warningState: warningState,
              onHome: onHome,
              onOpenWarnings: onOpenWarnings,
            ),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('zeigt den reduzierten grünen Statusheader', (tester) async {
    await pumpHeader(tester);

    expect(find.byIcon(Icons.home_outlined), findsOneWidget);

    expect(find.text('Keine Warnungen'), findsOneWidget);

    expect(
      find.text(
        'Für Ihren Standort liegen aktuell keine amtlichen '
        'Warnungen vor.',
      ),
      findsOneWidget,
    );

    expect(find.text('ORTHA METEO Ω'), findsNothing);
    expect(find.text('Meine Orte'), findsNothing);

    expect(find.byIcon(Icons.straighten_outlined), findsNothing);

    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt den Ladezustand', (tester) async {
    await pumpHeader(tester, warningState: OrthaWarningBeaconState.loading);

    expect(find.text('Warnlage wird geprüft'), findsOneWidget);

    expect(
      find.text('Die amtlichen Warnquellen werden aktuell abgefragt.'),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt die gelbe amtliche Warnung', (tester) async {
    await pumpHeader(tester, warningState: OrthaWarningBeaconState.yellow);

    expect(find.text('Amtliche Warnung'), findsOneWidget);

    expect(
      find.textContaining('mindestens eine amtliche Warnung'),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('zeigt die rote akute Warnlage', (tester) async {
    await pumpHeader(tester, warningState: OrthaWarningBeaconState.red);

    expect(find.text('Akute Warnlage'), findsOneWidget);

    expect(
      find.textContaining('erhebliche oder akute Warnlage'),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('führt Home- und Warnzentrale-Aktion aus', (tester) async {
    var homeOpened = false;
    var warningsOpened = false;

    await pumpHeader(
      tester,
      onHome: () {
        homeOpened = true;
      },
      onOpenWarnings: () {
        warningsOpened = true;
      },
    );

    await tester.tap(find.byIcon(Icons.home_outlined));
    await tester.pump();

    expect(homeOpened, isTrue);

    await tester.tap(find.byKey(const ValueKey('nova-status-area')));
    await tester.pump();

    expect(warningsOpened, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('bleibt auf kleinem Display ohne Ausnahme', (tester) async {
    await pumpHeader(tester, size: const Size(320, 700));

    expect(find.text('Keine Warnungen'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });
}
