import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'notification_level.dart';
import 'notification_request.dart';

abstract class NovaNotificationGateway {
  Future<void> initialize();

  Future<void> show(NotificationRequest request);
}

class LocalNovaNotificationGateway implements NovaNotificationGateway {
  static const String _channelId = 'ortha_meteo_alerts';
  static const String _channelName = 'ORTHA METEO Warnungen';
  static const String _channelDescription =
      'Wetter- und Gefahrenwarnungen der NOVA Alert Engine';

  final FlutterLocalNotificationsPlugin _plugin;

  bool _initialized = false;
  int _nextNotificationId = 1000;

  LocalNovaNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  @override
  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
      macOS: DarwinInitializationSettings(),
      linux: LinuxInitializationSettings(
        defaultActionName: 'ORTHA METEO öffnen',
      ),
    );

    await _plugin.initialize(settings: initializationSettings);

    _initialized = true;
  }

  @override
  Future<void> show(NotificationRequest request) async {
    await initialize();

    final notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: _androidImportance(request.level),
        priority: _androidPriority(request.level),
        playSound: request.playSound,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: request.playSound,
      ),
      macOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: false,
        presentSound: request.playSound,
      ),
      linux: const LinuxNotificationDetails(),
    );

    await _plugin.show(
      id: _nextNotificationId++,
      title: request.title,
      body: request.message,
      notificationDetails: notificationDetails,
    );
  }

  Importance _androidImportance(NotificationLevel level) {
    switch (level) {
      case NotificationLevel.none:
        return Importance.min;
      case NotificationLevel.information:
        return Importance.defaultImportance;
      case NotificationLevel.warning:
        return Importance.high;
      case NotificationLevel.emergency:
        return Importance.max;
    }
  }

  Priority _androidPriority(NotificationLevel level) {
    switch (level) {
      case NotificationLevel.none:
        return Priority.min;
      case NotificationLevel.information:
        return Priority.defaultPriority;
      case NotificationLevel.warning:
        return Priority.high;
      case NotificationLevel.emergency:
        return Priority.max;
    }
  }
}
