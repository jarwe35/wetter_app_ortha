abstract interface class NovaSpeechService {
  Future<void> initialize();

  Future<void> speak(String message);

  Future<void> stop();
}
