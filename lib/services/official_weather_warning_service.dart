import '../models/official_weather_warning.dart';

abstract class OfficialWeatherWarningService {
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  });
}

class EmptyOfficialWeatherWarningService
    implements OfficialWeatherWarningService {
  const EmptyOfficialWeatherWarningService();

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    return const [];
  }
}
