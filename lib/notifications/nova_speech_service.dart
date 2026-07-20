import 'nova_speech_voice.dart';

abstract interface class NovaSpeechService {
  Future<void> initialize();

  Future<List<NovaSpeechVoice>> getAvailableVoices();

  Future<void> selectVoice(NovaSpeechVoice? voice);

  Future<void> speak(String message);

  Future<void> stop();
}
