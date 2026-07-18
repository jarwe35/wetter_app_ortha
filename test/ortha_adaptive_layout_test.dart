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
              SizedBox(key: Key('card-1')),
              SizedBox(key: Key('card-2')),
              SizedBox(key: Key('card-3')),
            ],
          ),
        ),
      ),
    );
  }

  testWidgets('verwendet auf Smartphones eine Column', (tester) async {
    await pumpAdaptiveLayout(tester, screenSize: const Size(390, 844));

    expect(find.byType(Column), findsOneWidget);
    expect(find.byType(GridView), findsNothing);
    expect(find.byKey(const Key('card-1')), findsOneWidget);
    expect(find.byKey(const Key('card-2')), findsOneWidget);
    expect(find.byKey(const Key('card-3')), findsOneWidget);
  });

  testWidgets('verwendet auf Tablets ein zweispaltiges Grid', (tester) async {
    await pumpAdaptiveLayout(tester, screenSize: const Size(1024, 1366));

    expect(find.byType(GridView), findsOneWidget);

    final gridView = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 2);
  });

  testWidgets('verwendet auf großen Desktops ein dreispaltiges Grid', (
    tester,
  ) async {
    await pumpAdaptiveLayout(tester, screenSize: const Size(1920, 1080));

    expect(find.byType(GridView), findsOneWidget);

    final gridView = tester.widget<GridView>(find.byType(GridView));
    final delegate =
        gridView.gridDelegate as SliverGridDelegateWithFixedCrossAxisCount;

    expect(delegate.crossAxisCount, 3);
  });
}
