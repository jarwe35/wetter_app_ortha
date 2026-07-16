import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'engine/risk_engine.dart';
import 'models/official_weather_warning.dart';
import 'models/saved_location.dart';
import 'pages/locations_page.dart';
import 'services/location_migration_service.dart';
import 'services/location_service.dart';
import 'services/location_storage_service.dart';
import 'services/official_weather_warning_service.dart';
import 'services/provider_based_official_weather_warning_service.dart';
import 'services/warning_providers/bbk/bbk_warning_client.dart';
import 'services/warning_providers/bbk/bbk_warning_provider.dart';
import 'services/warning_providers/dwd_cap_download_client.dart';
import 'services/warning_providers/dwd_warning_provider.dart';
import 'services/weather_service.dart';
import 'widgets/location_search_result_dialog.dart';
import 'widgets/weather/ortha_weather_icon.dart';
import 'widgets/radar/ortha_radar_map.dart';
import 'widgets/warnings/official_warning_map.dart';
import 'settings/unit_settings.dart';
import 'settings/unit_settings_page.dart';
import 'settings/unit_settings_service.dart';
import 'utils/official_warning_text_formatter.dart';

part 'widgets/weather/daily_forecast_card.dart';
part 'widgets/weather/hourly_forecast_card.dart';
part 'widgets/weather/current_weather_card.dart';

const Color orthaBackground = Color(0xFF08131F);
const Color orthaSurface = Color(0xFF102235);
const Color orthaSurfaceElevated = Color(0xFF153149);
const Color orthaPrimaryText = Color(0xFFF2F7FA);
const Color orthaSecondaryText = Color(0xFF9FB3C2);
const Color orthaAccent = Color(0xFFD5A84A);
const Color orthaBorder = Color(0xFF27465D);

void main() {
  runApp(const OrthaWeatherApp());
}

class OrthaWeatherApp extends StatelessWidget {
  const OrthaWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORTHA Wetter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: orthaBackground,
        colorScheme: ColorScheme.fromSeed(
          seedColor: orthaAccent,
          brightness: Brightness.dark,
          surface: orthaSurface,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: orthaPrimaryText),
          bodyMedium: TextStyle(color: orthaPrimaryText),
          bodySmall: TextStyle(color: orthaSecondaryText),
          titleLarge: TextStyle(color: orthaPrimaryText),
          titleMedium: TextStyle(color: orthaPrimaryText),
          titleSmall: TextStyle(color: orthaPrimaryText),
        ),
        iconTheme: const IconThemeData(color: orthaPrimaryText),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  static const SavedLocation _defaultLocation = SavedLocation(
    name: 'Duisburg',
    latitude: 51.4344,
    longitude: 6.7623,
    country: 'Deutschland',
    timezone: 'Europe/Berlin',
  );

  final WeatherService weatherService = WeatherService();
  final LocationStorageService locationStorageService =
      LocationStorageService();
  final RiskEngine riskEngine = const RiskEngine();
  final UnitSettingsService unitSettingsService = UnitSettingsService();

  late final http.Client locationHttpClient;
  late final LocationService locationService;
  late final LocationMigrationService locationMigrationService;

  late final http.Client dwdHttpClient;
  late final DwdWarningProvider dwdWarningProvider;

  late final http.Client bbkHttpClient;
  late final HttpBbkWarningClient bbkWarningClient;
  late final BbkWarningProvider bbkWarningProvider;

  late final OfficialWeatherWarningService officialWeatherWarningService;

  UnitSettings unitSettings = const UnitSettings();

  final List<SavedLocation> savedLocations = [];

  SavedLocation? selectedLocation;
  String selectedPlace = 'Duisburg';
  WeatherData? weatherData;
  RiskResult? riskResult;

  List<OfficialWeatherWarning> officialWarnings = [];
  bool officialWarningsSupported = false;
  bool officialWarningsLoading = false;
  String? officialWarningsError;

  bool isLoading = false;
  String? errorMessage;

  int selectedNavigationIndex = 0;

  @override
  void initState() {
    super.initState();

    locationHttpClient = http.Client();
    locationService = LocationService(httpClient: locationHttpClient);
    locationMigrationService = LocationMigrationService(
      storageService: locationStorageService,
      locationService: locationService,
    );

    dwdHttpClient = http.Client();
    dwdWarningProvider = DwdWarningProvider(
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

    bbkHttpClient = http.Client();

    bbkWarningClient = HttpBbkWarningClient(
      httpClient: bbkHttpClient,

      // Vorübergehend noch erforderlicher Legacy-Parameter.
      // Die reale Provider-Kette verwendet fetchMapData(),
      // fetchWarningDetail() und fetchWarningGeometry().
      endpoint: Uri.https('warnung.bund.de', '/api31/mowas/mapData.json'),
    );

    bbkWarningProvider = BbkWarningProvider(client: bbkWarningClient);

    officialWeatherWarningService = ProviderBasedOfficialWeatherWarningService(
      providers: [dwdWarningProvider, bbkWarningProvider],
    );

    initializeUnitSettings();
    initializeLocations();
  }

  @override
  void dispose() {
    locationHttpClient.close();
    dwdHttpClient.close();
    bbkHttpClient.close();
    super.dispose();
  }

  Future<void> initializeUnitSettings() async {
    final storedSettings = await unitSettingsService.load();

    if (!mounted) return;

    setState(() {
      unitSettings = storedSettings;
    });
  }

  Future<void> openUnitSettings() async {
    final updatedSettings = await Navigator.push<UnitSettings>(
      context,
      MaterialPageRoute(
        builder: (_) => UnitSettingsPage(initialSettings: unitSettings),
      ),
    );

    if (updatedSettings == null || !mounted) return;

    setState(() {
      unitSettings = updatedSettings;
    });

    await unitSettingsService.save(updatedSettings);
  }

  Future<void> initializeLocations() async {
    final migrationResult = await locationMigrationService
        .migrateLegacyLocations();

    final storedSelectedSavedLocationName = await locationStorageService
        .loadSelectedSavedLocationName();

    final storedSavedLocations = List<SavedLocation>.from(
      migrationResult.locations,
    );

    if (storedSavedLocations.isEmpty) {
      storedSavedLocations.add(_defaultLocation);

      await locationStorageService.saveSavedLocations(storedSavedLocations);
      await locationStorageService.saveSelectedSavedLocationName(
        _defaultLocation.name,
      );
    }

    if (!mounted) return;

    SavedLocation? initialSavedLocation;

    if (storedSelectedSavedLocationName != null) {
      for (final location in storedSavedLocations) {
        if (location.name.toLowerCase() ==
            storedSelectedSavedLocationName.toLowerCase()) {
          initialSavedLocation = location;
          break;
        }
      }
    }

    initialSavedLocation ??= storedSavedLocations.first;

    setState(() {
      savedLocations
        ..clear()
        ..addAll(storedSavedLocations);

      selectedLocation = initialSavedLocation;
      selectedPlace = initialSavedLocation!.name;
    });

    await locationStorageService.saveSelectedSavedLocationName(
      initialSavedLocation.name,
    );
    await locationStorageService.saveSelectedLocation(
      initialSavedLocation.name,
    );

    await loadWeather(initialSavedLocation.name);
  }

  SavedLocation? _findSavedLocation(String place) {
    final normalizedPlace = place.trim().toLowerCase();

    for (final location in savedLocations) {
      if (location.name.trim().toLowerCase() == normalizedPlace) {
        return location;
      }
    }

    return null;
  }

  Future<void> loadWeather(String place) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
      officialWarnings = [];
      officialWarningsError = null;
      officialWarningsLoading = false;
    });

    try {
      final savedLocation = _findSavedLocation(place);

      if (mounted) {
        setState(() {
          selectedLocation = savedLocation;
        });
      }

      final data = savedLocation == null
          ? await weatherService.fetchWeather(place)
          : await weatherService.fetchWeatherForLocation(savedLocation);

      final risk = riskEngine.evaluate(data);

      final locationLatitude = savedLocation?.latitude ?? data.latitude;
      final locationLongitude = savedLocation?.longitude ?? data.longitude;

      final warningsSupported = officialWeatherWarningService.supportsLocation(
        latitude: locationLatitude,
        longitude: locationLongitude,
      );

      var warnings = <OfficialWeatherWarning>[];
      String? warningsError;

      if (warningsSupported) {
        if (mounted) {
          setState(() {
            officialWarningsLoading = true;
          });
        }

        try {
          warnings = await officialWeatherWarningService.fetchWarnings(
            latitude: locationLatitude,
            longitude: locationLongitude,
          );
        } catch (error) {
          warningsError = 'Amtliche Warnungen sind derzeit nicht verfügbar.';
        }
      }

      if (!mounted) return;

      setState(() {
        weatherData = data;
        riskResult = risk;
        selectedPlace = savedLocation?.name ?? data.place;
        selectedLocation =
            savedLocation ??
            SavedLocation(
              name: data.place,
              latitude: data.latitude,
              longitude: data.longitude,
            );

        officialWarningsSupported = warningsSupported;
        officialWarnings = warnings;
        officialWarningsError = warningsError;
        officialWarningsLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
        officialWarningsLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void addPlace() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ort hinzufügen'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Ort',
              hintText: 'z. B. Düsseldorf, Dinard, Berlin',
            ),
            onSubmitted: (_) {
              addPlaceFromDialog(controller, dialogContext);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                addPlaceFromDialog(controller, dialogContext);
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  Future<SavedLocation?> _selectLocationSearchResult(
    BuildContext context,
    List<SavedLocation> results,
  ) async {
    if (results.length == 1) {
      return results.first;
    }

    return showDialog<SavedLocation>(
      context: context,
      builder: (selectionContext) {
        return LocationSearchResultDialog(results: results);
      },
    );
  }

  Future<void> addPlaceFromDialog(
    TextEditingController controller,
    BuildContext dialogContext,
  ) async {
    final value = controller.text.trim();

    if (value.isEmpty) return;

    List<SavedLocation> searchResults;

    try {
      searchResults = await locationService.searchLocations(value);
    } on LocationServiceException catch (error) {
      if (!dialogContext.mounted) return;

      ScaffoldMessenger.of(
        dialogContext,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }

    if (!dialogContext.mounted) return;

    final resolvedLocation = await _selectLocationSearchResult(
      dialogContext,
      searchResults,
    );

    if (resolvedLocation == null || !dialogContext.mounted) {
      return;
    }

    final existingLocation = savedLocations.cast<SavedLocation?>().firstWhere(
      (location) =>
          location?.name.trim().toLowerCase() ==
          resolvedLocation.name.trim().toLowerCase(),
      orElse: () => null,
    );

    final locationToSelect = existingLocation ?? resolvedLocation;

    if (existingLocation == null) {
      setState(() {
        savedLocations.add(resolvedLocation);

        selectedLocation = resolvedLocation;
        selectedPlace = resolvedLocation.name;
      });

      await locationStorageService.saveSavedLocations(savedLocations);
    } else {
      setState(() {
        selectedLocation = existingLocation;
        selectedPlace = existingLocation.name;
      });
    }

    await locationStorageService.saveSelectedSavedLocationName(
      locationToSelect.name,
    );
    await locationStorageService.saveSelectedLocation(locationToSelect.name);

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    await loadWeather(locationToSelect.name);
  }

  Future<void> _selectSavedLocation(SavedLocation location) async {
    if (!mounted) return;

    setState(() {
      selectedLocation = location;
      selectedPlace = location.name;
    });

    await locationStorageService.saveSelectedLocation(location.name);
    await locationStorageService.saveSelectedSavedLocationName(location.name);

    await loadWeather(location.name);
  }

  Future<void> deleteSavedLocation(SavedLocation location) async {
    if (savedLocations.length == 1) return;

    final normalizedName = location.name.trim().toLowerCase();
    final deletingSelectedLocation =
        selectedLocation?.name.trim().toLowerCase() == normalizedName;

    setState(() {
      savedLocations.removeWhere(
        (storedLocation) =>
            storedLocation.name.trim().toLowerCase() == normalizedName,
      );

      if (deletingSelectedLocation && savedLocations.isNotEmpty) {
        selectedLocation = savedLocations.first;
        selectedPlace = selectedLocation!.name;
      }
    });

    await locationStorageService.saveSavedLocations(savedLocations);

    if (deletingSelectedLocation && selectedLocation != null) {
      await locationStorageService.saveSelectedLocation(selectedLocation!.name);
      await locationStorageService.saveSelectedSavedLocationName(
        selectedLocation!.name,
      );

      await loadWeather(selectedLocation!.name);
    }
  }

  Future<void> _renameSavedLocation(
    SavedLocation location,
    String newPlace,
  ) async {
    final cleanedName = newPlace.trim();
    final normalizedOldPlace = location.name.trim().toLowerCase();
    final normalizedNewPlace = cleanedName.toLowerCase();

    if (cleanedName.isEmpty || normalizedNewPlace == normalizedOldPlace) {
      return;
    }

    final nameAlreadyExists = savedLocations.any(
      (location) =>
          location.name.trim().toLowerCase() == normalizedNewPlace &&
          location.name.trim().toLowerCase() != normalizedOldPlace,
    );

    if (nameAlreadyExists) {
      return;
    }

    final savedLocationIndex = savedLocations.indexWhere(
      (location) => location.name.trim().toLowerCase() == normalizedOldPlace,
    );

    if (savedLocationIndex < 0) {
      return;
    }

    final renamingSelectedPlace =
        selectedPlace.trim().toLowerCase() == normalizedOldPlace;

    setState(() {
      savedLocations[savedLocationIndex] = savedLocations[savedLocationIndex]
          .copyWith(name: cleanedName);

      if (renamingSelectedPlace) {
        selectedLocation = savedLocations[savedLocationIndex];
        selectedPlace = selectedLocation!.name;
      }
    });

    await locationStorageService.saveSavedLocations(savedLocations);

    if (renamingSelectedPlace && selectedLocation != null) {
      await locationStorageService.saveSelectedLocation(selectedLocation!.name);
      await locationStorageService.saveSelectedSavedLocationName(
        selectedLocation!.name,
      );
    }
  }

  Future<void> _reorderSavedLocations(List<SavedLocation> newLocations) async {
    if (!mounted) return;

    setState(() {
      savedLocations
        ..clear()
        ..addAll(newLocations);
    });

    await locationStorageService.saveSavedLocations(savedLocations);
  }

  Future<void> openLocationsPage() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => LocationsPage(
          locations: savedLocations,
          selectedLocation: selectedLocation,
          onSelect: _selectSavedLocation,
          onDelete: deleteSavedLocation,
          onReorder: _reorderSavedLocations,
          onRename: _renameSavedLocation,
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }
  }

  void handleNavigationSelection(int index) {
    if (index == 4) {
      setState(() {
        selectedNavigationIndex = index;
      });
      return;
    }

    if (index == 2) {
      setState(() {
        selectedNavigationIndex = index;
      });
      return;
    }

    if (index == 3) {
      setState(() {
        selectedNavigationIndex = index;
      });
      return;
    }

    setState(() {
      selectedNavigationIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = weatherData;
    final risk = riskResult;

    return Scaffold(
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: orthaSurface,
          border: Border(
            top: BorderSide(color: orthaBorder.withValues(alpha: 0.85)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 20,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            height: 72,
            selectedIndex: selectedNavigationIndex,
            onDestinationSelected: handleNavigationSelection,
            backgroundColor: orthaSurface,
            indicatorColor: orthaAccent.withValues(alpha: 0.18),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home, color: orthaAccent),
                label: 'Heute',
              ),
              NavigationDestination(
                icon: Icon(Icons.warning_amber_outlined),
                selectedIcon: Icon(Icons.warning_amber, color: orthaAccent),
                label: 'Warnungen',
              ),
              NavigationDestination(
                icon: Icon(Icons.shield_outlined),
                selectedIcon: Icon(Icons.shield, color: orthaAccent),
                label: 'Risiken',
              ),
              NavigationDestination(
                icon: Icon(Icons.radar_outlined),
                selectedIcon: Icon(Icons.radar, color: orthaAccent),
                label: 'Radar',
              ),
              NavigationDestination(
                icon: Icon(Icons.location_on_outlined),
                selectedIcon: Icon(Icons.location_on, color: orthaAccent),
                label: 'Orte',
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: orthaSurface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: orthaBorder.withValues(alpha: 0.85),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: orthaAccent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: orthaAccent.withValues(alpha: 0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.cloud_outlined,
                        color: orthaAccent,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ORTHA METEO Ω',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: orthaPrimaryText,
                              letterSpacing: 0.4,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Wetter · Warnungen · Risikoanalyse',
                            style: TextStyle(
                              fontSize: 14,
                              color: orthaSecondaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Einheiten',
                      onPressed: openUnitSettings,
                      icon: const Icon(Icons.straighten_outlined),
                    ),
                    const SizedBox(width: 4),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LocationsPage(
                              locations: savedLocations,
                              selectedLocation: selectedLocation,
                              onSelect: _selectSavedLocation,
                              onDelete: deleteSavedLocation,
                              onReorder: _reorderSavedLocations,
                              onRename: _renameSavedLocation,
                            ),
                          ),
                        );

                        if (mounted) {
                          setState(() {});
                        }
                      },
                      icon: const Icon(Icons.location_city_outlined),
                      label: const Text('Meine Orte'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              PlaceSelector(
                locations: savedLocations,
                selectedLocation: selectedLocation,
                onSelect: _selectSavedLocation,
                onDelete: deleteSavedLocation,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: selectedNavigationIndex == 1
                    ? ListView(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: orthaSurface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: orthaBorder.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: orthaAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: orthaAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.warning_amber_rounded,
                                    color: orthaAccent,
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Warnungen',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: orthaPrimaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Amtliche Wetterwarnungen für $selectedPlace',
                                        style: const TextStyle(
                                          color: orthaSecondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Warnungen aktualisieren',
                                  onPressed: () => loadWeather(selectedPlace),
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (isLoading)
                            const CardBox(
                              child: Text(
                                'Wetter- und Warnungsdaten werden geladen …',
                              ),
                            )
                          else if (errorMessage != null)
                            CardBox(child: Text(errorMessage!))
                          else
                            OfficialWeatherWarningsCard(
                              warnings: officialWarnings,
                              isSupported: officialWarningsSupported,
                              isLoading: officialWarningsLoading,
                              errorMessage: officialWarningsError,
                              latitude:
                                  selectedLocation?.latitude ??
                                  data?.latitude ??
                                  0.0,
                              longitude:
                                  selectedLocation?.longitude ??
                                  data?.longitude ??
                                  0.0,
                              place: selectedPlace,
                            ),
                          const SizedBox(height: 30),
                        ],
                      )
                    : selectedNavigationIndex == 2
                    ? ListView(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: orthaSurface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: orthaBorder.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: orthaAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: orthaAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.shield_outlined,
                                    color: orthaAccent,
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ORTHA Risiken',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: orthaPrimaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Risikobewertung für $selectedPlace',
                                        style: const TextStyle(
                                          color: orthaSecondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Risikoanalyse aktualisieren',
                                  onPressed: () => loadWeather(selectedPlace),
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (isLoading)
                            const CardBox(
                              child: Text(
                                'Wetter- und Risikodaten werden geladen …',
                              ),
                            )
                          else if (errorMessage != null)
                            CardBox(child: Text(errorMessage!))
                          else if (risk != null) ...[
                            WarningLevelBar(result: risk),
                            const SizedBox(height: 18),
                            RiskCard(result: risk),
                            const SizedBox(height: 18),
                            RiskCategoriesCard(categories: risk.categories),
                          ],
                          const SizedBox(height: 30),
                        ],
                      )
                    : selectedNavigationIndex == 3
                    ? ListView(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: orthaSurface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: orthaBorder.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: orthaAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: orthaAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.radar_outlined,
                                    color: orthaAccent,
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'ORTHA Radar',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: orthaPrimaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Radar- und Niederschlagslage für $selectedPlace',
                                        style: const TextStyle(
                                          color: orthaSecondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Wetterdaten aktualisieren',
                                  onPressed: () => loadWeather(selectedPlace),
                                  icon: const Icon(Icons.refresh),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          CardBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.layers_outlined,
                                      color: orthaAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Niederschlagsradar',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 18),
                                if (selectedLocation == null)
                                  const SizedBox(
                                    height: 380,
                                    child: Center(
                                      child: Text(
                                        'Für die Radaransicht werden zunächst '
                                        'Standortdaten geladen.',
                                      ),
                                    ),
                                  )
                                else
                                  OrthaRadarMap(
                                    latitude: selectedLocation!.latitude,
                                    longitude: selectedLocation!.longitude,
                                    place: selectedLocation!.name,
                                  ),
                                const SizedBox(height: 16),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.info_outline,
                                      size: 18,
                                      color: orthaSecondaryText,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Radarquelle: RainViewer · '
                                        'Basiskarte: OpenStreetMap',
                                        style: TextStyle(
                                          color: orthaSecondaryText,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          if (data != null)
                            WeatherDetailsCard(
                              data: data,
                              unitSettings: unitSettings,
                            ),
                          const SizedBox(height: 30),
                        ],
                      )
                    : selectedNavigationIndex == 4
                    ? ListView(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: orthaSurface,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: orthaBorder.withValues(alpha: 0.85),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: orthaAccent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(
                                      color: orthaAccent.withValues(
                                        alpha: 0.35,
                                      ),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.location_on_outlined,
                                    color: orthaAccent,
                                    size: 27,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Meine Orte',
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: orthaPrimaryText,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${savedLocations.length} gespeicherte Orte',
                                        style: const TextStyle(
                                          color: orthaSecondaryText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Ort hinzufügen',
                                  onPressed: addPlace,
                                  icon: const Icon(
                                    Icons.add_location_alt_outlined,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          CardBox(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.bookmarks_outlined,
                                      color: orthaAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        'Gespeicherte Orte',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                ...savedLocations.map((location) {
                                  final place = location.name;
                                  final selected = place == selectedPlace;

                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.only(bottom: 10),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? orthaAccent.withValues(alpha: 0.10)
                                          : orthaSurfaceElevated,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: selected
                                            ? orthaAccent.withValues(
                                                alpha: 0.55,
                                              )
                                            : orthaBorder.withValues(
                                                alpha: 0.75,
                                              ),
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.circular(16),
                                      clipBehavior: Clip.antiAlias,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 14,
                                              vertical: 5,
                                            ),
                                        leading: Icon(
                                          selected
                                              ? Icons.location_on
                                              : Icons.location_on_outlined,
                                          color: selected
                                              ? orthaAccent
                                              : orthaSecondaryText,
                                        ),
                                        title: Text(
                                          place,
                                          style: TextStyle(
                                            color: orthaPrimaryText,
                                            fontWeight: selected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                          ),
                                        ),
                                        subtitle: selected
                                            ? const Text(
                                                'Aktuell ausgewählter Ort',
                                                style: TextStyle(
                                                  color: orthaSecondaryText,
                                                ),
                                              )
                                            : null,
                                        onTap: () {
                                          final location = _findSavedLocation(
                                            place,
                                          );

                                          if (location != null) {
                                            _selectSavedLocation(location);
                                          }
                                        },
                                        trailing: savedLocations.length > 1
                                            ? IconButton(
                                                tooltip: 'Ort löschen',
                                                onPressed: () {
                                                  final location =
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

class PlaceSelector extends StatelessWidget {
  final List<SavedLocation> locations;
  final SavedLocation? selectedLocation;
  final ValueChanged<SavedLocation> onSelect;
  final ValueChanged<SavedLocation> onDelete;

  const PlaceSelector({
    super.key,
    required this.locations,
    required this.selectedLocation,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        scrollDirection: Axis.horizontal,
        itemCount: locations.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final location = locations[index];
          final selected =
              selectedLocation?.name.trim().toLowerCase() ==
              location.name.trim().toLowerCase();

          return InputChip(
            label: Text(location.name),
            selected: selected,
            onPressed: () {
              onSelect(location);
            },
            onDeleted: locations.length > 1
                ? () {
                    onDelete(location);
                  }
                : null,
          );
        },
      ),
    );
  }
}

class OfficialWeatherWarningsCard extends StatelessWidget {
  final List<OfficialWeatherWarning> warnings;
  final bool isSupported;
  final bool isLoading;
  final String? errorMessage;
  final double latitude;
  final double longitude;
  final String place;

  const OfficialWeatherWarningsCard({
    super.key,
    required this.warnings,
    required this.isSupported,
    required this.isLoading,
    required this.errorMessage,
    required this.latitude,
    required this.longitude,
    required this.place,
  });

  Color severityColor(OfficialWarningSeverity severity) {
    switch (severity) {
      case OfficialWarningSeverity.minor:
        return const Color(0xFFD1A928);
      case OfficialWarningSeverity.moderate:
        return const Color(0xFFD77B2E);
      case OfficialWarningSeverity.severe:
        return const Color(0xFFB94A48);
      case OfficialWarningSeverity.extreme:
        return const Color(0xFF7E2634);
      case OfficialWarningSeverity.unknown:
        return const Color(0xFF607D86);
    }
  }

  String severityText(OfficialWarningSeverity severity) {
    switch (severity) {
      case OfficialWarningSeverity.minor:
        return 'Geringe Warnstufe';
      case OfficialWarningSeverity.moderate:
        return 'Erhöhte Warnstufe';
      case OfficialWarningSeverity.severe:
        return 'Schwere Warnlage';
      case OfficialWarningSeverity.extreme:
        return 'Extreme Warnlage';
      case OfficialWarningSeverity.unknown:
        return 'Warnstufe nicht angegeben';
    }
  }

  String sourceLabel(OfficialWeatherWarning warning) {
    final normalizedId = warning.id.trim().toLowerCase();
    final normalizedSource = warning.source.trim().toLowerCase();

    if (normalizedId.startsWith('mow.') ||
        normalizedSource.contains('bbk') ||
        normalizedSource.contains('warnung.bund')) {
      return 'BBK / MoWaS';
    }

    if (normalizedSource.contains('dwd') ||
        normalizedSource.contains('deutscher wetterdienst')) {
      return 'DWD';
    }

    return warning.source.trim().isEmpty
        ? 'Amtliche Warnquelle'
        : warning.source.trim();
  }

  IconData sourceIcon(OfficialWeatherWarning warning) {
    return sourceLabel(warning) == 'DWD'
        ? Icons.cloud_outlined
        : Icons.shield_outlined;
  }

  String formatWarningTime(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$day.$month. · $hour:$minute Uhr';
  }

  @override
  Widget build(BuildContext context) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.campaign_outlined, color: orthaAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Amtliche Wetterwarnungen',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Offizielle externe Warnquelle – unabhängig von ORTHA',
            style: TextStyle(fontSize: 13, color: orthaSecondaryText),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: orthaSurfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: orthaBorder.withValues(alpha: 0.72)),
              ),
              child: const Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: orthaAccent,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Amtliche Warnungen werden geladen …',
                      style: TextStyle(color: orthaSecondaryText),
                    ),
                  ),
                ],
              ),
            )
          else if (!isSupported)
            const _OfficialWarningStatusBox(
              icon: Icons.public_off_outlined,
              color: orthaSecondaryText,
              text:
                  'Für diesen Ort ist derzeit noch keine amtliche Warnquelle angebunden.',
            )
          else if (errorMessage != null)
            _OfficialWarningStatusBox(
              icon: Icons.error_outline,
              color: Color(0xFFB94A48),
              text: errorMessage!,
            )
          else if (warnings.isEmpty)
            const _OfficialWarningStatusBox(
              icon: Icons.verified_outlined,
              color: Color(0xFF4F8A70),
              text:
                  'Aktuell liegen für diesen Ort keine amtlichen Warnungen vor.',
            )
          else
            ...warnings.map((warning) {
              final color = severityColor(warning.severity);

              final cleanedDescription = OfficialWarningTextFormatter.sanitize(
                warning.description,
              );

              final descriptionSummary = OfficialWarningTextFormatter.summary(
                warning.description,
              );

              final cleanedInstruction = OfficialWarningTextFormatter.sanitize(
                warning.instruction,
              );

              final hasExtendedDescription =
                  cleanedDescription.isNotEmpty &&
                  cleanedDescription != descriptionSummary;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: color.withValues(alpha: 0.50)),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.10),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.16),
                            shape: BoxShape.circle,
                            border: Border.all(color: color),
                          ),
                          child: Icon(
                            Icons.warning_amber_rounded,
                            color: color,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 9,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: orthaSurfaceElevated,
                                      borderRadius: BorderRadius.circular(999),
                                      border: Border.all(
                                        color: color.withValues(alpha: 0.55),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          sourceIcon(warning),
                                          size: 15,
                                          color: color,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          sourceLabel(warning),
                                          style: TextStyle(
                                            color: color,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    severityText(warning.severity),
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                warning.title,
                                style: const TextStyle(
                                  color: orthaPrimaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (warning.areaDescriptions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: orthaSecondaryText,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              warning.areaDescriptions.join(', '),
                              style: const TextStyle(color: orthaSecondaryText),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 18,
                          color: orthaSecondaryText,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            'Gültig: ${formatWarningTime(warning.validFrom)}'
                            ' bis ${formatWarningTime(warning.validUntil)}',
                            style: const TextStyle(color: orthaSecondaryText),
                          ),
                        ),
                      ],
                    ),
                    if (warning.geometry != null &&
                        !warning.geometry!.isEmpty) ...[
                      const SizedBox(height: 14),
                      OfficialWarningMap(
                        warning: warning,
                        latitude: latitude,
                        longitude: longitude,
                        place: place,
                      ),
                    ],
                    if (descriptionSummary.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: orthaSurfaceElevated,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: orthaBorder.withValues(alpha: 0.72),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.summarize_outlined,
                                  size: 18,
                                  color: orthaAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Kurzinfo',
                                  style: TextStyle(
                                    color: orthaAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              descriptionSummary,
                              style: const TextStyle(
                                color: orthaPrimaryText,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (hasExtendedDescription) ...[
                      const SizedBox(height: 10),
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          childrenPadding: const EdgeInsets.fromLTRB(
                            4,
                            0,
                            4,
                            12,
                          ),
                          leading: const Icon(
                            Icons.article_outlined,
                            color: orthaSecondaryText,
                          ),
                          title: const Text(
                            'Amtlichen Originaltext anzeigen',
                            style: TextStyle(
                              color: orthaPrimaryText,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: SelectableText(
                                cleanedDescription,
                                style: const TextStyle(
                                  color: orthaSecondaryText,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (cleanedInstruction.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: orthaSurfaceElevated,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: orthaBorder.withValues(alpha: 0.72),
                          ),
                        ),
                        child: Text(
                          'Amtliche Handlungsempfehlung:\n$cleanedInstruction',
                          style: const TextStyle(
                            color: orthaPrimaryText,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Text(
                      'Herausgeber: ${warning.source}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: orthaSecondaryText,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _OfficialWarningStatusBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _OfficialWarningStatusBox({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: orthaSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.42)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: const TextStyle(color: orthaPrimaryText)),
          ),
        ],
      ),
    );
  }
}

class RiskCard extends StatelessWidget {
  final RiskResult result;

  const RiskCard({super.key, required this.result});

  Color riskColor() {
    switch (result.level) {
      case RiskLevel.green:
        return const Color(0xFF4F8A70);
      case RiskLevel.yellow:
        return const Color(0xFFD1A928);
      case RiskLevel.orange:
        return const Color(0xFFD77B2E);
      case RiskLevel.red:
        return const Color(0xFFB94A48);
    }
  }

  String riskLabel() {
    switch (result.level) {
      case RiskLevel.green:
        return 'Geringe Belastung';
      case RiskLevel.yellow:
        return 'Erhöhte Aufmerksamkeit';
      case RiskLevel.orange:
        return 'Deutliche Belastung';
      case RiskLevel.red:
        return result.score >= 85 ? 'Extreme Belastung' : 'Hohe Belastung';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = riskColor();

    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.psychology_alt_outlined, color: orthaAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ORTHA Risikoanalyse',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Eigenständige Bewertung aus aktuellen Messwerten und Prognosen',
            style: TextStyle(color: orthaSecondaryText, fontSize: 13),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.50)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: color),
                  ),
                  child: Icon(Icons.shield_outlined, color: color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        riskLabel(),
                        style: TextStyle(
                          color: color,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        result.title,
                        style: const TextStyle(
                          color: orthaPrimaryText,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: result.score / 100,
                  minHeight: 9,
                  borderRadius: BorderRadius.circular(10),
                  color: color,
                  backgroundColor: color.withValues(alpha: 0.16),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${result.score} / 100',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            result.message,
            style: const TextStyle(color: orthaPrimaryText, height: 1.35),
          ),
          if (result.factors.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Erkannte Risikofaktoren',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...result.factors.map(
              (factor) => Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: orthaSurfaceElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: orthaBorder.withValues(alpha: 0.72),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.circle, size: 8, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        factor,
                        style: const TextStyle(color: orthaSecondaryText),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

double temperatureForDisplay(double celsius, UnitSettings settings) {
  if (settings.temperatureUnit == TemperatureUnit.fahrenheit) {
    return (celsius * 9 / 5) + 32;
  }
  return celsius;
}

String temperatureUnitText(UnitSettings settings) {
  return settings.temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';
}

String formatTemperature(
  double celsius,
  UnitSettings settings, {
  int decimals = 1,
}) {
  final value = temperatureForDisplay(celsius, settings);
  return '${value.toStringAsFixed(decimals)} ${temperatureUnitText(settings)}';
}

String formatWindSpeed(
  double kilometersPerHour,
  UnitSettings settings, {
  int decimals = 1,
}) {
  if (settings.windSpeedUnit == WindSpeedUnit.knots) {
    final knots = kilometersPerHour / 1.852;
    return '${knots.toStringAsFixed(decimals)} kn';
  }

  return '${kilometersPerHour.toStringAsFixed(decimals)} km/h';
}

String formatVisibility(double meters, UnitSettings settings) {
  if (settings.visibilityUnit == VisibilityUnit.miles) {
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(1)} mi';
  }

  final kilometers = meters / 1000;
  return '${kilometers.toStringAsFixed(1)} km';
}

String formatPrecipitation(double millimeters, UnitSettings settings) {
  if (settings.precipitationUnit == PrecipitationUnit.inches) {
    final inches = millimeters / 25.4;
    return '${inches.toStringAsFixed(2)} in';
  }

  return '${millimeters.toStringAsFixed(1)} mm';
}

String weatherText(int code) {
  if (code == 0) return 'Klar';
  if ([1, 2, 3].contains(code)) return 'Bewölkt';
  if ([45, 48].contains(code)) return 'Nebel';
  if ([51, 53, 55, 56, 57].contains(code)) return 'Niesel';
  if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Regen';
  if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Schnee';
  if ([95, 96, 99].contains(code)) return 'Gewitter';
  return 'Wetter';
}

IconData weatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny_outlined;
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

class BulletText extends StatelessWidget {
  final String text;

  const BulletText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class WeatherDetailsCard extends StatelessWidget {
  final WeatherData data;
  final UnitSettings unitSettings;

  const WeatherDetailsCard({
    super.key,
    required this.data,
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
              Icon(Icons.monitor_heart_outlined, color: orthaAccent),
              SizedBox(width: 10),
              Text(
                'Messwerte',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DetailRow(
            icon: Icons.water_drop_outlined,
            label: 'Niederschlag',
            value: formatPrecipitation(data.precipitation, unitSettings),
          ),
          DetailRow(
            icon: Icons.air,
            label: 'Wind',
            value: formatWindSpeed(data.windSpeed, unitSettings),
          ),
          DetailRow(
            icon: Icons.storm_outlined,
            label: 'Böen',
            value: formatWindSpeed(data.windGusts, unitSettings),
          ),
          DetailRow(
            icon: Icons.speed_outlined,
            label: 'Luftdruck',
            value: '${data.pressure.toStringAsFixed(0)} hPa',
          ),
          DetailRow(
            icon: Icons.cloud_outlined,
            label: 'Bewölkung',
            value: '${data.cloudCover} %',
          ),
          DetailRow(
            icon: Icons.visibility_outlined,
            label: 'Sichtweite',
            value: formatVisibility(data.visibility, unitSettings),
          ),
          DetailRow(
            icon: Icons.wb_sunny_outlined,
            label: 'UV-Index',
            value: data.uvIndex.toStringAsFixed(1),
            accentValue: true,
          ),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool accentValue;

  const DetailRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.accentValue = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: orthaSurfaceElevated,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: orthaBorder.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: orthaSecondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: orthaSecondaryText),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: accentValue ? orthaAccent : orthaPrimaryText,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class CardBox extends StatelessWidget {
  final Widget child;

  const CardBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: orthaSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: orthaBorder.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}

class WarningLevelBar extends StatelessWidget {
  final RiskResult result;

  const WarningLevelBar({super.key, required this.result});

  int get activeLevel {
    if (result.score >= 85) return 4;
    if (result.score >= 70) return 3;
    if (result.score >= 40) return 2;
    if (result.score >= 15) return 1;
    return 0;
  }

  String get activeDescription {
    switch (activeLevel) {
      case 4:
        return 'Extreme Wetterbelastung';
      case 3:
        return 'Hohe Wetterbelastung';
      case 2:
        return 'Deutliche Wetterbelastung';
      case 1:
        return 'Erhöhte Aufmerksamkeit';
      case 0:
        return 'Geringe Wetterbelastung';
      default:
        return 'Wetterlage';
    }
  }

  @override
  Widget build(BuildContext context) {
    const levels = [
      (number: '0', label: 'Gering', color: Color(0xFF4F8A70)),
      (number: '1', label: 'Erhöht', color: Color(0xFFD1A928)),
      (number: '2', label: 'Deutlich', color: Color(0xFFD77B2E)),
      (number: '3', label: 'Hoch', color: Color(0xFFB94A48)),
      (number: '4', label: 'Extrem', color: Color(0xFF7E2634)),
    ];

    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: orthaAccent),
              SizedBox(width: 10),
              Text(
                'ORTHA Warnstufe',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Stufe $activeLevel · $activeDescription',
            style: const TextStyle(color: orthaSecondaryText),
          ),
          const SizedBox(height: 18),
          Row(
            children: List.generate(levels.length, (index) {
              final level = levels[index];
              final isActive = index == activeLevel;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < levels.length - 1 ? 7 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? level.color
                        : level.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? level.color
                          : level.color.withValues(alpha: 0.55),
                      width: isActive ? 2 : 1,
                    ),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: level.color.withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        level.number,
                        style: TextStyle(
                          color: isActive ? Colors.white : level.color,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        level.label,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive ? Colors.white : orthaSecondaryText,
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.analytics_outlined,
                size: 18,
                color: orthaSecondaryText,
              ),
              const SizedBox(width: 8),
              Text(
                'Interner Risikowert: ${result.score} / 100',
                style: const TextStyle(color: orthaSecondaryText, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RiskCategoriesCard extends StatelessWidget {
  final List<RiskCategoryResult> categories;

  const RiskCategoriesCard({super.key, required this.categories});

  Color colorForLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.green:
        return const Color(0xFF4F8A70);
      case RiskLevel.yellow:
        return const Color(0xFFD1A928);
      case RiskLevel.orange:
        return const Color(0xFFD77B2E);
      case RiskLevel.red:
        return const Color(0xFFB94A48);
    }
  }

  IconData iconForCategory(String name) {
    switch (name) {
      case 'Hitze':
        return Icons.thermostat_outlined;
      case 'UV':
        return Icons.wb_sunny_outlined;
      case 'Wind/Sturm':
        return Icons.air;
      case 'Niederschlag':
        return Icons.water_drop_outlined;
      case 'Sicht':
        return Icons.visibility_outlined;
      case 'Gewitter':
        return Icons.thunderstorm_outlined;
      default:
        return Icons.analytics_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.dashboard_customize_outlined, color: orthaAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Risikokategorien',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Einzelbewertung der wichtigsten Wetterrisiken',
            style: TextStyle(color: orthaSecondaryText, fontSize: 13),
          ),
          const SizedBox(height: 16),
          ...categories.map((category) {
            final color = colorForLevel(category.level);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: orthaSurfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: 0.38)),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Text(category.name),
                        content: Text(
                          'Warnstufe: ${riskLevelText(category.level)}\n\n'
                          'Aktuell: ${category.displayValue}\n'
                          'Prognose: ${category.forecastDisplayValue}\n\n'
                          'Begründung: ${category.message}\n\n'
                          'Empfehlung: ${recommendationForCategory(category)}',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(dialogContext),
                            child: const Text('Schließen'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(13),
                          border: Border.all(
                            color: color.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Icon(
                          iconForCategory(category.name),
                          color: color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    category.name,
                                    style: const TextStyle(
                                      color: orthaPrimaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${category.score} / 100',
                                  style: TextStyle(
                                    color: color,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: category.score / 100,
                              minHeight: 7,
                              borderRadius: BorderRadius.circular(8),
                              color: color,
                              backgroundColor: color.withValues(alpha: 0.14),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              category.message,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: orthaSecondaryText,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.chevron_right,
                        color: orthaSecondaryText,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String riskLevelText(RiskLevel level) {
  switch (level) {
    case RiskLevel.green:
      return 'Grün · geringe Belastung';
    case RiskLevel.yellow:
      return 'Gelb · erhöhte Aufmerksamkeit';
    case RiskLevel.orange:
      return 'Orange · erhöhte Belastung';
    case RiskLevel.red:
      return 'Rot · hohe Belastung';
  }
}

String recommendationForCategory(RiskCategoryResult category) {
  if (category.level == RiskLevel.green) {
    return 'Keine besonderen wetterbedingten Maßnahmen erforderlich.';
  }

  switch (category.name) {
    case 'Hitze':
      return 'Körperliche Belastung reduzieren, ausreichend trinken, Schatten aufsuchen und besonders belastende Aktivitäten anpassen.';

    case 'UV':
      return 'Direkte Sonne möglichst begrenzen, geeigneten Sonnenschutz verwenden und längere Aufenthalte im Freien anpassen.';

    case 'Wind/Sturm':
      return 'Lose Gegenstände sichern, exponierte Bereiche meiden und Wege sowie Aktivitäten an die Windlage anpassen.';

    case 'Niederschlag':
      return 'Rutschige Wege, mögliche Sichtbehinderungen und lokale Wasseransammlungen berücksichtigen.';

    case 'Sicht':
      return 'Geschwindigkeit und Wege anpassen, zusätzliche Zeit einplanen und im Straßenverkehr besonders aufmerksam sein.';

    case 'Gewitter':
      return 'Aufenthalte im Freien und exponierte Bereiche vermeiden, sichere Gebäude aufsuchen und die weitere Wetterentwicklung beobachten.';

    default:
      return 'Die Wetterentwicklung weiter beobachten und Aktivitäten bei Bedarf anpassen.';
  }
}
