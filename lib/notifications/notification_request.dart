import 'notification_level.dart';

class NotificationRequest {
  final NotificationLevel level;
  final String title;
  final String message;
  final bool playSound;
  final bool speakMessage;

  const NotificationRequest({
    required this.level,
    required this.title,
    required this.message,
    this.playSound = false,
    this.speakMessage = false,
  });
}
