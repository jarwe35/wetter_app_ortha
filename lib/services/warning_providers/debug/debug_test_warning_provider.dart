import '../../../models/official_weather_warning.dart';
import '../official_warning_provider.dart';

class DebugTestWarningProvider implements OfficialWarningProvider {
  const DebugTestWarningProvider();

  @override
  String get providerId => 'debug_test';

  @override
  String get sourceName => 'ORTHA TEST / BBK Simulation';

  @override
  bool supportsLocation({required double latitude, required double longitude}) {
    // Nur Deutschland
    return latitude >= 47.0 &&
        latitude <= 55.5 &&
        longitude >= 5.5 &&
        longitude <= 15.5;
  }

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    if (!supportsLocation(latitude: latitude, longitude: longitude)) {
      return const [];
    }

    final now = DateTime.now();

    return [
      OfficialWeatherWarning(
        id: 'debug-bbk-duisburg-001',
        title: 'BBK / MoWaS Testwarnung',
        description:
            'Simulierte Warnmeldung für ORTHA METEO Ω. '
            'Dies ist eine Entwicklungsprüfung der Warnanzeige.',
        instruction:
            'Bitte prüfen Sie die angezeigten Informationen '
            'und beachten Sie die Hinweise der zuständigen Behörden.',
        source: 'BBK / MoWaS',
        severity: OfficialWarningSeverity.severe,
        validFrom: now,
        validUntil: now.add(const Duration(hours: 2)),
        areaDescriptions: const ['Duisburg'],
        geocodes: const {'CITY': 'Duisburg'},
      ),
    ];
  }
}
