import 'package:flutter_tts/flutter_tts.dart';

import '../settings/nova_speech_settings.dart';
import '../settings/nova_speech_settings_store.dart';
import 'nova_speech_service.dart';
import 'nova_speech_voice.dart';

class FlutterNovaSpeechService implements NovaSpeechService {
  FlutterNovaSpeechService({
    FlutterTts? flutterTts,
    NovaSpeechSettingsStore? settingsStore,
    this.language = 'de-DE',
    this.speechRate = 0.48,
    this.volume = 1.0,
    this.pitch = 1.0,
  }) : _flutterTts = flutterTts ?? FlutterTts(),
       _settingsStore = settingsStore ?? NovaSpeechSettingsStore();

  final FlutterTts _flutterTts;
  final NovaSpeechSettingsStore _settingsStore;

  final String language;
  final double speechRate;
  final double volume;
  final double pitch;

  bool _initialized = false;
  NovaSpeechVoice? _selectedVoice;
  NovaSpeechSettings? _activeSettings;

  NovaSpeechSettings? get activeSettings => _activeSettings;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await applyStoredSettings();
  }

  Future<NovaSpeechSettings> applyStoredSettings() async {
    NovaSpeechSettings settings;

    try {
      settings = await _settingsStore.load();
    } catch (_) {
      settings = NovaSpeechSettings(
        language: language,
        speechRate: speechRate,
        pitch: pitch,
        volume: volume,
      );
    }

    await applySettings(settings);

    return settings;
  }

  Future<void> applySettings(NovaSpeechSettings settings) async {
    await _flutterTts.setLanguage(settings.language);
    await _flutterTts.setSpeechRate(settings.speechRate);
    await _flutterTts.setPitch(settings.pitch);
    await _flutterTts.setVolume(settings.volume);
    await _flutterTts.awaitSpeakCompletion(true);

    final selectedVoice = _selectedVoice;

    if (selectedVoice != null) {
      await _applyVoice(selectedVoice);
    }

    _activeSettings = settings;
    _initialized = true;
  }

  @override
  Future<List<NovaSpeechVoice>> getAvailableVoices() async {
    final dynamic rawVoices = await _flutterTts.getVoices;

    if (rawVoices is! List) {
      return const [];
    }

    final voices = <NovaSpeechVoice>[];

    for (final dynamic rawVoice in rawVoices) {
      if (rawVoice is! Map) {
        continue;
      }

      final dynamic rawName = rawVoice['name'];
      final dynamic rawLocale = rawVoice['locale'];

      if (rawName is! String || rawLocale is! String) {
        continue;
      }

      final name = rawName.trim();
      final locale = rawLocale.trim().replaceAll('_', '-');

      if (name.isEmpty || locale.isEmpty) {
        continue;
      }

      voices.add(NovaSpeechVoice(name: name, locale: locale));
    }

    final uniqueVoices = voices.toSet().toList()
      ..sort((a, b) {
        final localeComparison = a.locale.compareTo(b.locale);

        if (localeComparison != 0) {
          return localeComparison;
        }

        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    return uniqueVoices;
  }

  @override
  Future<void> selectVoice(NovaSpeechVoice? voice) async {
    _selectedVoice = voice;

    if (voice == null) {
      await _flutterTts.setLanguage(_activeSettings?.language ?? language);

      return;
    }

    await _applyVoice(voice);
  }

  Future<void> _applyVoice(NovaSpeechVoice voice) async {
    await _flutterTts.setLanguage(voice.locale);

    await _flutterTts.setVoice({'name': voice.name, 'locale': voice.locale});
  }

  @override
  Future<void> speak(String message) async {
    final normalizedMessage = message.trim();

    if (normalizedMessage.isEmpty) {
      return;
    }

    await applyStoredSettings();
    await _flutterTts.stop();
    await _flutterTts.speak(normalizedMessage);
  }

  Future<void> speakTestMessage() async {
    final settings = await applyStoredSettings();

    final message = settings.language.toLowerCase().startsWith('en')
        ? 'NOVA voice output is active. '
              'Your selected speech settings have been applied.'
        : 'NOVA Sprachausgabe ist aktiv. '
              'Die gewählten Spracheinstellungen wurden übernommen.';

    await _flutterTts.stop();
    await _flutterTts.speak(message);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
