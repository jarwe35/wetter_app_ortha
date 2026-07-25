import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/weather_service.dart';

void main() {
  group('HourlyForecast Tag-/Nachtstatus', () {
    test('verwendet standardmäßig Tag für bestehende Aufrufer', () {
      const forecast = HourlyForecast(
        time: '2026-07-25T14:00',
        temperature: 23,
        apparentTemperature: 24,
        humidity: 55,
        windGusts: 8,
        uvIndex: 4,
        weatherCode: 0,
        precipitationProbability: 0,
        visibility: 10000,
      );

      expect(forecast.isDay, isTrue);
    });

    test('kann eine Nachtstunde eindeutig abbilden', () {
      const forecast = HourlyForecast(
        time: '2026-07-25T02:00',
        temperature: 18,
        apparentTemperature: 18,
        humidity: 72,
        windGusts: 5,
        uvIndex: 0,
        weatherCode: 0,
        precipitationProbability: 0,
        visibility: 10000,
        isDay: false,
      );

      expect(forecast.isDay, isFalse);
    });
  });
}
