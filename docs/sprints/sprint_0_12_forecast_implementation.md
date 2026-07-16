# ORTHA METEO Ω – Vorhersage-Implementierung vor Umbau

## Ausgangspunkt

- Branch: `develop-v0.12.0`
- Commit: `5c3997f`
- Bestehender Prognosezeitraum: 7 Tage
- Geplanter Prognosezeitraum: umschaltbar zwischen 7 und 14 Tagen

## Festgestellte Architektur

- Wetterdaten und Prognosemodelle liegen in `lib/services/weather_service.dart`.
- Die Tagesvorhersage wird durch `DailyForecastCard` in `lib/main.dart` dargestellt.
- Die Stundenprognose wird durch `HourlyForecastCard` dargestellt.
- Der Open-Meteo-Aufruf verwendet derzeit `forecast_days: 7`.
- Eine eigenständige 14-Tage-Darstellung existiert noch nicht.

## Umsetzungsprinzip Sprint 0.12

1. Datenabruf kontrolliert auf 14 Tage erweitern.
2. Bestehende 7-Tage-Ansicht vollständig erhalten.
3. Umschaltung zwischen 7 und 14 Tagen einführen.
4. Smartphone-Karten für schmale Displays optimieren.
5. Wetterzustände in eine eigenständige Symbolkomponente auslagern.
6. Semi-3D-Darstellung ausschließlich durch Flutter-UI-Mittel umsetzen.
7. Bestehende Warn-, Risiko- und Standortlogik nicht verändern.

## Weather-Service

```dart
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
          'wind_gusts_10m,uv_index,weather_code,'
          'precipitation_probability,visibility',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,'
          'precipitation_probability_max,uv_index_max',
      'forecast_days': '7',
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
```

## Einbindung der Vorhersagen

```dart
                                                      _findSavedLocation(place);

                                                  if (location != null) {
                                                    deleteSavedLocation(
                                                      location,
                                                    );
                                                  }
                                                },
                                                icon: const Icon(
                                                  Icons.delete_outline,
                                                  color: orthaSecondaryText,
                                                ),
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: FilledButton.icon(
                              onPressed: addPlace,
                              icon: const Icon(Icons.add_location_alt_outlined),
                              label: const Text('Neuen Ort hinzufügen'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed: () => openLocationsPage(),
                              icon: const Icon(Icons.tune_outlined),
                              label: const Text('Sortieren und umbenennen'),
                            ),
                          ),
                          const SizedBox(height: 30),
                        ],
                      )
                    : ListView(
                        children: [
                          if (isLoading)
                            const CardBox(
                              child: Text('Wetterdaten werden geladen …'),
                            )
                          else if (errorMessage != null)
                            CardBox(child: Text(errorMessage!))
                          else if (data != null && risk != null) ...[
                            WeatherCard(data: data, unitSettings: unitSettings),
                            const SizedBox(height: 18),
                            WarningLevelBar(result: risk),
                            const SizedBox(height: 18),
                            HourlyForecastCard(
                              forecast: data.hourlyForecast,
                              unitSettings: unitSettings,
                            ),
                            const SizedBox(height: 18),
                            OfficialWeatherWarningsCard(
                              warnings: officialWarnings,
                              isSupported: officialWarningsSupported,
                              isLoading: officialWarningsLoading,
                              errorMessage: officialWarningsError,
                              latitude:
                                  selectedLocation?.latitude ?? data.latitude,
                              longitude:
                                  selectedLocation?.longitude ?? data.longitude,
                              place: selectedPlace,
                            ),
                            const SizedBox(height: 18),
                            RiskCard(result: risk),
                            const SizedBox(height: 18),
                            RiskCategoriesCard(categories: risk.categories),
                            const SizedBox(height: 18),
                            DailyForecastCard(
                              forecast: data.dailyForecast,
                              unitSettings: unitSettings,
                            ),
                            const SizedBox(height: 18),
                            WeatherDetailsCard(
                              data: data,
                              unitSettings: unitSettings,
                            ),
                            const SizedBox(height: 18),
                            SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: FilledButton.icon(
                                onPressed: addPlace,
                                icon: const Icon(
                                  Icons.add_location_alt_outlined,
                                ),
                                label: const Text('Ort hinzufügen'),
                              ),
                            ),
                          ],
                          const SizedBox(height: 30),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

## Stunden- und Tagesvorhersage

```dart
  if ([1, 2, 3].contains(code)) return Icons.cloud_outlined;
  if ([45, 48].contains(code)) return Icons.foggy;
  if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
    return Icons.water_drop_outlined;
  }
  if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit;
  if ([95, 96, 99].contains(code)) return Icons.thunderstorm_outlined;
  return Icons.device_thermostat;
}

String shortTime(String value) {
  final parts = value.split('T');
  if (parts.length != 2) return value;
  return parts[1].substring(0, 5);
}

String shortDate(String value) {
  final parts = value.split('-');
  if (parts.length != 3) return value;
  return '${parts[2]}.${parts[1]}.';
}

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> forecast;
  final UnitSettings unitSettings;

  const HourlyForecastCard({
    super.key,
    required this.forecast,
    required this.unitSettings,
  });

  @override
  Widget build(BuildContext context) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '24-Stunden-Prognose',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 146,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: forecast.length,
              separatorBuilder: (_, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = forecast[index];

                return Container(
                  width: 92,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: orthaSurfaceElevated,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: orthaBorder.withValues(alpha: 0.85),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        shortTime(item.time),
                        style: const TextStyle(
                          color: orthaSecondaryText,
                          fontSize: 12,
                        ),
                      ),
                      Icon(weatherIcon(item.weatherCode), color: orthaAccent),
                      Text(
                        formatTemperature(
                          item.temperature,
                          unitSettings,
                          decimals: 0,
                        ),
                        style: const TextStyle(
                          color: orthaPrimaryText,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${item.precipitationProbability} % Regen',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: orthaSecondaryText,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> forecast;
  final UnitSettings unitSettings;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    required this.unitSettings,
  });

  @override
  Widget build(BuildContext context) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: orthaAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '7-Tage-Vorhersage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Temperaturspanne und Niederschlagswahrscheinlichkeit',
            style: TextStyle(color: orthaSecondaryText, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...forecast.map(
            (day) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: orthaSurfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: orthaBorder.withValues(alpha: 0.85)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final compact = constraints.maxWidth < 520;

                  final weatherInfo = Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: orthaAccent.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: orthaAccent.withValues(alpha: 0.30),
                          ),
                        ),
                        child: Icon(
                          weatherIcon(day.weatherCode),
                          color: orthaAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shortDate(day.date),
                              style: const TextStyle(
                                color: orthaPrimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              weatherText(day.weatherCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: orthaSecondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final values = Row(
                    mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: compact ? 1 : 0,
                        child: _ForecastValue(
                          icon: Icons.arrow_downward,
                          label: 'Min',
                          value: formatTemperature(
                            day.temperatureMin,
                            unitSettings,
                            decimals: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: compact ? 1 : 0,
                        child: _ForecastValue(
                          icon: Icons.arrow_upward,
                          label: 'Max',
                          value: formatTemperature(
                            day.temperatureMax,
                            unitSettings,
                            decimals: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        flex: compact ? 1 : 0,
                        child: _ForecastValue(
                          icon: Icons.water_drop_outlined,
                          label: 'Regen',
                          value: '${day.precipitationProbability} %',
                        ),
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      children: [
                        weatherInfo,
                        const SizedBox(height: 14),
                        values,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: weatherInfo),
                      const SizedBox(width: 18),
                      SizedBox(width: 300, child: values),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ForecastValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: orthaSecondaryText),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(color: orthaSecondaryText, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: orthaPrimaryText,
```

## Fundstellen zu Wettersymbolen

```text
lib/main.dart:667:                icon: Icon(Icons.home_outlined),
lib/main.dart:668:                selectedIcon: Icon(Icons.home, color: orthaAccent),
lib/main.dart:672:                icon: Icon(Icons.warning_amber_outlined),
lib/main.dart:673:                selectedIcon: Icon(Icons.warning_amber, color: orthaAccent),
lib/main.dart:677:                icon: Icon(Icons.shield_outlined),
lib/main.dart:678:                selectedIcon: Icon(Icons.shield, color: orthaAccent),
lib/main.dart:682:                icon: Icon(Icons.radar_outlined),
lib/main.dart:683:                selectedIcon: Icon(Icons.radar, color: orthaAccent),
lib/main.dart:687:                icon: Icon(Icons.location_on_outlined),
lib/main.dart:688:                selectedIcon: Icon(Icons.location_on, color: orthaAccent),
lib/main.dart:732:                        Icons.cloud_outlined,
lib/main.dart:765:                      icon: const Icon(Icons.straighten_outlined),
lib/main.dart:788:                      icon: const Icon(Icons.location_city_outlined),
lib/main.dart:831:                                    Icons.warning_amber_rounded,
lib/main.dart:863:                                  icon: const Icon(Icons.refresh),
lib/main.dart:924:                                    Icons.shield_outlined,
lib/main.dart:956:                                  icon: const Icon(Icons.refresh),
lib/main.dart:1008:                                    Icons.radar_outlined,
lib/main.dart:1040:                                  icon: const Icon(Icons.refresh),
lib/main.dart:1053:                                      Icons.layers_outlined,
lib/main.dart:1089:                                      Icons.info_outline,
lib/main.dart:1146:                                    Icons.location_on_outlined,
lib/main.dart:1179:                                    Icons.add_location_alt_outlined,
lib/main.dart:1193:                                      Icons.bookmarks_outlined,
lib/main.dart:1243:                                              ? Icons.location_on
lib/main.dart:1244:                                              : Icons.location_on_outlined,
lib/main.dart:1289:                                                  Icons.delete_outline,
lib/main.dart:1307:                              icon: const Icon(Icons.add_location_alt_outlined),
lib/main.dart:1317:                              icon: const Icon(Icons.tune_outlined),
lib/main.dart:1374:                                  Icons.add_location_alt_outlined,
lib/main.dart:1509:  IconData sourceIcon(OfficialWeatherWarning warning) {
lib/main.dart:1511:        ? Icons.cloud_outlined
lib/main.dart:1512:        : Icons.shield_outlined;
lib/main.dart:1533:              Icon(Icons.campaign_outlined, color: orthaAccent),
lib/main.dart:1580:              icon: Icons.public_off_outlined,
lib/main.dart:1587:              icon: Icons.error_outline,
lib/main.dart:1593:              icon: Icons.verified_outlined,
lib/main.dart:1649:                            Icons.warning_amber_rounded,
lib/main.dart:1723:                            Icons.location_on_outlined,
lib/main.dart:1741:                          Icons.schedule_outlined,
lib/main.dart:1783:                                  Icons.summarize_outlined,
lib/main.dart:1826:                            Icons.article_outlined,
lib/main.dart:1891:  final IconData icon;
lib/main.dart:1943:                Icons.location_on_outlined,
lib/main.dart:1979:                  weatherIcon(data.weatherCode),
lib/main.dart:2004:                      weatherText(data.weatherCode),
lib/main.dart:2029:                  icon: Icons.device_thermostat_outlined,
lib/main.dart:2034:                  icon: Icons.water_drop_outlined,
lib/main.dart:2038:                  icon: Icons.air,
lib/main.dart:2052:  final IconData icon;
lib/main.dart:2114:              Icon(Icons.psychology_alt_outlined, color: orthaAccent),
lib/main.dart:2148:                  child: Icon(Icons.shield_outlined, color: color),
lib/main.dart:2226:                    Icon(Icons.circle, size: 8, color: color),
lib/main.dart:2308:IconData weatherIcon(int code) {
lib/main.dart:2309:  if (code == 0) return Icons.wb_sunny_outlined;
lib/main.dart:2310:  if ([1, 2, 3].contains(code)) return Icons.cloud_outlined;
lib/main.dart:2311:  if ([45, 48].contains(code)) return Icons.foggy;
lib/main.dart:2313:    return Icons.water_drop_outlined;
lib/main.dart:2315:  if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit;
lib/main.dart:2316:  if ([95, 96, 99].contains(code)) return Icons.thunderstorm_outlined;
lib/main.dart:2317:  return Icons.device_thermostat;
lib/main.dart:2382:                      Icon(weatherIcon(item.weatherCode), color: orthaAccent),
lib/main.dart:2432:              Icon(Icons.calendar_month_outlined, color: orthaAccent),
lib/main.dart:2458:                builder: (context, constraints) {
lib/main.dart:2459:                  final compact = constraints.maxWidth < 520;
lib/main.dart:2474:                          weatherIcon(day.weatherCode),
lib/main.dart:2493:                              weatherText(day.weatherCode),
lib/main.dart:2513:                          icon: Icons.arrow_downward,
lib/main.dart:2526:                          icon: Icons.arrow_upward,
lib/main.dart:2539:                          icon: Icons.water_drop_outlined,
lib/main.dart:2575:  final IconData icon;
lib/main.dart:2652:              Icon(Icons.monitor_heart_outlined, color: orthaAccent),
lib/main.dart:2662:            icon: Icons.water_drop_outlined,
lib/main.dart:2667:            icon: Icons.air,
lib/main.dart:2672:            icon: Icons.storm_outlined,
lib/main.dart:2677:            icon: Icons.speed_outlined,
lib/main.dart:2682:            icon: Icons.cloud_outlined,
lib/main.dart:2684:            value: '${data.cloudCover} %',
lib/main.dart:2687:            icon: Icons.visibility_outlined,
lib/main.dart:2692:            icon: Icons.wb_sunny_outlined,
lib/main.dart:2704:  final IconData icon;
lib/main.dart:2823:              Icon(Icons.shield_outlined, color: orthaAccent),
lib/main.dart:2904:                Icons.analytics_outlined,
lib/main.dart:2939:  IconData iconForCategory(String name) {
lib/main.dart:2942:        return Icons.thermostat_outlined;
lib/main.dart:2944:        return Icons.wb_sunny_outlined;
lib/main.dart:2946:        return Icons.air;
lib/main.dart:2948:        return Icons.water_drop_outlined;
lib/main.dart:2950:        return Icons.visibility_outlined;
lib/main.dart:2952:        return Icons.thunderstorm_outlined;
lib/main.dart:2954:        return Icons.analytics_outlined;
lib/main.dart:2966:              Icon(Icons.dashboard_customize_outlined, color: orthaAccent),
lib/main.dart:3085:                        Icons.chevron_right,
lib/services/weather_service.dart:14:  final int weatherCode;
lib/services/weather_service.dart:25:    required this.weatherCode,
lib/services/weather_service.dart:35:  final int weatherCode;
lib/services/weather_service.dart:43:    required this.weatherCode,
lib/services/weather_service.dart:60:  final int cloudCover;
lib/services/weather_service.dart:61:  final int weatherCode;
lib/services/weather_service.dart:79:    required this.cloudCover,
lib/services/weather_service.dart:80:    required this.weatherCode,
lib/services/weather_service.dart:157:          'precipitation,weather_code,cloud_cover,surface_pressure,'
lib/services/weather_service.dart:161:          'wind_gusts_10m,uv_index,weather_code,'
lib/services/weather_service.dart:164:          'weather_code,temperature_2m_max,temperature_2m_min,'
lib/services/weather_service.dart:200:    final hourlyWeatherCodes = hourly['weather_code'] as List;
lib/services/weather_service.dart:237:        weatherCode: (hourlyWeatherCodes[sourceIndex] as num).round(),
lib/services/weather_service.dart:247:    final dailyWeatherCodes = daily['weather_code'] as List;
lib/services/weather_service.dart:259:        weatherCode: (dailyWeatherCodes[index] as num).round(),
lib/services/weather_service.dart:280:      cloudCover: (current['cloud_cover'] as num).round(),
lib/services/weather_service.dart:281:      weatherCode: (current['weather_code'] as num).round(),
lib/widgets/location_search_result_dialog.dart:15:          Icon(Icons.location_searching_outlined),
lib/widgets/location_search_result_dialog.dart:30:              leading: const Icon(Icons.location_on_outlined),
lib/widgets/radar/ortha_radar_map.dart:8:import '../../services/radar/rainviewer_radar_service.dart';
lib/widgets/radar/ortha_radar_map.dart:245:                const Icon(Icons.cloud_off_outlined, size: 48),
lib/widgets/radar/ortha_radar_map.dart:261:                  icon: const Icon(Icons.refresh),
lib/widgets/radar/ortha_radar_map.dart:322:                            Icons.location_on,
lib/widgets/radar/ortha_radar_map.dart:350:                          icon: const Icon(Icons.add),
lib/widgets/radar/ortha_radar_map.dart:356:                          icon: const Icon(Icons.remove),
lib/widgets/radar/ortha_radar_map.dart:362:                          icon: const Icon(Icons.my_location_outlined),
lib/widgets/radar/ortha_radar_map.dart:376:              const Icon(Icons.history_outlined, size: 20),
lib/widgets/radar/ortha_radar_map.dart:388:                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
lib/widgets/radar/ortha_radar_map.dart:412:                const Icon(Icons.schedule_outlined, size: 20),
lib/widgets/radar/ortha_radar_map.dart:466:                  Icon(Icons.palette_outlined, size: 19),
lib/widgets/radar/ortha_radar_map.dart:515:                Icon(Icons.history_toggle_off_outlined),
lib/widgets/radar/ortha_radar_map.dart:534:            const Icon(Icons.radar_outlined, size: 18),
lib/widgets/radar/ortha_radar_map.dart:542:              icon: const Icon(Icons.refresh, size: 18),
lib/widgets/warnings/official_warning_map.dart:98:                        Icons.location_on,
lib/widgets/warnings/official_warning_map.dart:132:                          ? Icons.location_on_outlined
lib/widgets/warnings/official_warning_map.dart:133:                          : Icons.location_off_outlined,
lib/widgets/warnings/official_warning_map.dart:174:                      Icons.map_outlined,
```
