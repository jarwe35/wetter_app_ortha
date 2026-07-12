import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_location.dart';

class LocationStorageService {
  static const String _locationsKey = 'ortha_saved_locations';
  static const String _selectedLocationKey = 'ortha_selected_location';

  static const String _structuredLocationsKey =
      'ortha_saved_locations_structured_v1';

  static const String _selectedStructuredLocationKey =
      'ortha_selected_location_structured_v1';

  Future<List<String>> loadLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final locations = prefs.getStringList(_locationsKey);

    if (locations == null || locations.isEmpty) {
      return ['Duisburg'];
    }

    return locations;
  }

  Future<void> saveLocations(List<String> locations) async {
    final prefs = await SharedPreferences.getInstance();

    final cleaned = locations
        .map((location) => location.trim())
        .where((location) => location.isNotEmpty)
        .toSet()
        .toList();

    await prefs.setStringList(_locationsKey, cleaned);
  }

  Future<String> loadSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_selectedLocationKey) ?? 'Duisburg';
  }

  Future<void> saveSelectedLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_selectedLocationKey, location.trim());
  }

  Future<List<SavedLocation>> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLocations = prefs.getStringList(_structuredLocationsKey);

    if (storedLocations == null || storedLocations.isEmpty) {
      return [];
    }

    final locations = <SavedLocation>[];

    for (final encodedLocation in storedLocations) {
      try {
        final decoded = jsonDecode(encodedLocation);

        if (decoded is! Map<String, dynamic>) {
          continue;
        }

        locations.add(SavedLocation.fromJson(decoded));
      } catch (_) {
        continue;
      }
    }

    return locations;
  }

  Future<void> saveSavedLocations(List<SavedLocation> locations) async {
    final prefs = await SharedPreferences.getInstance();

    final uniqueLocations = <SavedLocation>[];

    for (final location in locations) {
      final alreadyStored = uniqueLocations.any(
        (storedLocation) =>
            storedLocation.name.toLowerCase() == location.name.toLowerCase() ||
            storedLocation.hasSameCoordinatesAs(location),
      );

      if (!alreadyStored) {
        uniqueLocations.add(location);
      }
    }

    final encodedLocations = uniqueLocations
        .map((location) => jsonEncode(location.toJson()))
        .toList();

    await prefs.setStringList(_structuredLocationsKey, encodedLocations);
  }

  Future<String?> loadSelectedSavedLocationName() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString(_selectedStructuredLocationKey);
  }

  Future<void> saveSelectedSavedLocationName(String locationName) async {
    final prefs = await SharedPreferences.getInstance();

    final cleanedName = locationName.trim();

    if (cleanedName.isEmpty) {
      return;
    }

    await prefs.setString(_selectedStructuredLocationKey, cleanedName);
  }

  Future<void> clearStructuredLocations() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_structuredLocationsKey);
    await prefs.remove(_selectedStructuredLocationKey);
  }
}
