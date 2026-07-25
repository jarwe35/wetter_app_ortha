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

    test('ordnet überwiegend klare Wetterlage korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(1),
        OrthaWeatherCondition.mainlyClear,
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

    test('ordnet Nieselregen korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(53),
        OrthaWeatherCondition.drizzle,
      );

      expect(
        OrthaWeatherCodeMapper.fromWmoCode(57),
        OrthaWeatherCondition.freezingDrizzle,
      );
    });

    test('ordnet Regen und Schauer korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(63),
        OrthaWeatherCondition.rain,
      );

      expect(
        OrthaWeatherCodeMapper.fromWmoCode(67),
        OrthaWeatherCondition.freezingRain,
      );

      expect(
        OrthaWeatherCodeMapper.fromWmoCode(82),
        OrthaWeatherCondition.rainShower,
      );
    });

    test('ordnet Schnee korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(75),
        OrthaWeatherCondition.snow,
      );

      expect(
        OrthaWeatherCodeMapper.fromWmoCode(77),
        OrthaWeatherCondition.snowGrains,
      );

      expect(
        OrthaWeatherCodeMapper.fromWmoCode(86),
        OrthaWeatherCondition.snowShower,
      );
    });

    test('ordnet Gewitter korrekt zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(95),
        OrthaWeatherCondition.thunderstorm,
      );

      expect(
        OrthaWeatherCodeMapper.fromWmoCode(99),
        OrthaWeatherCondition.thunderstormWithHail,
      );
    });

    test('ordnet unbekannte Codes sicher zu', () {
      expect(
        OrthaWeatherCodeMapper.fromWmoCode(999),
        OrthaWeatherCondition.unknown,
      );

      expect(
        OrthaWeatherCodeMapper.fromWmoCode(null),
        OrthaWeatherCondition.unknown,
      );
    });
  });

  group('OrthaWeatherIcon', () {
    testWidgets('übernimmt die vorgegebene Größe', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: OrthaWeatherIcon(weatherCode: 0, size: 80)),
        ),
      );

      final widget = tester.widget<OrthaWeatherIcon>(
        find.byType(OrthaWeatherIcon),
      );

      expect(widget.size, 80);
      expect(widget.weatherCode, 0);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
    });

    testWidgets('zeigt nachts ein Mondsymbol', (tester) async {
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

      expect(find.byIcon(Icons.help_outline_rounded), findsOneWidget);
    });
  });
}
