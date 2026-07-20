import 'package:shared_preferences/shared_preferences.dart';

class LocationStartupPreferenceService {
  static const String _useCurrentLocationKey =
      'use_current_location_at_startup';

  const LocationStartupPreferenceService();

  Future<bool?> loadUseCurrentLocationAtStartup() async {
    final preferences = await SharedPreferences.getInstance();

    if (!preferences.containsKey(_useCurrentLocationKey)) {
      return null;
    }

    return preferences.getBool(_useCurrentLocationKey);
  }

  Future<void> saveUseCurrentLocationAtStartup(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_useCurrentLocationKey, enabled);
  }

  Future<void> clearUseCurrentLocationAtStartup() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_useCurrentLocationKey);
  }
}
