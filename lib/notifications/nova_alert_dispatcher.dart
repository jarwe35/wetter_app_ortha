import 'nova_notification_gateway.dart';
import 'notification_request.dart';

class NovaAlertDispatcher {
  final NovaNotificationGateway notificationGateway;

  const NovaAlertDispatcher({required this.notificationGateway});

  Future<bool> dispatch(NotificationRequest? request) async {
    if (request == null) {
      return false;
    }

    await notificationGateway.show(request);

    return true;
  }
}
