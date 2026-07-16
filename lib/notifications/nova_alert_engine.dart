import '../engine/recommendation_engine.dart';
import '../engine/risk_engine.dart';
import 'notification_level.dart';
import 'notification_request.dart';

class NovaAlertEngine {
  const NovaAlertEngine();

  NotificationRequest? evaluate({
    required RiskResult risk,
    Recommendation? recommendation,
    String? locationName,
  }) {
    if (risk.level == RiskLevel.green) {
      return null;
    }

    final normalizedLocation = locationName?.trim();
    final locationSuffix =
        normalizedLocation == null || normalizedLocation.isEmpty
        ? ''
        : ' für $normalizedLocation';

    final recommendationText = recommendation?.description.trim();

    final message = recommendationText != null && recommendationText.isNotEmpty
        ? recommendationText
        : risk.message;

    switch (risk.level) {
      case RiskLevel.green:
        return null;

      case RiskLevel.yellow:
        return NotificationRequest(
          level: NotificationLevel.information,
          title: 'NOVA Wetterhinweis$locationSuffix',
          message: message,
        );

      case RiskLevel.orange:
        return NotificationRequest(
          level: NotificationLevel.warning,
          title: 'NOVA Wetterwarnung$locationSuffix',
          message: message,
          playSound: true,
        );

      case RiskLevel.red:
        return NotificationRequest(
          level: NotificationLevel.emergency,
          title: 'NOVA Akutwarnung$locationSuffix',
          message: message,
          playSound: true,
          speakMessage: true,
        );
    }
  }
}
