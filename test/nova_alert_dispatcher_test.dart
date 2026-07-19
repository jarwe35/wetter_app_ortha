import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_alert_dispatcher.dart';
import 'package:wetter_app_ortha/notifications/nova_notification_gateway.dart';
import 'package:wetter_app_ortha/notifications/notification_level.dart';
import 'package:wetter_app_ortha/notifications/notification_request.dart';
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

class RecordingNotificationGateway implements NovaNotificationGateway {
  int initializeCalls = 0;
  int showCalls = 0;
  NotificationRequest? lastRequest;

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<void> show(NotificationRequest request) async {
    showCalls++;
    lastRequest = request;
  }
}

void main() {
  test('ignoriert einen fehlenden NotificationRequest', () async {
    final gateway = RecordingNotificationGateway();
    final dispatcher = NovaAlertDispatcher(notificationGateway: gateway);

    final dispatched = await dispatcher.dispatch(null);

    expect(dispatched, isFalse);
    expect(gateway.showCalls, 0);
    expect(gateway.lastRequest, isNull);
  });

  test('übergibt vorhandenen Request an das Notification-Gateway', () async {
    final gateway = RecordingNotificationGateway();
    final dispatcher = NovaAlertDispatcher(notificationGateway: gateway);

    const request = NotificationRequest(
      level: NotificationLevel.warning,
      title: 'NOVA Wetterwarnung für Duisburg',
      message: 'Starke Windböen möglich.',
      playSound: true,
    );

    final dispatched = await dispatcher.dispatch(request);

    expect(dispatched, isTrue);
    expect(gateway.showCalls, 1);
    expect(gateway.lastRequest, same(request));
  });

  test('übergibt auch eine Notfallwarnung unverändert', () async {
    final gateway = RecordingNotificationGateway();
    final dispatcher = NovaAlertDispatcher(notificationGateway: gateway);

    const request = NotificationRequest(
      level: NotificationLevel.emergency,
      title: 'NOVA Akutwarnung',
      message: 'Schwere Unwettergefahr.',
      playSound: true,
      speakMessage: true,
    );

    await dispatcher.dispatch(request);

    expect(gateway.lastRequest?.level, NotificationLevel.emergency);
    expect(gateway.lastRequest?.playSound, isTrue);
    expect(gateway.lastRequest?.speakMessage, isTrue);
  });

  test('liest eine ausdrücklich angeforderte Warnung vor', () async {
    final gateway = RecordingNotificationGateway();
    final speechService = RecordingNovaSpeechService();

    final dispatcher = NovaAlertDispatcher(
      notificationGateway: gateway,
      speechService: speechService,
    );

    const request = NotificationRequest(
      level: NotificationLevel.emergency,
      title: 'NOVA Akutwarnung',
      message: 'Schwere Unwettergefahr.',
      speakMessage: true,
    );

    await dispatcher.dispatch(request);

    expect(speechService.speakCalls, 1);
    expect(speechService.lastMessage, 'Schwere Unwettergefahr.');
  });

  test('liest eine Warnung ohne Sprachfreigabe nicht vor', () async {
    final gateway = RecordingNotificationGateway();
    final speechService = RecordingNovaSpeechService();

    final dispatcher = NovaAlertDispatcher(
      notificationGateway: gateway,
      speechService: speechService,
    );

    const request = NotificationRequest(
      level: NotificationLevel.warning,
      title: 'NOVA Wetterwarnung',
      message: 'Starke Windböen möglich.',
      speakMessage: false,
    );

    await dispatcher.dispatch(request);

    expect(speechService.speakCalls, 0);
    expect(speechService.lastMessage, isNull);
  });
}
