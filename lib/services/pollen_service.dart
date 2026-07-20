import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pollen_forecast.dart';

class PollenServiceException implements Exception {
  final String message;

  const PollenServiceException(this.message);

  @override
  String toString() => message;
}

class PollenService {
  static const List<PollenType> supportedTypes = [
    PollenType.alder,
    PollenType.birch,
    PollenType.grass,
    PollenType.mugwort,
    PollenType.olive,
    PollenType.ragweed,
  ];

  final http.Client _client;

  PollenService({http.Client? client}) : _client = client ?? http.Client();

  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) async {
    final hourlyVariables = supportedTypes.map((type) => type.apiKey).join(',');

    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'hourly': hourlyVariables,
      'forecast_days': '4',
      'timezone': 'auto',
    });

    http.Response response;

    try {
      response = await _client.get(uri).timeout(const Duration(seconds: 20));
    } on Exception catch (error) {
      throw PollenServiceException(
        'Die Pollendaten konnten nicht geladen werden: $error',
      );
    }

    if (response.statusCode != 200) {
      throw PollenServiceException(
        'Der Pollendienst antwortete mit Status ${response.statusCode}.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unerwartetes Antwortformat');
      }

      return parseForecast(decoded);
    } on PollenServiceException {
      rethrow;
    } on Exception catch (error) {
      throw PollenServiceException(
        'Die Pollendaten konnten nicht verarbeitet werden: $error',
      );
    }
  }

  static PollenForecast parseForecast(Map<String, dynamic> json) {
    final hourly = json['hourly'];

    if (hourly is! Map<String, dynamic>) {
      throw const PollenServiceException(
        'Die API-Antwort enthält keine stündlichen Pollendaten.',
      );
    }

    final rawTimes = hourly['time'];

    if (rawTimes is! List) {
      throw const PollenServiceException(
        'Die API-Antwort enthält keine Zeitangaben.',
      );
    }

    final valuesByDay = <String, Map<PollenType, double>>{};
    final dateByKey = <String, DateTime>{};

    for (var index = 0; index < rawTimes.length; index++) {
      final rawTime = rawTimes[index];

      if (rawTime is! String) {
        continue;
      }

      final timestamp = DateTime.tryParse(rawTime);

      if (timestamp == null) {
        continue;
      }

      final dayKey = _dateKey(timestamp);
      dateByKey[dayKey] = DateTime(
        timestamp.year,
        timestamp.month,
        timestamp.day,
      );

      final maxima = valuesByDay.putIfAbsent(
        dayKey,
        () => <PollenType, double>{},
      );

      for (final type in supportedTypes) {
        final rawValues = hourly[type.apiKey];

        if (rawValues is! List || index >= rawValues.length) {
          maxima.putIfAbsent(type, () => 0);
          continue;
        }

        final rawValue = rawValues[index];
        final value = rawValue is num ? rawValue.toDouble() : 0.0;
        final safeValue = value.isFinite && value > 0 ? value : 0.0;
        final previousMaximum = maxima[type] ?? 0.0;

        if (safeValue > previousMaximum) {
          maxima[type] = safeValue;
        } else {
          maxima.putIfAbsent(type, () => previousMaximum);
        }
      }
    }

    final dayKeys = valuesByDay.keys.toList()..sort();

    final days = dayKeys
        .map((dayKey) {
          final maxima = valuesByDay[dayKey] ?? const <PollenType, double>{};

          return DailyPollenForecast(
            date: dateByKey[dayKey]!,
            values: supportedTypes
                .map(
                  (type) =>
                      PollenValue(type: type, concentration: maxima[type] ?? 0),
                )
                .toList(growable: false),
          );
        })
        .toList(growable: false);

    final latitude = json['latitude'];
    final longitude = json['longitude'];

    return PollenForecast(
      latitude: latitude is num ? latitude.toDouble() : 0,
      longitude: longitude is num ? longitude.toDouble() : 0,
      timezone: json['timezone']?.toString() ?? 'Unbekannt',
      days: days,
    );
  }

  static String _dateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '${date.year}-$month-$day';
  }
}
