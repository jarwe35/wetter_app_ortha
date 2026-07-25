import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/saved_location.dart';

class HourlyForecast {
  final String time;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double windGusts;
  final double uvIndex;
  final int weatherCode;
  final bool isDay;
  final int precipitationProbability;
  final double visibility;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.windGusts,
    required this.uvIndex,
    required this.weatherCode,
    this.isDay = true,
    required this.precipitationProbability,
    required this.visibility,
  });
}

class DailyForecast {
  final String date;
  final double temperatureMin;
  final double temperatureMax;
  final int weatherCode;
  final int precipitationProbability;
  final double uvIndex;

  const DailyForecast({
    required this.date,
    required this.temperatureMin,
    required this.temperatureMax,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.uvIndex,
  });
}

class WeatherData {
  final String place;
  final double latitude;
  final double longitude;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final double precipitation;
  final double windSpeed;
  final double windGusts;
  final double pressure;
  final int cloudCover;
  final int weatherCode;
  final double uvIndex;
  final double visibility;
  final String observationTime;
  final List<HourlyForecast> hourlyForecast;
  final List<DailyForecast> dailyForecast;

  const WeatherData({
    required this.place,
    required this.latitude,
    required this.longitude,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.windSpeed,
    required this.windGusts,
    required this.pressure,
    required this.cloudCover,
    required this.weatherCode,
    required this.uvIndex,
    required this.visibility,
    required this.observationTime,
    required this.hourlyForecast,
    required this.dailyForecast,
  });
}

class WeatherService {
  final http.Client? httpClient;

  const WeatherService({this.httpClient});

  Future<http.Response> _get(Uri uri) {
    final client = httpClient;

    if (client != null) {
      return client.get(uri);
    }

    return http.get(uri);
  }

  Future<WeatherData> fetchWeather(String place) async {
    final geoUrl = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': place,
      'count': '1',
      'language': 'de',
      'format': 'json',
    });

    final geoResponse = await _get(geoUrl).timeout(const Duration(seconds: 15));

    if (geoResponse.statusCode != 200) {
      throw Exception(
        'Ortssuche fehlgeschlagen: HTTP ${geoResponse.statusCode}',
      );
    }

    final geoJson = jsonDecode(geoResponse.body);
    final results = geoJson['results'];

    if (results == null || results is! List || results.isEmpty) {
      throw Exception('Ort nicht gefunden.');
    }

    final result = results.first;
    final latitude = (result['latitude'] as num).toDouble();
    final longitude = (result['longitude'] as num).toDouble();
    final resolvedName = result['name'] as String;

    return fetchWeatherForLocation(
      SavedLocation(
        name: resolvedName,
        latitude: latitude,
        longitude: longitude,
        country: result['country'] is String
            ? result['country'] as String
            : null,
        timezone: result['timezone'] is String
            ? result['timezone'] as String
            : null,
      ),
    );
  }

  Future<WeatherData> fetchWeatherForLocation(SavedLocation location) async {
    final latitude = location.latitude;
    final longitude = location.longitude;
    final resolvedName = location.name;

    final weatherUrl = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,'
          'precipitation,weather_code,cloud_cover,surface_pressure,'
          'wind_speed_10m,wind_gusts_10m',
      'hourly':
          'temperature_2m,apparent_temperature,relative_humidity_2m,'
          'wind_gusts_10m,uv_index,weather_code,is_day,'
          'precipitation_probability,visibility',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,uv_index_max',
      'forecast_days': '14',
      'timezone': 'auto',
    });

    final weatherResponse = await _get(
      weatherUrl,
    ).timeout(const Duration(seconds: 15));

    if (weatherResponse.statusCode != 200) {
      throw Exception(
        'Wetterdaten konnten nicht geladen werden: '
        'HTTP ${weatherResponse.statusCode} · ${weatherResponse.body}',
      );
    }

    final weatherJson = jsonDecode(weatherResponse.body);

    final current = weatherJson['current'] as Map<String, dynamic>?;
    final hourly = weatherJson['hourly'] as Map<String, dynamic>?;
    final daily = weatherJson['daily'] as Map<String, dynamic>?;

    if (current == null || hourly == null || daily == null) {
      throw Exception('Unvollständige Wetterdaten empfangen.');
    }

    final currentTime = current['time'] as String;

    final hourlyTimes = hourly['time'] as List;
    final hourlyTemperatures = hourly['temperature_2m'] as List;
    final hourlyApparentTemperatures =
        hourly['apparent_temperature'] as List? ?? hourlyTemperatures;
    final hourlyHumidities = hourly['relative_humidity_2m'] as List? ?? [];
    final hourlyWindGusts = hourly['wind_gusts_10m'] as List? ?? [];
    final hourlyUvIndices = hourly['uv_index'] as List? ?? [];
    final hourlyWeatherCodes = hourly['weather_code'] as List;

    final hourlyIsDay = hourly['is_day'] is List
        ? hourly['is_day'] as List
        : List<dynamic>.filled(hourlyTimes.length, 1);
    final hourlyPrecipitationProbabilities =
        hourly['precipitation_probability'] as List;
    final hourlyVisibilities = hourly['visibility'] as List;

    var currentHourIndex = hourlyTimes.indexWhere(
      (time) => (time as String).compareTo(currentTime) >= 0,
    );

    if (currentHourIndex < 0) {
      currentHourIndex = 0;
    }

    final availableHourlyCount =
        [
          hourlyTimes.length,
          hourlyTemperatures.length,
          hourlyApparentTemperatures.length,
          hourlyWeatherCodes.length,
          hourlyPrecipitationProbabilities.length,
          hourlyVisibilities.length,
        ].reduce((a, b) => a < b ? a : b) -
        currentHourIndex;

    final hourlyCount = availableHourlyCount < 24 ? availableHourlyCount : 24;

    final hourlyForecast = List<HourlyForecast>.generate(hourlyCount, (index) {
      final sourceIndex = currentHourIndex + index;

      return HourlyForecast(
        time: hourlyTimes[sourceIndex] as String,
        temperature: (hourlyTemperatures[sourceIndex] as num).toDouble(),
        apparentTemperature: (hourlyApparentTemperatures[sourceIndex] as num)
            .toDouble(),
        humidity: (hourlyHumidities[sourceIndex] as num).round(),
        windGusts: (hourlyWindGusts[sourceIndex] as num).toDouble(),
        uvIndex: (hourlyUvIndices[sourceIndex] as num).toDouble(),
        weatherCode: (hourlyWeatherCodes[sourceIndex] as num).round(),
        isDay: (hourlyIsDay[sourceIndex] as num).round() == 1,
        precipitationProbability:
            (hourlyPrecipitationProbabilities[sourceIndex] as num).round(),
        visibility: (hourlyVisibilities[sourceIndex] as num).toDouble(),
      );
    });

    final dailyTimes = daily['time'] as List;
    final dailyTemperatureMax = daily['temperature_2m_max'] as List;
    final dailyTemperatureMin = daily['temperature_2m_min'] as List;
    final dailyWeatherCodes = daily['weather_code'] as List;
    final dailyPrecipitationProbabilities =
        daily['precipitation_probability_max'] as List;
    final dailyUvIndices = daily['uv_index_max'] as List;

    final dailyForecast = List<DailyForecast>.generate(dailyTimes.length, (
      index,
    ) {
      return DailyForecast(
        date: dailyTimes[index] as String,
        temperatureMin: (dailyTemperatureMin[index] as num).toDouble(),
        temperatureMax: (dailyTemperatureMax[index] as num).toDouble(),
        weatherCode: (dailyWeatherCodes[index] as num).round(),
        precipitationProbability:
            (dailyPrecipitationProbabilities[index] as num).round(),
        uvIndex: (dailyUvIndices[index] as num).toDouble(),
      );
    });

    final currentVisibility = (hourlyVisibilities[currentHourIndex] as num)
        .toDouble();

    return WeatherData(
      place: resolvedName,
      latitude: latitude,
      longitude: longitude,
      temperature: (current['temperature_2m'] as num).toDouble(),
      apparentTemperature: (current['apparent_temperature'] as num).toDouble(),
      humidity: (current['relative_humidity_2m'] as num).round(),
      precipitation: (current['precipitation'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      windGusts: (current['wind_gusts_10m'] as num).toDouble(),
      pressure: (current['surface_pressure'] as num).toDouble(),
      cloudCover: (current['cloud_cover'] as num).round(),
      weatherCode: (current['weather_code'] as num).round(),
      uvIndex: (dailyUvIndices.first as num).toDouble(),
      visibility: currentVisibility,
      observationTime: currentTime,
      hourlyForecast: hourlyForecast,
      dailyForecast: dailyForecast,
    );
  }
}
