import '../../engine/risk_engine.dart';
import '../../services/weather_service.dart';

class OrthaWidgetData {
  final String place;
  final String temperature;
  final String apparentTemperature;
  final String weatherSymbol;
  final String warningLabel;
  final RiskLevel warningLevel;
  final String observationTime;

  const OrthaWidgetData({
    required this.place,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherSymbol,
    required this.warningLabel,
    required this.warningLevel,
    required this.observationTime,
  });

  factory OrthaWidgetData.fromWeather({
    required WeatherData weather,
    required RiskResult risk,
  }) {
    return OrthaWidgetData(
      place: weather.place,
      temperature: '${weather.temperature.round()} °C',
      apparentTemperature: 'Gefühlt ${weather.apparentTemperature.round()} °C',
      weatherSymbol: _symbolForWeatherCode(weather.weatherCode),
      warningLabel: _warningLabelForLevel(risk.level),
      warningLevel: risk.level,
      observationTime: _formatObservationTime(weather.observationTime),
    );
  }

  static String _warningLabelForLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.green:
        return 'Warnlage: Grün';
      case RiskLevel.yellow:
        return 'Warnlage: Gelb';
      case RiskLevel.orange:
        return 'Warnlage: Orange';
      case RiskLevel.red:
        return 'Warnlage: Rot';
    }
  }

  static String _symbolForWeatherCode(int weatherCode) {
    if (weatherCode == 0) {
      return '☀';
    }

    if ([1, 2].contains(weatherCode)) {
      return '🌤';
    }

    if (weatherCode == 3) {
      return '☁';
    }

    if ([45, 48].contains(weatherCode)) {
      return '🌫';
    }

    if ([51, 53, 55, 56, 57].contains(weatherCode)) {
      return '🌦';
    }

    if ([61, 63, 65, 66, 67, 80, 81, 82].contains(weatherCode)) {
      return '🌧';
    }

    if ([71, 73, 75, 77, 85, 86].contains(weatherCode)) {
      return '❄';
    }

    if ([95, 96, 99].contains(weatherCode)) {
      return '⛈';
    }

    return '•';
  }

  static String _formatObservationTime(String value) {
    final parts = value.split('T');

    if (parts.length != 2 || parts[1].length < 5) {
      return value;
    }

    return parts[1].substring(0, 5);
  }
}
