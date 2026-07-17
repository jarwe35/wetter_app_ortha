import 'nova_notification_gateway.dart';
import 'notification_request.dart';
import 'notification_level.dart';
import 'nova_signal_service.dart';
import 'nova_signal_level.dart';
import 'nova_signal_coordinator.dart';

class NovaAlertDispatcher {
  final NovaNotificationGateway notificationGateway;
  final NovaSignalService signalService;
  final NovaSignalCoordinator? coordinator;

  const NovaAlertDispatcher({
    required this.notificationGateway,
    this.signalService = const NovaSignalService(),
    this.coordinator,
  });

  Future<bool> dispatch(NotificationRequest? request) async {
    if (request == null) {
      return false;
    }

    final signalLevel = _mapLevel(request.level);

    bool shouldPlaySound;
    bool shouldSpeak;

    if (coordinator != null) {
      final decision = await coordinator!.evaluate(signalLevel);

      shouldPlaySound = request.playSound || decision.sound;
      shouldSpeak = request.speakMessage || decision.speak;
    } else {
      final decision = signalService.evaluate(signalLevel);

      shouldPlaySound = request.playSound || decision.policy.sound;
      shouldSpeak = request.speakMessage;
    }

    final requestToSend =
        shouldPlaySound == request.playSound &&
            shouldSpeak == request.speakMessage
        ? request
        : NotificationRequest(
            level: request.level,
            title: request.title,
            message: request.message,
            playSound: shouldPlaySound,
            speakMessage: shouldSpeak,
          );

    await notificationGateway.show(requestToSend);

    return true;
  }

  NovaSignalLevel _mapLevel(NotificationLevel level) {
    switch (level) {
      case NotificationLevel.none:
        return NovaSignalLevel.none;

      case NotificationLevel.information:
        return NovaSignalLevel.information;

      case NotificationLevel.warning:
        return NovaSignalLevel.warning;

      case NotificationLevel.emergency:
        return NovaSignalLevel.emergency;
    }
  }
}
