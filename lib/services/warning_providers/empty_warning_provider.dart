import '../../models/official_weather_warning.dart';
import 'official_warning_provider.dart';

class EmptyWarningProvider implements OfficialWarningProvider {
  const EmptyWarningProvider();

  @override
  String get providerId => 'empty';

  @override
  String get sourceName => 'Keine amtliche Warnquelle';

  @override
  bool supportsLocation({required double latitude, required double longitude}) {
    return true;
  }

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    return const [];
  }
}
