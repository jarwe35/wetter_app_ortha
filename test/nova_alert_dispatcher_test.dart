import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_alert_dispatcher.dart';
import 'package:wetter_app_ortha/notifications/nova_notification_gateway.dart';
import 'package:wetter_app_ortha/notifications/notification_level.dart';
import 'package:wetter_app_ortha/notifications/notification_request.dart';

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
}
