import 'package:flutter_test/flutter_test.dart';

import 'package:wetter_app_ortha/engine/official_warning_pipeline.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/notifications/notification_level.dart';

void main() {
  const pipeline = OfficialWarningPipeline();

  OfficialWeatherWarning warning(
    OfficialWarningSeverity severity, {
    bool active = true,
  }) {
    return OfficialWeatherWarning(
      id: severity.name,
      title: 'Test Warnung',
      description: '',
      instruction: '',
      source: 'TEST',
      severity: severity,
      validFrom: active
          ? DateTime.now().subtract(const Duration(minutes: 5))
          : DateTime.now().subtract(const Duration(days: 2)),
      validUntil: active
          ? DateTime.now().add(const Duration(hours: 2))
          : DateTime.now().subtract(const Duration(hours: 1)),
    );
  }

  test('no warnings returns no notification', () {
    final result = pipeline.evaluate(warnings: []);

    expect(result, null);
  });

  test('extreme warning creates emergency notification', () {
    final result = pipeline.evaluate(
      warnings: [warning(OfficialWarningSeverity.extreme)],
    );

    expect(result?.level, NotificationLevel.emergency);
    expect(result?.speakMessage, true);
  });

  test('highest severity warning wins', () {
    final result = pipeline.evaluate(
      warnings: [
        warning(OfficialWarningSeverity.minor),
        warning(OfficialWarningSeverity.severe),
      ],
    );

    expect(result?.level, NotificationLevel.emergency);
  });

  test('expired warning is ignored', () {
    final result = pipeline.evaluate(
      warnings: [warning(OfficialWarningSeverity.extreme, active: false)],
    );

    expect(result, null);
  });
}
