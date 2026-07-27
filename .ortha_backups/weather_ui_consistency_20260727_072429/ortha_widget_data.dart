import '../../services/weather_service.dart';

class OrthaWidgetDay {
  const OrthaWidgetDay({
    required this.label,
    required this.symbol,
    required this.temperature,
  });

  final String label;
  final String symbol;
  final String temperature;
}

class OrthaWidgetData {
  const OrthaWidgetData({
    required this.place,
    required this.temperature,
    required this.apparentTemperature,
    required this.weatherSymbol,
    required this.warningLabel,
    required this.warningLevel,
    required this.observationTime,
    required this.days,
  });

  final String place;
  final String temperature;
  final String apparentTemperature;
  final String weatherSymbol;
  final String warningLabel;
  final String warningLevel;
  final String observationTime;
  final List<OrthaWidgetDay> days;

  factory OrthaWidgetData.fromWeather({
    required WeatherData weather,
    required String placeOverride,
    required bool hasOfficialWarning,
  }) {
    final forecast = weather.dailyForecast.take(3).toList();

    return OrthaWidgetData(
      place: placeOverride.trim().isNotEmpty
          ? placeOverride.trim()
          : weather.place.trim().isEmpty
          ? 'Unbekannter Ort'
          : weather.place.trim(),
      temperature: '${weather.temperature.round()} °C',
      apparentTemperature: 'Gefühlt ${weather.apparentTemperature.round()} °C',
      weatherSymbol: symbolForWeatherCode(weather.weatherCode),
      warningLabel: hasOfficialWarning
          ? 'Amtliche Warnung'
          : 'Keine amtliche Warnung',
      warningLevel: hasOfficialWarning ? 'red' : 'green',
      observationTime: formatObservationTime(weather.observationTime),
      days: List<OrthaWidgetDay>.generate(3, (index) {
        if (index >= forecast.length) {
          return const OrthaWidgetDay(
            label: '–',
            symbol: '–',
            temperature: '– / –',
          );
        }

        final day = forecast[index];

        return OrthaWidgetDay(
          label: index == 0 ? 'Heute' : weekdayLabel(day.date),
          symbol: symbolForWeatherCode(day.weatherCode),
          temperature:
              '${day.temperatureMax.round()}° / '
              '${day.temperatureMin.round()}°',
        );
      }),
    );
  }

  static String weekdayLabel(String value) {
    final date = DateTime.tryParse(value);

    if (date == null) {
      return '–';
    }

    switch (date.weekday) {
      case DateTime.monday:
        return 'Mo';
      case DateTime.tuesday:
        return 'Di';
      case DateTime.wednesday:
        return 'Mi';
      case DateTime.thursday:
        return 'Do';
      case DateTime.friday:
        return 'Fr';
      case DateTime.saturday:
        return 'Sa';
      case DateTime.sunday:
        return 'So';
    }

    return '–';
  }

  static String formatObservationTime(String value) {
    final date = DateTime.tryParse(value);

    if (date != null) {
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }

    final parts = value.split('T');

    if (parts.length == 2 && parts[1].length >= 5) {
      return parts[1].substring(0, 5);
    }

    return value;
  }

  static String symbolForWeatherCode(int weatherCode) {
    if (weatherCode == 0) {
      return '☀';
    }

    if (weatherCode == 1 || weatherCode == 2) {
      return '🌤';
    }

    if (weatherCode == 3) {
      return '☁';
    }

    if (weatherCode == 45 || weatherCode == 48) {
      return '🌫';
    }

    if ({51, 53, 55, 56, 57}.contains(weatherCode)) {
      return '🌦';
    }

    if ({61, 63, 65, 66, 67, 80, 81, 82}.contains(weatherCode)) {
      return '🌧';
    }

    if ({71, 73, 75, 77, 85, 86}.contains(weatherCode)) {
      return '❄';
    }

    if ({95, 96, 99}.contains(weatherCode)) {
      return '⛈';
    }

    return '•';
  }
}
