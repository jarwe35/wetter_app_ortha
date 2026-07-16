import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/widgets/weather/ortha_weather_icon.dart';

void main() {
  group('OrthaWeatherCodeMapper', () {
    test('ordnet klare Wetterlage korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(0),
        OrthaWeatherCondition.clear,
      );
    });

    test('ordnet Bewölkung korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(2),
        OrthaWeatherCondition.partlyCloudy,
      );
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(3),
        OrthaWeatherCondition.cloudy,
      );
    });

    test('ordnet Nebel korrekt zu', () {
      expect(OrthaWeatherCodeMapper.fromWmoCode(45), OrthaWeatherCondition.fog);
      expect(OrthaWeatherCodeMapper.fromWmoCode(48), OrthaWeatherCondition.fog);
    });

    test('ordnet Regen und Schauer korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(63),
        OrthaWeatherCondition.rain,
      );
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(82),
        OrthaWeatherCondition.shower,
      );
    });

    test('ordnet Schnee korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(75),
        OrthaWeatherCondition.snow,
      );
    });

    test('ordnet Gewitter korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(95),
        OrthaWeatherCondition.thunderstorm,
      );
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(99),
        OrthaWeatherCondition.thunderstorm,
      );
    });

    test('ordnet unbekannte Codes sicher zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(999),
        OrthaWeatherCondition.unknown,
      );
    });
  });

  group('OrthaWeatherIcon', () {
    testWidgets('wird mit vorgegebener Größe dargestellt', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OrthaWeatherIcon(weatherCode: 0, size: 80)),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox && widget.width == 80 && widget.height == 80,
        ),
      );

      expect(sizedBox.width, 80);
      expect(sizedBox.height, 80);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    });

    testWidgets('zeigt nachts zusätzlich ein Mondsymbol', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OrthaWeatherIcon(weatherCode: 0, isNight: true)),
        ),
      );

      expect(find.byIcon(Icons.nightlight_round), findsOneWidget);
    });

    testWidgets('stellt einen unbekannten Wettercode sicher dar', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OrthaWeatherIcon(weatherCode: 999)),
        ),
      );

      expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
    });
  });
}
