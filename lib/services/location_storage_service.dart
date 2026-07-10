import 'package:shared_preferences/shared_preferences.dart';

class LocationStorageService {
  static const String _locationsKey = 'ortha_saved_locations';
  static const String _selectedLocationKey = 'ortha_selected_location';

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
}
