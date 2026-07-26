import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/weather/ortha_weather_icon.dart';

void main() {
  testWidgets('mainlyClear verwendet nicht das reine Sonnensymbol', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrthaWeatherIcon(
            condition: OrthaWeatherCondition.mainlyClear,
            size: 92,
            semanticLabel: 'Klar',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is OrthaWeatherIcon &&
            widget.condition == OrthaWeatherCondition.mainlyClear &&
            widget.size == 92,
      ),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('Nacht bleibt von der Tagesregel unberührt', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OrthaWeatherIcon(
            condition: OrthaWeatherCondition.clear,
            isNight: true,
            size: 92,
            semanticLabel: 'Klare Nacht',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is OrthaWeatherIcon &&
            widget.condition == OrthaWeatherCondition.clear &&
            widget.isNight,
      ),
      findsOneWidget,
    );

    expect(tester.takeException(), isNull);
  });
}
