import '../engine/risk_engine.dart';
import '../models/official_weather_warning.dart';
import '../models/ortha_status_model.dart';

class OrthaStatusBuilder {
  const OrthaStatusBuilder();

  OrthaStatusModel build({
    required RiskResult risk,
    required List<OfficialWeatherWarning> warnings,
  }) {
    final warningActive = warnings.any((warning) => warning.isActive);

    switch (risk.level) {
      case RiskLevel.red:
        return OrthaStatusModel(
          level: OrthaStatusLevel.red,
          title: 'Akute Wettergefahr',
          statusText: 'Handlung empfohlen',
          riskText: risk.message,
          warningText: warningActive
              ? 'Amtliche Warnung aktiv'
              : 'Keine amtliche Warnung',
        );

      case RiskLevel.orange:
        return OrthaStatusModel(
          level: OrthaStatusLevel.orange,
          title: 'Erhöhte Wetterlage',
          statusText: 'Aufmerksamkeit empfohlen',
          riskText: risk.message,
          warningText: warningActive
              ? 'Amtliche Warnung aktiv'
              : 'Keine amtliche Warnung',
        );

      case RiskLevel.yellow:
        return OrthaStatusModel(
          level: OrthaStatusLevel.yellow,
          title: 'Veränderte Wetterlage',
          statusText: 'Beobachtung empfohlen',
          riskText: risk.message,
          warningText: warningActive
              ? 'Amtliche Warnung aktiv'
              : 'Keine amtliche Warnung',
        );

      case RiskLevel.green:
        return OrthaStatusModel(
          level: OrthaStatusLevel.green,
          title: 'Lage stabil',
          statusText: 'Keine besonderen Maßnahmen nötig',
          riskText: risk.message,
          warningText: warningActive
              ? 'Amtliche Warnung aktiv'
              : 'Keine amtliche Warnung',
        );
    }
  }
}
