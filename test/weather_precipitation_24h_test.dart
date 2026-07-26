import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/weather_service.dart';

void main() {
  HourlyForecast createHour(double precipitation) {
    return HourlyForecast(
      time: '2026-07-26T08:00',
      temperature: 20,
      apparentTemperature: 18,
      humidity: 58,
      windGusts: 20,
      uvIndex: 2,
      weatherCode: 3,
      isDay: true,
      precipitationProbability: 50,
      precipitation: precipitation,
      visibility: 10000,
    );
  }

  WeatherData createWeatherData(List<HourlyForecast> hours) {
    return WeatherData(
      place: 'Duisburg',
      latitude: 51.4344,
      longitude: 6.7623,
      temperature: 20,
      apparentTemperature: 18,
      humidity: 58,
      precipitation: 0,
      windSpeed: 16.6,
      windGusts: 20,
      pressure: 1015,
      cloudCover: 80,
      weatherCode: 3,
      isDay: true,
      uvIndex: 2,
      visibility: 10000,
      observationTime: '2026-07-26T08:00',
      hourlyForecast: hours,
      dailyForecast: const [],
    );
  }

  group('WeatherData.precipitationNext24Hours', () {
    test('summiert die ersten 24 Stunden', () {
      final hours = <HourlyForecast>[
        ...List.generate(24, (_) => createHour(0.5)),
        createHour(100),
      ];

      final data = createWeatherData(hours);

      expect(data.precipitationNext24Hours, closeTo(12.0, 0.0001));
    });

    test('verwendet bei kürzerer Prognose alle vorhandenen Stunden', () {
      final data = createWeatherData([
        createHour(0.4),
        createHour(1.2),
        createHour(0.3),
      ]);

      expect(data.precipitationNext24Hours, closeTo(1.9, 0.0001));
    });

    test('ignoriert negative Werte', () {
      final data = createWeatherData([
        createHour(1.0),
        createHour(-4.0),
        createHour(0.5),
      ]);

      expect(data.precipitationNext24Hours, closeTo(1.5, 0.0001));
    });

    test('liefert bei leerer Stundenprognose null', () {
      final data = createWeatherData(const []);

      expect(data.precipitationNext24Hours, 0.0);
    });

    test('bestehende Konstruktoren bleiben ohne Mengenangabe kompatibel', () {
      const hour = HourlyForecast(
        time: '2026-07-26T08:00',
        temperature: 20,
        apparentTemperature: 18,
        humidity: 58,
        windGusts: 20,
        uvIndex: 2,
        weatherCode: 3,
        precipitationProbability: 50,
        visibility: 10000,
      );

      expect(hour.precipitation, 0.0);
    });
  });
}
