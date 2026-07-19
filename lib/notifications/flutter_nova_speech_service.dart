import 'package:flutter_tts/flutter_tts.dart';

import 'nova_speech_service.dart';

class FlutterNovaSpeechService implements NovaSpeechService {
  FlutterNovaSpeechService({
    FlutterTts? flutterTts,
    this.language = 'de-DE',
    this.speechRate = 0.525,
    this.volume = 1.0,
    this.pitch = 1.0,
  }) : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  final String language;
  final double speechRate;
  final double volume;
  final double pitch;

  bool _initialized = false;

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

    _initialized = true;
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
