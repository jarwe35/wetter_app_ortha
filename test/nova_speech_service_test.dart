import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_speech_service.dart';

class RecordingNovaSpeechService implements NovaSpeechService {
  int initializeCalls = 0;
  int speakCalls = 0;
  int stopCalls = 0;

  String? lastMessage;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<void> speak(String message) async {
    speakCalls++;
    lastMessage = message;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

void main() {
  test('NovaSpeechService kann initialisiert werden', () async {
    final service = RecordingNovaSpeechService();

    await service.initialize();

    expect(service.initializeCalls, 1);
  });

  test('NovaSpeechService übernimmt einen Warntext', () async {
    final service = RecordingNovaSpeechService();

    await service.speak('Schwere Unwettergefahr.');

    expect(service.speakCalls, 1);
    expect(service.lastMessage, 'Schwere Unwettergefahr.');
  });

  test('NovaSpeechService kann laufende Sprachausgabe stoppen', () async {
    final service = RecordingNovaSpeechService();

    await service.stop();

    expect(service.stopCalls, 1);
  });
}
