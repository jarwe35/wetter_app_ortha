import '../engine/warning_intelligence_engine.dart';
import '../models/official_weather_warning.dart';
import 'notification_level.dart';
import 'notification_request.dart';

class OfficialWarningAlertEngine {
  const OfficialWarningAlertEngine();

  NotificationRequest? evaluate({
    required OfficialWeatherWarning warning,
    required WarningIntelligenceResult intelligence,
    String? locationName,
  }) {
    if (intelligence.level == OrthaWarningLevel.none) {
      return null;
    }

    final normalizedLocation = locationName?.trim();

    final locationSuffix =
        normalizedLocation == null || normalizedLocation.isEmpty
        ? ''
        : ' für $normalizedLocation';

    switch (intelligence.level) {
      case OrthaWarningLevel.yellow:
        return NotificationRequest(
          level: NotificationLevel.information,
          title: 'NOVA Wetterhinweis$locationSuffix',
          message: intelligence.recommendation,
        );

      case OrthaWarningLevel.orange:
        return NotificationRequest(
          level: NotificationLevel.warning,
          title: 'NOVA Wetterwarnung$locationSuffix',
          message: intelligence.recommendation,
          playSound: true,
        );

      case OrthaWarningLevel.red:
        return NotificationRequest(
          level: NotificationLevel.emergency,
          title: 'NOVA Akutwarnung$locationSuffix',
          message: intelligence.recommendation,
          playSound: true,
        );

      case OrthaWarningLevel.darkRed:
        return NotificationRequest(
          level: NotificationLevel.emergency,
          title: 'NOVA Extremwarnung$locationSuffix',
          message: intelligence.recommendation,
          playSound: true,
          speakMessage: true,
        );

      case OrthaWarningLevel.none:
        return null;
    }
  }
}
