import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_notification_gateway.dart';
import 'package:wetter_app_ortha/notifications/notification_level.dart';
import 'package:wetter_app_ortha/notifications/notification_request.dart';

void main() {
  test(
    'überspringt lokale Benachrichtigungen auf nicht unterstützten Plattformen',
    () async {
      final gateway = LocalNovaNotificationGateway(
        notificationsSupported: false,
      );

      const request = NotificationRequest(
        level: NotificationLevel.warning,
        title: 'NOVA Wetterwarnung',
        message: 'Starke Windböen möglich.',
        playSound: true,
      );

      await gateway.initialize();
      await gateway.show(request);
    },
  );
}
