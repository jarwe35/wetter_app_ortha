import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/engine/risk_engine.dart';
import 'package:wetter_app_ortha/services/weather_service.dart';
import 'package:wetter_app_ortha/widgets/home/ortha_widget_data.dart';

void main() {
  WeatherData weather({
    int weatherCode = 0,
    double temperature = 24.4,
    double apparentTemperature = 25.6,
    String observationTime = '2026-07-16T13:30',
  }) {
    return WeatherData(
      place: 'Duisburg',
      latitude: 51.4344,
      longitude: 6.7623,
      temperature: temperature,
      apparentTemperature: apparentTemperature,
      humidity: 55,
      precipitation: 0,
      windSpeed: 12,
      windGusts: 20,
      pressure: 1015,
      cloudCover: 10,
      weatherCode: weatherCode,
      uvIndex: 4,
      visibility: 20000,
      observationTime: observationTime,
      hourlyForecast: const [],
      dailyForecast: const [],
    );
  }

  RiskResult risk(RiskLevel level) {
    return RiskResult(
      level: level,
      score: 0,
      title: '',
      message: '',
      factors: const [],
      forecastWarnings: const [],
      categories: const [],
    );
  }

  test('bereitet Ort und Temperaturen kompakt auf', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(),
      risk: risk(RiskLevel.green),
    );

    expect(data.place, 'Duisburg');
    expect(data.temperature, '24 °C');
    expect(data.apparentTemperature, 'Gefühlt 26 °C');
    expect(data.observationTime, '13:30');
  });

  test('ordnet grüne Warnlage korrekt zu', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(),
      risk: risk(RiskLevel.green),
    );

    expect(data.warningLabel, 'Warnlage: Grün');
    expect(data.warningLevel, RiskLevel.green);
  });

  test('ordnet rote Warnlage korrekt zu', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(),
      risk: risk(RiskLevel.red),
    );

    expect(data.warningLabel, 'Warnlage: Rot');
    expect(data.warningLevel, RiskLevel.red);
  });

  test('ordnet Gewittercode einem Gewittersymbol zu', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(weatherCode: 95),
      risk: risk(RiskLevel.orange),
    );

    expect(data.weatherSymbol, '⛈');
  });

  test('behält unbekannte Beobachtungszeit unverändert bei', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(observationTime: 'unbekannt'),
      risk: risk(RiskLevel.yellow),
    );

    expect(data.observationTime, 'unbekannt');
  });
}
