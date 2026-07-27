import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/dashboard/ortha_dashboard_header.dart';

Widget _buildTestApp({
  required OrthaWarningBeaconState warningState,
  VoidCallback? onHome,
  VoidCallback? onRefresh,
  VoidCallback? onOpenWarnings,
  String place = 'Duisburg',
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 420,
          child: OrthaDashboardHeader(
            place: place,
            warningState: warningState,
            onHome: onHome,
            onRefresh: onRefresh,
            onOpenWarnings: onOpenWarnings,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('zeigt den aktiven Standort', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(
        warningState: OrthaWarningBeaconState.green,
        place: 'Duisburg',
      ),
    );

    expect(
      find.byKey(const ValueKey('dashboard-header-place')),
      findsOneWidget,
    );
    expect(find.text('Duisburg'), findsOneWidget);
  });

  testWidgets('zeigt die grüne Warnlage', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(warningState: OrthaWarningBeaconState.green),
    );

    expect(find.text('Keine Warnungen'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
  });

  testWidgets('zeigt die gelbe amtliche Warnlage', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(warningState: OrthaWarningBeaconState.yellow),
    );

    expect(find.text('Amtliche Warnung'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
  });

  testWidgets('zeigt die rote akute Warnlage', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(warningState: OrthaWarningBeaconState.red),
    );

    expect(find.text('Akute Warnlage'), findsOneWidget);
    expect(find.byIcon(Icons.crisis_alert_rounded), findsOneWidget);
  });

  testWidgets('zeigt den Ladezustand', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(warningState: OrthaWarningBeaconState.loading),
    );

    expect(find.text('Warnlage wird geprüft'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('führt Home-, Refresh- und Warnaktionen aus', (tester) async {
    var homePressed = false;
    var refreshPressed = false;
    var warningsPressed = false;

    await tester.pumpWidget(
      _buildTestApp(
        warningState: OrthaWarningBeaconState.green,
        onHome: () {
          homePressed = true;
        },
        onRefresh: () {
          refreshPressed = true;
        },
        onOpenWarnings: () {
          warningsPressed = true;
        },
      ),
    );

    await tester.tap(
      find.byKey(const ValueKey('dashboard-header-logo-button')),
    );
    await tester.pump();

    expect(homePressed, isTrue);

    await tester.tap(find.byKey(const ValueKey('dashboard-header-refresh')));
    await tester.pump();

    expect(refreshPressed, isTrue);

    await tester.tap(find.byKey(const ValueKey('dashboard-warning-beacon')));
    await tester.pump();

    expect(warningsPressed, isTrue);
  });

  testWidgets('öffnet Warnzentrale auch über den Statusbereich', (
    tester,
  ) async {
    var warningsPressed = false;

    await tester.pumpWidget(
      _buildTestApp(
        warningState: OrthaWarningBeaconState.yellow,
        onOpenWarnings: () {
          warningsPressed = true;
        },
      ),
    );

    await tester.tap(find.byKey(const ValueKey('nova-status-area')));
    await tester.pump();

    expect(warningsPressed, isTrue);
  });

  testWidgets('enthält das kompakte ORTHA-Masterlogo', (tester) async {
    await tester.pumpWidget(
      _buildTestApp(warningState: OrthaWarningBeaconState.green),
    );

    expect(
      find.byKey(const ValueKey('dashboard-warning-master-logo')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ortha-dashboard-header')),
      findsOneWidget,
    );
  });
}
