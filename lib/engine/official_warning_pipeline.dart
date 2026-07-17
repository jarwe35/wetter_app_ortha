import '../models/official_weather_warning.dart';
import '../notifications/official_warning_alert_engine.dart';
import '../notifications/notification_request.dart';
import 'warning_intelligence_engine.dart';

class OfficialWarningPipeline {
  final WarningIntelligenceEngine intelligenceEngine;
  final OfficialWarningAlertEngine alertEngine;

  const OfficialWarningPipeline({
    this.intelligenceEngine = const WarningIntelligenceEngine(),
    this.alertEngine = const OfficialWarningAlertEngine(),
  });

  NotificationRequest? evaluate({
    required List<OfficialWeatherWarning> warnings,
    String? locationName,
  }) {
    final activeWarnings = warnings
        .where((warning) => warning.isActive)
        .toList();

    if (activeWarnings.isEmpty) {
      return null;
    }

    activeWarnings.sort(
      (a, b) => _severityRank(b.severity).compareTo(_severityRank(a.severity)),
    );

    final warning = activeWarnings.first;

    final intelligence = intelligenceEngine.analyze(warning);

    return alertEngine.evaluate(
      warning: warning,
      intelligence: intelligence,
      locationName: locationName,
    );
  }

  int _severityRank(OfficialWarningSeverity severity) {
    switch (severity) {
      case OfficialWarningSeverity.extreme:
        return 4;
      case OfficialWarningSeverity.severe:
        return 3;
      case OfficialWarningSeverity.moderate:
        return 2;
      case OfficialWarningSeverity.minor:
        return 1;
      case OfficialWarningSeverity.unknown:
        return 0;
    }
  }
}
