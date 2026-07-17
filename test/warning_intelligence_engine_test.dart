import 'package:flutter_test/flutter_test.dart';

import 'package:wetter_app_ortha/engine/warning_intelligence_engine.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';

void main() {
  const engine = WarningIntelligenceEngine();

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

  test('extreme warning becomes dark red and spoken alert', () {
    final result = engine.analyze(warning(OfficialWarningSeverity.extreme));

    expect(result.level, OrthaWarningLevel.darkRed);
    expect(result.shouldNotify, true);
    expect(result.shouldSpeak, true);
  });

  test('severe warning becomes red', () {
    final result = engine.analyze(warning(OfficialWarningSeverity.severe));

    expect(result.level, OrthaWarningLevel.red);
  });

  test('moderate warning becomes orange', () {
    final result = engine.analyze(warning(OfficialWarningSeverity.moderate));

    expect(result.level, OrthaWarningLevel.orange);
  });

  test('minor warning becomes yellow', () {
    final result = engine.analyze(warning(OfficialWarningSeverity.minor));

    expect(result.level, OrthaWarningLevel.yellow);
    expect(result.shouldNotify, false);
  });

  test('unknown warning falls back to yellow', () {
    final result = engine.analyze(warning(OfficialWarningSeverity.unknown));

    expect(result.level, OrthaWarningLevel.yellow);
  });
}
