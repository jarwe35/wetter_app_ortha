import 'package:flutter_tts/flutter_tts.dart';

import 'nova_speech_service.dart';
import 'nova_speech_voice.dart';

class FlutterNovaSpeechService implements NovaSpeechService {
  FlutterNovaSpeechService({
    FlutterTts? flutterTts,
    this.language = 'de-DE',
    this.speechRate = 0.48,
    this.volume = 1.0,
    this.pitch = 1.00,
  }) : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  final String language;
  final double speechRate;
  final double volume;
  final double pitch;

  bool _initialized = false;
  NovaSpeechVoice? _selectedVoice;

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setVolume(volume);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.awaitSpeakCompletion(true);

    final selectedVoice = _selectedVoice;

    if (selectedVoice != null) {
      await _applyVoice(selectedVoice);
    }

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

      if (!locale.toLowerCase().startsWith('de')) {
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
      await _flutterTts.setLanguage(language);
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

    await initialize();
    await _flutterTts.stop();
    await _flutterTts.speak(normalizedMessage);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}
