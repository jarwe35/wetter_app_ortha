import 'package:flutter_test/flutter_test.dart';

import 'package:wetter_app_ortha/engine/warning_intelligence_engine.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/notifications/official_warning_alert_engine.dart';
import 'package:wetter_app_ortha/notifications/notification_level.dart';

void main() {
  const engine = OfficialWarningAlertEngine();

  OfficialWeatherWarning warning(OfficialWarningSeverity severity) {
    return OfficialWeatherWarning(
      id: 'test',
      title: 'Test Warnung',
      description: '',
      instruction: '',
      source: 'TEST',
      severity: severity,
      validFrom: DateTime(2026, 1, 1),
      validUntil: DateTime(2027, 1, 1),
    );
  }

  test('moderate warning creates warning notification', () {
    final intelligence = const WarningIntelligenceEngine().analyze(
      warning(OfficialWarningSeverity.moderate),
    );

    final result = engine.evaluate(
      warning: warning(OfficialWarningSeverity.moderate),
      intelligence: intelligence,
    );

    expect(result?.level, NotificationLevel.warning);
    expect(result?.playSound, true);
  });

  test('severe warning creates emergency notification', () {
    final intelligence = const WarningIntelligenceEngine().analyze(
      warning(OfficialWarningSeverity.severe),
    );

    final result = engine.evaluate(
      warning: warning(OfficialWarningSeverity.severe),
      intelligence: intelligence,
    );

    expect(result?.level, NotificationLevel.emergency);
    expect(result?.playSound, true);
  });

  test('extreme warning enables speech', () {
    final intelligence = const WarningIntelligenceEngine().analyze(
      warning(OfficialWarningSeverity.extreme),
    );

    final result = engine.evaluate(
      warning: warning(OfficialWarningSeverity.extreme),
      intelligence: intelligence,
    );

    expect(result?.speakMessage, true);
  });

  test('minor warning creates information notification', () {
    final intelligence = const WarningIntelligenceEngine().analyze(
      warning(OfficialWarningSeverity.minor),
    );

    final result = engine.evaluate(
      warning: warning(OfficialWarningSeverity.minor),
      intelligence: intelligence,
    );

    expect(result?.level, NotificationLevel.information);
  });
}
