import 'package:shared_preferences/shared_preferences.dart';

import 'nova_speech_settings.dart';

class NovaSpeechSettingsStore {
  NovaSpeechSettingsStore({
    Future<SharedPreferences> Function()? preferencesLoader,
  }) : _preferencesLoader = preferencesLoader ?? SharedPreferences.getInstance;

  static const String _languageKey = 'ortha.nova.speech.language';

  static const String _speechRateKey = 'ortha.nova.speech.rate';

  static const String _pitchKey = 'ortha.nova.speech.pitch';

  static const String _volumeKey = 'ortha.nova.speech.volume';

  static const String _repeatCriticalWarningsKey =
      'ortha.nova.speech.repeat_critical_warnings';

  static const String _announceWarningSourceKey =
      'ortha.nova.speech.announce_warning_source';

  static const String _announceLocationKey =
      'ortha.nova.speech.announce_location';

  final Future<SharedPreferences> Function() _preferencesLoader;

  Future<NovaSpeechSettings> load() async {
    final preferences = await _preferencesLoader();
    const defaults = NovaSpeechSettings.defaults;

    return NovaSpeechSettings(
      language: preferences.getString(_languageKey) ?? defaults.language,
      speechRate: _bounded(
        preferences.getDouble(_speechRateKey) ?? defaults.speechRate,
        minimum: 0.2,
        maximum: 0.8,
      ),
      pitch: _bounded(
        preferences.getDouble(_pitchKey) ?? defaults.pitch,
        minimum: 0.5,
        maximum: 2.0,
      ),
      volume: _bounded(
        preferences.getDouble(_volumeKey) ?? defaults.volume,
        minimum: 0.0,
        maximum: 1.0,
      ),
      repeatCriticalWarnings:
          preferences.getBool(_repeatCriticalWarningsKey) ??
          defaults.repeatCriticalWarnings,
      announceWarningSource:
          preferences.getBool(_announceWarningSourceKey) ??
          defaults.announceWarningSource,
      announceLocation:
          preferences.getBool(_announceLocationKey) ??
          defaults.announceLocation,
    );
  }

  Future<void> save(NovaSpeechSettings settings) async {
    final preferences = await _preferencesLoader();

    await Future.wait<void>([
      preferences.setString(_languageKey, settings.language),
      preferences.setDouble(_speechRateKey, settings.speechRate),
      preferences.setDouble(_pitchKey, settings.pitch),
      preferences.setDouble(_volumeKey, settings.volume),
      preferences.setBool(
        _repeatCriticalWarningsKey,
        settings.repeatCriticalWarnings,
      ),
      preferences.setBool(
        _announceWarningSourceKey,
        settings.announceWarningSource,
      ),
      preferences.setBool(_announceLocationKey, settings.announceLocation),
    ]);
  }

  Future<void> reset() async {
    await save(NovaSpeechSettings.defaults);
  }

  static double _bounded(
    double value, {
    required double minimum,
    required double maximum,
  }) {
    return value.clamp(minimum, maximum).toDouble();
  }
}
