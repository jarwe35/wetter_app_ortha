import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/engine/risk_engine.dart';
import 'package:wetter_app_ortha/services/weather_service.dart';

void main() {
  const engine = RiskEngine();

  WeatherData createWeatherData({
    double apparentTemperature = 20,
    double uvIndex = 1,
    double windGusts = 10,
    double precipitation = 0,
    double visibility = 20000,
    int weatherCode = 0,
    List<HourlyForecast> hourlyForecast = const [],
  }) {
    return WeatherData(
      place: 'Testort',
      latitude: 0,
      longitude: 0,
      temperature: 20,
      apparentTemperature: apparentTemperature,
      humidity: 50,
      precipitation: precipitation,
      windSpeed: 10,
      windGusts: windGusts,
      pressure: 1013,
      cloudCover: 0,
      weatherCode: weatherCode,
      uvIndex: uvIndex,
      visibility: visibility,
      observationTime: '2026-07-10T08:00',
      hourlyForecast: hourlyForecast,
      dailyForecast: const [],
    );
  }

  HourlyForecast createHour({
    String time = '2026-07-10T09:00',
    double apparentTemperature = 20,
    double windGusts = 10,
    double uvIndex = 1,
    int weatherCode = 0,
    int precipitationProbability = 0,
    double visibility = 20000,
  }) {
    return HourlyForecast(
      time: time,
      temperature: 20,
      apparentTemperature: apparentTemperature,
      humidity: 50,
      windGusts: windGusts,
      uvIndex: uvIndex,
      weatherCode: weatherCode,
      precipitationProbability: precipitationProbability,
      visibility: visibility,
    );
  }

  RiskCategoryResult categoryByName(RiskResult result, String name) {
    return result.categories.firstWhere((category) => category.name == name);
  }

  test('erkennt aktuellen Regen über Wettercode', () {
    final result = engine.evaluate(
      createWeatherData(weatherCode: 63, precipitation: 0),
    );

    final rain = categoryByName(result, 'Niederschlag');

    expect(rain.currentScore, greaterThan(0));
    expect(rain.message, contains('Regen'));
  });

  test('erkennt prognostizierte starke Windböen', () {
    final result = engine.evaluate(
      createWeatherData(
        hourlyForecast: [createHour(time: '2026-07-10T15:00', windGusts: 70)],
      ),
    );

    final wind = categoryByName(result, 'Wind/Sturm');

    expect(wind.forecastScore, greaterThanOrEqualTo(60));
    expect(wind.peakTime, '15:00');
    expect(wind.forecastDisplayValue, contains('70 km/h'));
  });

  test('erkennt prognostiziertes Gewitter', () {
    final result = engine.evaluate(
      createWeatherData(
        hourlyForecast: [
          createHour(
            time: '2026-07-10T18:00',
            weatherCode: 95,
            precipitationProbability: 80,
          ),
        ],
      ),
    );

    final thunderstorm = categoryByName(result, 'Gewitter');

    expect(thunderstorm.forecastScore, greaterThanOrEqualTo(70));
    expect(thunderstorm.peakTime, '18:00');
    expect(thunderstorm.forecastDisplayValue, contains('Gewitter'));
  });

  test('erkennt prognostizierte Hitzebelastung', () {
    final result = engine.evaluate(
      createWeatherData(
        hourlyForecast: [
          createHour(time: '2026-07-10T15:00', apparentTemperature: 34),
        ],
      ),
    );

    final heat = categoryByName(result, 'Hitze');

    expect(heat.forecastScore, greaterThanOrEqualTo(60));
    expect(heat.peakTime, '15:00');
    expect(heat.forecastDisplayValue, contains('34.0 °C'));
  });

  test('erkennt prognostizierte hohe UV-Strahlung', () {
    final result = engine.evaluate(
      createWeatherData(
        hourlyForecast: [createHour(time: '2026-07-10T13:00', uvIndex: 8)],
      ),
    );

    final uv = categoryByName(result, 'UV');

    expect(uv.forecastScore, greaterThanOrEqualTo(60));
    expect(uv.peakTime, '13:00');
    expect(uv.forecastDisplayValue, contains('UV 8.0'));
  });

  test('erkennt prognostizierte schlechte Sicht', () {
    final result = engine.evaluate(
      createWeatherData(
        hourlyForecast: [
          createHour(
            time: '2026-07-10T06:00',
            visibility: 800,
            weatherCode: 45,
          ),
        ],
      ),
    );

    final visibility = categoryByName(result, 'Sicht');

    expect(visibility.forecastScore, greaterThanOrEqualTo(60));
    expect(visibility.peakTime, '06:00');
    expect(visibility.forecastDisplayValue, contains('800 m'));
  });

  test('Gesamtwarnstufe Grün bei unkritischer Wetterlage', () {
    final result = engine.evaluate(createWeatherData());

    expect(result.level, RiskLevel.green);
  });

  test('Gesamtwarnstufe Gelb bei einzelner erhöhter Belastung', () {
    final result = engine.evaluate(createWeatherData(apparentTemperature: 27));

    expect(result.level, RiskLevel.yellow);
  });

  test('Gesamtwarnstufe Orange bei deutlicher Wetterbelastung', () {
    final result = engine.evaluate(createWeatherData(windGusts: 70));

    expect(result.level, RiskLevel.orange);
  });

  test('Gesamtwarnstufe Rot bei kritischer Wetterbelastung', () {
    final result = engine.evaluate(createWeatherData(apparentTemperature: 39));

    expect(result.level, RiskLevel.red);
  });

  test('kombinierte Wetterlage Hitze und hohe UV-Strahlung', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 34, uvIndex: 8),
    );

    final heat = categoryByName(result, 'Hitze');
    final uv = categoryByName(result, 'UV');

    expect(heat.currentScore, greaterThanOrEqualTo(60));
    expect(uv.currentScore, greaterThanOrEqualTo(60));
    expect(result.level.index, greaterThanOrEqualTo(RiskLevel.orange.index));
    expect(result.factors, isNotEmpty);
  });

  test('kritische Kombination Sturm Starkregen und Gewitter', () {
    final result = engine.evaluate(
      createWeatherData(
        windGusts: 90,
        precipitation: 16,
        weatherCode: 95,
        hourlyForecast: [
          createHour(
            time: '2026-07-10T18:00',
            windGusts: 95,
            weatherCode: 99,
            precipitationProbability: 95,
          ),
        ],
      ),
    );

    final wind = categoryByName(result, 'Wind/Sturm');
    final rain = categoryByName(result, 'Niederschlag');
    final thunderstorm = categoryByName(result, 'Gewitter');

    expect(wind.score, greaterThanOrEqualTo(85));
    expect(rain.score, greaterThanOrEqualTo(75));
    expect(thunderstorm.score, greaterThanOrEqualTo(85));
    expect(result.level, RiskLevel.red);
    expect(result.factors.length, greaterThanOrEqualTo(3));
  });

  test('mehrere moderate Risiken erzeugen keine rote Warnstufe', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 27, uvIndex: 6, windGusts: 40),
    );

    final heat = categoryByName(result, 'Hitze');
    final uv = categoryByName(result, 'UV');
    final wind = categoryByName(result, 'Wind/Sturm');

    expect(heat.score, greaterThanOrEqualTo(25));
    expect(uv.score, greaterThanOrEqualTo(35));
    expect(wind.score, greaterThanOrEqualTo(35));

    expect(result.level, isNot(RiskLevel.red));
    expect(result.score, lessThan(70));
  });

  test('Windgrenzwert 24.9 kmh bleibt unter Warnschwelle', () {
    final result = engine.evaluate(createWeatherData(windGusts: 24.9));

    final wind = categoryByName(result, 'Wind/Sturm');

    expect(wind.currentScore, 0);
    expect(wind.level, RiskLevel.green);
  });

  test('Windgrenzwert 25.0 kmh aktiviert erhöhte Windbelastung', () {
    final result = engine.evaluate(createWeatherData(windGusts: 25.0));

    final wind = categoryByName(result, 'Wind/Sturm');

    expect(wind.currentScore, 15);
    expect(wind.level, RiskLevel.yellow);
  });

  test('Sichtgrenzwert 5001 m bleibt außerhalb der Warnschwelle', () {
    final result = engine.evaluate(createWeatherData(visibility: 5001));

    final visibility = categoryByName(result, 'Sicht');

    expect(visibility.currentScore, 15);
    expect(visibility.level, RiskLevel.yellow);
  });

  test('Sichtgrenzwert 4999 m aktiviert eingeschränkte Sicht', () {
    final result = engine.evaluate(createWeatherData(visibility: 4999));

    final visibility = categoryByName(result, 'Sicht');

    expect(visibility.currentScore, 35);
    expect(visibility.level, RiskLevel.yellow);
  });

  test('Hitzegrenzwert 25.9 Grad bleibt unter Warnschwelle', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 25.9),
    );

    final heat = categoryByName(result, 'Hitze');

    expect(heat.currentScore, 0);
    expect(heat.level, RiskLevel.green);
  });

  test('Hitzegrenzwert 26.0 Grad aktiviert erhöhte Belastung', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 26.0),
    );

    final heat = categoryByName(result, 'Hitze');

    expect(heat.currentScore, 25);
    expect(heat.level, RiskLevel.yellow);
  });

  test('UV-Grenzwert 2.9 bleibt unter Warnschwelle', () {
    final result = engine.evaluate(createWeatherData(uvIndex: 2.9));

    final uv = categoryByName(result, 'UV');

    expect(uv.currentScore, 0);
    expect(uv.level, RiskLevel.green);
  });

  test('UV-Grenzwert 3.0 aktiviert erhöhte UV-Belastung', () {
    final result = engine.evaluate(createWeatherData(uvIndex: 3.0));

    final uv = categoryByName(result, 'UV');

    expect(uv.currentScore, 15);
    expect(uv.level, RiskLevel.yellow);
  });

  test('Niederschlagsgrenzwert 0.0 mm bleibt ohne Warnung', () {
    final result = engine.evaluate(
      createWeatherData(precipitation: 0.0, weatherCode: 0),
    );

    final rain = categoryByName(result, 'Niederschlag');

    expect(rain.currentScore, 0);
    expect(rain.level, RiskLevel.green);
  });

  test('Niederschlagsgrenzwert 0.1 mm aktiviert leichte Niederschlagslage', () {
    final result = engine.evaluate(
      createWeatherData(precipitation: 0.1, weatherCode: 0),
    );

    final rain = categoryByName(result, 'Niederschlag');

    expect(rain.currentScore, 25);
    expect(rain.level, RiskLevel.yellow);
    expect(rain.displayValue, contains('0.1 mm'));
  });

  test(
    'Niederschlagswahrscheinlichkeit 39 Prozent bleibt unter Prognoseschwelle',
    () {
      final result = engine.evaluate(
        createWeatherData(
          hourlyForecast: [
            createHour(
              time: '2026-07-10T14:00',
              precipitationProbability: 39,
              weatherCode: 0,
            ),
          ],
        ),
      );

      final rain = categoryByName(result, 'Niederschlag');

      expect(rain.forecastScore, 0);
      expect(
        rain.forecastDisplayValue,
        'keine relevante Niederschlagslage erkannt',
      );
    },
  );

  test(
    'Niederschlagswahrscheinlichkeit 40 Prozent aktiviert Prognosestufe',
    () {
      final result = engine.evaluate(
        createWeatherData(
          hourlyForecast: [
            createHour(
              time: '2026-07-10T14:00',
              precipitationProbability: 40,
              weatherCode: 0,
            ),
          ],
        ),
      );

      final rain = categoryByName(result, 'Niederschlag');

      expect(rain.forecastScore, 20);
      expect(rain.peakTime, '14:00');
      expect(rain.forecastDisplayValue, contains('40 %'));
    },
  );

  test('Hitzegrenzwert 31.9 Grad bleibt unter hoher Belastung', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 31.9),
    );

    final heat = categoryByName(result, 'Hitze');

    expect(heat.currentScore, 25);
    expect(heat.level, RiskLevel.yellow);
  });

  test('Hitzegrenzwert 32.0 Grad aktiviert hohe Belastung', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 32.0),
    );

    final heat = categoryByName(result, 'Hitze');

    expect(heat.currentScore, 60);
    expect(heat.level, RiskLevel.orange);
  });

  test('UV-Grenzwert 7.9 bleibt unter sehr hoher UV-Strahlung', () {
    final result = engine.evaluate(createWeatherData(uvIndex: 7.9));

    final uv = categoryByName(result, 'UV');

    expect(uv.currentScore, 35);
    expect(uv.level, RiskLevel.yellow);
  });

  test('UV-Grenzwert 8.0 aktiviert sehr hohe UV-Strahlung', () {
    final result = engine.evaluate(createWeatherData(uvIndex: 8.0));

    final uv = categoryByName(result, 'UV');

    expect(uv.currentScore, 60);
    expect(uv.level, RiskLevel.orange);
  });

  test('Windgrenzwert 64.9 kmh bleibt unter starker Sturmgefahr', () {
    final result = engine.evaluate(createWeatherData(windGusts: 64.9));

    final wind = categoryByName(result, 'Wind/Sturm');

    expect(wind.currentScore, 35);
    expect(wind.level, RiskLevel.yellow);
  });

  test('Windgrenzwert 65.0 kmh aktiviert starke Sturmgefahr', () {
    final result = engine.evaluate(createWeatherData(windGusts: 65.0));

    final wind = categoryByName(result, 'Wind/Sturm');

    expect(wind.currentScore, 60);
    expect(wind.level, RiskLevel.orange);
  });

  test('Niederschlagsgrenzwert 4.9 mm bleibt unter starkem Niederschlag', () {
    final result = engine.evaluate(
      createWeatherData(precipitation: 4.9, weatherCode: 0),
    );

    final rain = categoryByName(result, 'Niederschlag');

    expect(rain.currentScore, 25);
    expect(rain.level, RiskLevel.yellow);
  });

  test('Niederschlagsgrenzwert 5.0 mm aktiviert starken Niederschlag', () {
    final result = engine.evaluate(
      createWeatherData(precipitation: 5.0, weatherCode: 0),
    );

    final rain = categoryByName(result, 'Niederschlag');

    expect(rain.currentScore, 45);
    expect(rain.level, RiskLevel.orange);
  });

  test(
    'Niederschlagsgrenzwert 14.9 mm bleibt unter sehr starkem Niederschlag',
    () {
      final result = engine.evaluate(
        createWeatherData(precipitation: 14.9, weatherCode: 0),
      );

      final rain = categoryByName(result, 'Niederschlag');

      expect(rain.currentScore, 45);
      expect(rain.level, RiskLevel.orange);
    },
  );

  test(
    'Niederschlagsgrenzwert 15.0 mm aktiviert sehr starken Niederschlag',
    () {
      final result = engine.evaluate(
        createWeatherData(precipitation: 15.0, weatherCode: 0),
      );

      final rain = categoryByName(result, 'Niederschlag');

      expect(rain.currentScore, 75);
      expect(rain.level, RiskLevel.red);
    },
  );

  test('Windgrenzwert 89.9 kmh bleibt unter schwerer Sturmgefahr', () {
    final result = engine.evaluate(createWeatherData(windGusts: 89.9));

    final wind = categoryByName(result, 'Wind/Sturm');

    expect(wind.currentScore, 60);
    expect(wind.level, RiskLevel.orange);
  });

  test('Windgrenzwert 90.0 kmh aktiviert schwere Sturmgefahr', () {
    final result = engine.evaluate(createWeatherData(windGusts: 90.0));

    final wind = categoryByName(result, 'Wind/Sturm');

    expect(wind.currentScore, 85);
    expect(wind.level, RiskLevel.red);
  });

  test('Hitzegrenzwert 37.9 Grad bleibt unter extremer Belastung', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 37.9),
    );

    final heat = categoryByName(result, 'Hitze');

    expect(heat.currentScore, 60);
    expect(heat.level, RiskLevel.orange);
  });

  test('Hitzegrenzwert 38.0 Grad aktiviert extreme Belastung', () {
    final result = engine.evaluate(
      createWeatherData(apparentTemperature: 38.0),
    );

    final heat = categoryByName(result, 'Hitze');

    expect(heat.currentScore, 85);
    expect(heat.level, RiskLevel.red);
  });

  test('UV-Grenzwert 10.9 bleibt unter extremer UV-Strahlung', () {
    final result = engine.evaluate(createWeatherData(uvIndex: 10.9));

    final uv = categoryByName(result, 'UV');

    expect(uv.currentScore, 60);
    expect(uv.level, RiskLevel.orange);
  });

  test('UV-Grenzwert 11.0 aktiviert extreme UV-Strahlung', () {
    final result = engine.evaluate(createWeatherData(uvIndex: 11.0));

    final uv = categoryByName(result, 'UV');

    expect(uv.currentScore, 85);
    expect(uv.level, RiskLevel.red);
  });
}
