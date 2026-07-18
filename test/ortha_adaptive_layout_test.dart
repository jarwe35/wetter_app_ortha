import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/ortha_ui/ortha_adaptive_layout.dart';

void main() {
  Future<void> pumpAdaptiveLayout(
    WidgetTester tester, {
    required Size screenSize,
  }) async {
    tester.view.physicalSize = screenSize;
    tester.view.devicePixelRatio = 1.0;

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OrthaAdaptiveLayout(
            children: const [
              SizedBox(key: Key('card-1'), height: 100),
              SizedBox(key: Key('card-2'), height: 160),
              SizedBox(key: Key('card-3'), height: 220),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('verwendet auf Smartphones eine Column', (tester) async {
    await pumpAdaptiveLayout(tester, screenSize: const Size(390, 844));

    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(Wrap), findsNothing);
    expect(find.byType(GridView), findsNothing);

    expect(find.byKey(const Key('card-1')), findsOneWidget);
    expect(find.byKey(const Key('card-2')), findsOneWidget);
    expect(find.byKey(const Key('card-3')), findsOneWidget);
  });

  testWidgets('verwendet auf Tablets ein zweispaltiges Wrap-Layout', (
    tester,
  ) async {
    await pumpAdaptiveLayout(tester, screenSize: const Size(1024, 1366));

    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    final card1TopLeft = tester.getTopLeft(find.byKey(const Key('card-1')));
    final card2TopLeft = tester.getTopLeft(find.byKey(const Key('card-2')));
    final card3TopLeft = tester.getTopLeft(find.byKey(const Key('card-3')));

    expect(card2TopLeft.dy, card1TopLeft.dy);
    expect(card2TopLeft.dx, greaterThan(card1TopLeft.dx));
    expect(card3TopLeft.dy, greaterThan(card1TopLeft.dy));
  });

  testWidgets('verwendet auf großen Desktops ein dreispaltiges Wrap-Layout', (
    tester,
  ) async {
    await pumpAdaptiveLayout(tester, screenSize: const Size(1920, 1080));

    expect(find.byType(Wrap), findsOneWidget);
    expect(find.byType(GridView), findsNothing);

    final card1TopLeft = tester.getTopLeft(find.byKey(const Key('card-1')));
    final card2TopLeft = tester.getTopLeft(find.byKey(const Key('card-2')));
    final card3TopLeft = tester.getTopLeft(find.byKey(const Key('card-3')));

    expect(card2TopLeft.dy, card1TopLeft.dy);
    expect(card3TopLeft.dy, card1TopLeft.dy);
    expect(card2TopLeft.dx, greaterThan(card1TopLeft.dx));
    expect(card3TopLeft.dx, greaterThan(card2TopLeft.dx));
  });
}
