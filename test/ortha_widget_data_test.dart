import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/weather_service.dart';
import 'package:wetter_app_ortha/widgets/home/ortha_widget_data.dart';

void main() {
  WeatherData weather({
    String place = 'Duisburg',
    int weatherCode = 0,
    double temperature = 24.4,
    double apparentTemperature = 25.6,
    String observationTime = '2026-07-16T13:30',
    List<DailyForecast> dailyForecast = const [],
  }) {
    return WeatherData(
      place: place,
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
      dailyForecast: dailyForecast,
    );
  }

  test('bereitet Ort und Temperaturen kompakt auf', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(),
      placeOverride: 'Duisburg',
      hasOfficialWarning: false,
    );

    expect(data.place, 'Duisburg');
    expect(data.temperature, '24 °C');
    expect(data.apparentTemperature, 'Gefühlt 26 °C');
    expect(data.observationTime, '13:30');
  });

  test('ordnet fehlende amtliche Warnung grün zu', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(),
      placeOverride: 'Duisburg',
      hasOfficialWarning: false,
    );

    expect(data.warningLabel, 'Keine amtliche Warnung');
    expect(data.warningLevel, 'green');
  });

  test('ordnet amtliche Warnung rot zu', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(),
      placeOverride: 'Duisburg',
      hasOfficialWarning: true,
    );

    expect(data.warningLabel, 'Amtliche Warnung');
    expect(data.warningLevel, 'red');
  });

  test('ordnet Gewittercode einem Gewittersymbol zu', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(weatherCode: 95),
      placeOverride: 'Duisburg',
      hasOfficialWarning: false,
    );

    expect(data.weatherSymbol, '⛈');
  });

  test('behält unbekannte Beobachtungszeit unverändert bei', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(observationTime: 'unbekannt'),
      placeOverride: 'Duisburg',
      hasOfficialWarning: false,
    );

    expect(data.observationTime, 'unbekannt');
  });

  test('verwendet das Datum der Tagesvorhersage für Wochentage', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(
        dailyForecast: const [
          DailyForecast(
            date: '2026-07-24',
            temperatureMin: 14,
            temperatureMax: 23,
            weatherCode: 0,
            precipitationProbability: 5,
            uvIndex: 4,
          ),
          DailyForecast(
            date: '2026-07-25',
            temperatureMin: 15,
            temperatureMax: 24,
            weatherCode: 1,
            precipitationProbability: 10,
            uvIndex: 4,
          ),
          DailyForecast(
            date: '2026-07-26',
            temperatureMin: 16,
            temperatureMax: 25,
            weatherCode: 3,
            precipitationProbability: 20,
            uvIndex: 3,
          ),
        ],
      ),
      placeOverride: 'Duisburg',
      hasOfficialWarning: false,
    );

    expect(data.days, hasLength(3));

    expect(data.days[0].label, 'Heute');
    expect(data.days[0].symbol, '☀');
    expect(data.days[0].temperature, '23° / 14°');

    expect(data.days[1].label, 'Sa');
    expect(data.days[1].symbol, '🌤');
    expect(data.days[1].temperature, '24° / 15°');

    expect(data.days[2].label, 'So');
    expect(data.days[2].symbol, '☁');
    expect(data.days[2].temperature, '25° / 16°');
  });

  test('ergänzt fehlende Prognosetage mit Platzhaltern', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(
        dailyForecast: const [
          DailyForecast(
            date: '2026-07-24',
            temperatureMin: 14,
            temperatureMax: 23,
            weatherCode: 0,
            precipitationProbability: 5,
            uvIndex: 4,
          ),
        ],
      ),
      placeOverride: 'Duisburg',
      hasOfficialWarning: false,
    );

    expect(data.days, hasLength(3));
    expect(data.days[0].label, 'Heute');
    expect(data.days[1].label, '–');
    expect(data.days[1].symbol, '–');
    expect(data.days[1].temperature, '– / –');
    expect(data.days[2].label, '–');
  });

  test('verwendet den ausgewählten Ort statt des WeatherData-Ortes', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(place: 'Koblenz'),
      placeOverride: 'Duisburg',
      hasOfficialWarning: false,
    );

    expect(data.place, 'Duisburg');
  });

  test('ersetzt einen leeren Ortsnamen', () {
    final data = OrthaWidgetData.fromWeather(
      weather: weather(place: '   '),
      placeOverride: '',
      hasOfficialWarning: false,
    );

    expect(data.place, 'Unbekannter Ort');
  });

  test('formatiert bekannte Wettercodes für das Widget', () {
    expect(OrthaWidgetData.symbolForWeatherCode(0), '☀');
    expect(OrthaWidgetData.symbolForWeatherCode(2), '🌤');
    expect(OrthaWidgetData.symbolForWeatherCode(3), '☁');
    expect(OrthaWidgetData.symbolForWeatherCode(45), '🌫');
    expect(OrthaWidgetData.symbolForWeatherCode(53), '🌦');
    expect(OrthaWidgetData.symbolForWeatherCode(63), '🌧');
    expect(OrthaWidgetData.symbolForWeatherCode(75), '❄');
    expect(OrthaWidgetData.symbolForWeatherCode(95), '⛈');
    expect(OrthaWidgetData.symbolForWeatherCode(999), '•');
  });
}
