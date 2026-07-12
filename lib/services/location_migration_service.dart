import '../models/saved_location.dart';
import 'location_service.dart';
import 'location_storage_service.dart';

class LocationMigrationResult {
  final List<SavedLocation> locations;
  final List<String> unresolvedLocationNames;

  const LocationMigrationResult({
    required this.locations,
    required this.unresolvedLocationNames,
  });

  bool get isComplete => unresolvedLocationNames.isEmpty;
}

class LocationMigrationService {
  final LocationStorageService storageService;
  final LocationService locationService;

  const LocationMigrationService({
    required this.storageService,
    required this.locationService,
  });

  Future<LocationMigrationResult> migrateLegacyLocations() async {
    final legacyLocationNames = await storageService.loadLocations();
    final existingLocations = await storageService.loadSavedLocations();

    final migratedLocations = List<SavedLocation>.from(existingLocations);
    final unresolvedLocationNames = <String>[];

    for (final rawLocationName in legacyLocationNames) {
      final locationName = rawLocationName.trim();

      if (locationName.isEmpty) {
        continue;
      }

      final alreadyMigrated = migratedLocations.any(
        (location) => location.name.toLowerCase() == locationName.toLowerCase(),
      );

      if (alreadyMigrated) {
        continue;
      }

      try {
        final resolvedLocation = await locationService.resolveLocation(
          locationName,
        );

        final duplicateLocation = migratedLocations.any(
          (location) =>
              location.name.toLowerCase() ==
                  resolvedLocation.name.toLowerCase() ||
              location.hasSameCoordinatesAs(resolvedLocation),
        );

        if (!duplicateLocation) {
          migratedLocations.add(resolvedLocation);
        }
      } on LocationServiceException {
        unresolvedLocationNames.add(locationName);
      }
    }

    await storageService.saveSavedLocations(migratedLocations);

    final legacySelectedLocation = await storageService.loadSelectedLocation();

    final selectedLocationExists = migratedLocations.any(
      (location) =>
          location.name.toLowerCase() ==
          legacySelectedLocation.trim().toLowerCase(),
    );

    if (selectedLocationExists) {
      await storageService.saveSelectedSavedLocationName(
        legacySelectedLocation,
      );
    }

    return LocationMigrationResult(
      locations: List<SavedLocation>.unmodifiable(migratedLocations),
      unresolvedLocationNames: List<String>.unmodifiable(
        unresolvedLocationNames,
      ),
    );
  }
}
