import '../../models/official_weather_warning.dart';

abstract class OfficialWarningProvider {
  String get providerId;

  String get sourceName;

  bool supportsLocation({required double latitude, required double longitude});

  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  });
}
