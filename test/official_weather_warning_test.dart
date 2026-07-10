import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';

void main() {
  group('OfficialWeatherWarning', () {
    test('aktuelle Warnung ist aktiv', () {
      final now = DateTime.now();

      final warning = OfficialWeatherWarning(
        id: 'warning-active',
        title: 'Aktive Warnung',
        description: 'Testwarnung',
        instruction: 'Vorsicht',
        source: 'Testquelle',
        severity: OfficialWarningSeverity.moderate,
        validFrom: now.subtract(const Duration(hours: 1)),
        validUntil: now.add(const Duration(hours: 1)),
      );

      expect(warning.isActive, isTrue);
    });

    test('zukünftige Warnung ist noch nicht aktiv', () {
      final now = DateTime.now();

      final warning = OfficialWeatherWarning(
        id: 'warning-future',
        title: 'Zukünftige Warnung',
        description: 'Testwarnung',
        instruction: 'Beobachten',
        source: 'Testquelle',
        severity: OfficialWarningSeverity.severe,
        validFrom: now.add(const Duration(hours: 1)),
        validUntil: now.add(const Duration(hours: 2)),
      );

      expect(warning.isActive, isFalse);
    });

    test('abgelaufene Warnung ist nicht aktiv', () {
      final now = DateTime.now();

      final warning = OfficialWeatherWarning(
        id: 'warning-expired',
        title: 'Abgelaufene Warnung',
        description: 'Testwarnung',
        instruction: 'Keine Maßnahme',
        source: 'Testquelle',
        severity: OfficialWarningSeverity.minor,
        validFrom: now.subtract(const Duration(hours: 2)),
        validUntil: now.subtract(const Duration(hours: 1)),
      );

      expect(warning.isActive, isFalse);
      expect(warning.remainingDuration, Duration.zero);
    });

    test('aktive Warnung besitzt positive Restlaufzeit', () {
      final now = DateTime.now();

      final warning = OfficialWeatherWarning(
        id: 'warning-duration',
        title: 'Warnung mit Restlaufzeit',
        description: 'Testwarnung',
        instruction: 'Vorsicht',
        source: 'Testquelle',
        severity: OfficialWarningSeverity.extreme,
        validFrom: now.subtract(const Duration(minutes: 30)),
        validUntil: now.add(const Duration(hours: 2)),
      );

      expect(warning.remainingDuration, greaterThan(Duration.zero));
      expect(
        warning.remainingDuration,
        lessThanOrEqualTo(const Duration(hours: 2)),
      );
    });
  });
}
