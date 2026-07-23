import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/pollen_forecast.dart';
import '../models/pollen_provider.dart';

/// Pollendatenquelle auf Basis der Open-Meteo Air Quality API.
class OpenMeteoPollenProvider implements PollenProvider {
  OpenMeteoPollenProvider({http.Client? client})
    : _client = client ?? http.Client();

  static const List<PollenType> supportedTypes = [
    PollenType.alder,
    PollenType.birch,
    PollenType.grass,
    PollenType.mugwort,
    PollenType.olive,
    PollenType.ragweed,
  ];

  final http.Client _client;

  @override
  String get id => 'open-meteo';

  @override
  String get displayName => 'Open-Meteo';

  @override
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
      throw PollenProviderException(
        providerId: id,
        message: 'Die Pollendaten konnten nicht geladen werden.',
        cause: error,
      );
    }

    if (response.statusCode != 200) {
      throw PollenProviderException(
        providerId: id,
        message:
            'Der Pollendienst antwortete mit Status '
            '${response.statusCode}.',
      );
    }

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unerwartetes Antwortformat');
      }

      return parseForecast(decoded);
    } on PollenProviderException {
      rethrow;
    } on Exception catch (error) {
      throw PollenProviderException(
        providerId: id,
        message: 'Die Pollendaten konnten nicht verarbeitet werden.',
        cause: error,
      );
    }
  }

  /// Wandelt eine Open-Meteo-Antwort in das zentrale ORTHA-Datenmodell um.
  static PollenForecast parseForecast(Map<String, dynamic> json) {
    final hourly = json['hourly'];

    if (hourly is! Map<String, dynamic>) {
      throw const PollenProviderException(
        providerId: 'open-meteo',
        message: 'Die API-Antwort enthält keine stündlichen Pollendaten.',
      );
    }

    final rawTimes = hourly['time'];

    if (rawTimes is! List) {
      throw const PollenProviderException(
        providerId: 'open-meteo',
        message: 'Die API-Antwort enthält keine Zeitangaben.',
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
