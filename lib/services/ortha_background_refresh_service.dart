import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/official_weather_warning.dart';
import '../models/saved_location.dart';
import '../widgets/home/ortha_widget_service.dart';
import 'location_storage_service.dart';
import 'official_weather_warning_service.dart';
import 'provider_based_official_weather_warning_service.dart';
import 'warning_providers/bbk/bbk_warning_client.dart';
import 'warning_providers/bbk/bbk_warning_provider.dart';
import 'warning_providers/dwd_cap_download_client.dart';
import 'warning_providers/dwd_warning_provider.dart';
import 'weather_service.dart';

/// Führt eine vollständige Aktualisierung der Wetter- und Warninformationen
/// außerhalb der sichtbaren App aus.
///
/// Dieser Dienst besitzt keine UI-Abhängigkeiten und kann deshalb sowohl aus
/// einem WorkManager-Isolate als auch aus Tests oder Diagnosefunktionen
/// aufgerufen werden.
class OrthaBackgroundRefreshService {
  OrthaBackgroundRefreshService({
    LocationStorageService? locationStorageService,
  }) : _locationStorageService =
           locationStorageService ?? LocationStorageService();

  static const SavedLocation _fallbackLocation = SavedLocation(
    name: 'Duisburg',
    latitude: 51.4344,
    longitude: 6.7623,
    country: 'Deutschland',
    timezone: 'Europe/Berlin',
  );

  final LocationStorageService _locationStorageService;

  Future<OrthaBackgroundRefreshResult> refresh() async {
    final dwdHttpClient = http.Client();
    final bbkHttpClient = http.Client();
    final weatherHttpClient = http.Client();

    try {
      final selectedLocation = await _loadSelectedLocation();

      debugPrint(
        'ORTHA Background Ω: Aktualisierung für '
        '${selectedLocation.name} gestartet.',
      );

      final weatherService = WeatherService(httpClient: weatherHttpClient);

      final weather = await weatherService.fetchWeatherForLocation(
        selectedLocation,
      );

      final warningService = _createWarningService(
        dwdHttpClient: dwdHttpClient,
        bbkHttpClient: bbkHttpClient,
      );

      var warnings = <OfficialWeatherWarning>[];
      Object? warningError;

      final warningsSupported = warningService.supportsLocation(
        latitude: selectedLocation.latitude,
        longitude: selectedLocation.longitude,
      );

      if (warningsSupported) {
        try {
          warnings = await warningService.fetchWarnings(
            latitude: selectedLocation.latitude,
            longitude: selectedLocation.longitude,
          );
        } catch (error, stackTrace) {
          warningError = error;

          debugPrint(
            'ORTHA Background Ω: Amtliche Warnungen konnten nicht '
            'vollständig geladen werden: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        }
      }

      await OrthaWidgetService.update(
        weather: weather,
        placeOverride: selectedLocation.name,
        hasOfficialWarning: warnings.isNotEmpty,
      );

      debugPrint(
        'ORTHA Background Ω: Aktualisierung abgeschlossen. '
        'Ort=${selectedLocation.name}, '
        'Warnungen=${warnings.length}.',
      );

      return OrthaBackgroundRefreshResult(
        location: selectedLocation,
        warningCount: warnings.length,
        warningError: warningError,
      );
    } finally {
      weatherHttpClient.close();
      dwdHttpClient.close();
      bbkHttpClient.close();
    }
  }

  Future<SavedLocation> _loadSelectedLocation() async {
    final locations = await _locationStorageService.loadSavedLocations();

    if (locations.isEmpty) {
      return _fallbackLocation;
    }

    final selectedName = await _locationStorageService
        .loadSelectedSavedLocationName();

    if (selectedName == null || selectedName.trim().isEmpty) {
      return locations.first;
    }

    final normalizedSelectedName = selectedName.trim().toLowerCase();

    for (final location in locations) {
      if (location.name.trim().toLowerCase() == normalizedSelectedName) {
        return location;
      }
    }

    return locations.first;
  }

  OfficialWeatherWarningService _createWarningService({
    required http.Client dwdHttpClient,
    required http.Client bbkHttpClient,
  }) {
    final dwdProvider = DwdWarningProvider(
      downloadClient: DwdCapDownloadClient(
        httpClient: dwdHttpClient,
        sourceUri: Uri.parse(
          'https://opendata.dwd.de/weather/alerts/cap/'
          'COMMUNEUNION_DWD_STAT/'
          'Z_CAP_C_EDZW_LATEST_PVW_STATUS_PREMIUMDWD_'
          'COMMUNEUNION_DE.zip',
        ),
      ),
    );

    final bbkClient = HttpBbkWarningClient(
      httpClient: bbkHttpClient,
      endpoint: Uri.https('warnung.bund.de', '/api31/mowas/mapData.json'),
    );

    final bbkProvider = BbkWarningProvider(client: bbkClient);

    return ProviderBasedOfficialWeatherWarningService(
      providers: [dwdProvider, bbkProvider],
    );
  }
}

class OrthaBackgroundRefreshResult {
  const OrthaBackgroundRefreshResult({
    required this.location,
    required this.warningCount,
    this.warningError,
  });

  final SavedLocation location;
  final int warningCount;
  final Object? warningError;

  bool get warningsLoadedSuccessfully => warningError == null;
}
