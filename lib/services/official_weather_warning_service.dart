import '../models/official_weather_warning.dart';

abstract class OfficialWeatherWarningService {
  bool supportsLocation({required double latitude, required double longitude});

  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  });
}

class EmptyOfficialWeatherWarningService
    implements OfficialWeatherWarningService {
  const EmptyOfficialWeatherWarningService();

  @override
  bool supportsLocation({required double latitude, required double longitude}) {
    return false;
  }

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    return const [];
  }
}
