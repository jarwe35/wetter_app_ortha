import 'package:shared_preferences/shared_preferences.dart';

import 'unit_settings.dart';

class UnitSettingsService {
  static const _temperatureKey = 'unit_temperature';
  static const _windKey = 'unit_wind';
  static const _visibilityKey = 'unit_visibility';
  static const _precipitationKey = 'unit_precipitation';

  Future<UnitSettings> load() async {
    final preferences = await SharedPreferences.getInstance();

    return UnitSettings.fromMap({
      'temperatureUnit':
          preferences.getString(_temperatureKey) ??
          TemperatureUnit.celsius.name,
      'windSpeedUnit':
          preferences.getString(_windKey) ??
          WindSpeedUnit.kilometersPerHour.name,
      'visibilityUnit':
          preferences.getString(_visibilityKey) ??
          VisibilityUnit.kilometers.name,
      'precipitationUnit':
          preferences.getString(_precipitationKey) ??
          PrecipitationUnit.millimeters.name,
    });
  }

  Future<void> save(UnitSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    final values = settings.toMap();

    await Future.wait([
      preferences.setString(_temperatureKey, values['temperatureUnit']!),
      preferences.setString(_windKey, values['windSpeedUnit']!),
      preferences.setString(_visibilityKey, values['visibilityUnit']!),
      preferences.setString(_precipitationKey, values['precipitationUnit']!),
    ]);
  }
}
