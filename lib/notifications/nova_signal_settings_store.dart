import 'package:shared_preferences/shared_preferences.dart';

import 'nova_signal_level.dart';
import 'nova_signal_settings.dart';

class NovaSignalSettingsStore {
  static const _soundKey = 'nova_signal_sound_enabled';
  static const _vibrationKey = 'nova_signal_vibration_enabled';
  static const _speechKey = 'nova_signal_speech_enabled';
  static const _levelKey = 'nova_signal_minimum_level';

  const NovaSignalSettingsStore();

  Future<NovaSignalSettings> load() async {
    final preferences = await SharedPreferences.getInstance();

    final soundEnabled = preferences.getBool(_soundKey) ?? true;

    final vibrationEnabled = preferences.getBool(_vibrationKey) ?? true;

    final speechEnabled = preferences.getBool(_speechKey) ?? false;

    final levelIndex =
        preferences.getInt(_levelKey) ?? NovaSignalLevel.warning.index;

    final safeIndex = levelIndex.clamp(0, NovaSignalLevel.values.length - 1);

    return NovaSignalSettings(
      soundEnabled: soundEnabled,
      vibrationEnabled: vibrationEnabled,
      speechEnabled: speechEnabled,
      minimumLevel: NovaSignalLevel.values[safeIndex],
    );
  }

  Future<void> save(NovaSignalSettings settings) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_soundKey, settings.soundEnabled);

    await preferences.setBool(_vibrationKey, settings.vibrationEnabled);

    await preferences.setBool(_speechKey, settings.speechEnabled);

    await preferences.setInt(_levelKey, settings.minimumLevel.index);
  }

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.remove(_soundKey);
    await preferences.remove(_vibrationKey);
    await preferences.remove(_speechKey);
    await preferences.remove(_levelKey);
  }
}
