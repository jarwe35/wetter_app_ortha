import '../engine/risk_engine.dart';
import '../models/official_weather_warning.dart';
import '../models/ortha_status_model.dart';

class OrthaStatusBuilder {
  const OrthaStatusBuilder();

  OrthaStatusModel build({
    required RiskResult risk,
    required List<OfficialWeatherWarning> warnings,
    required String location,
  }) {
    final warningActive = warnings.any((warning) => warning.isActive);

    final warningText = warningActive
        ? 'Amtliche Warnung aktiv'
        : 'Keine amtliche Warnung';

    switch (risk.level) {
      case RiskLevel.red:
        return OrthaStatusModel(
          level: OrthaStatusLevel.red,
          title: 'Akute Wettergefahr',
          statusText: 'Handlung empfohlen',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation:
              'Sicherheitsmaßnahmen prüfen und Warnhinweise beachten.',
          timestamp: DateTime.now(),
        );

      case RiskLevel.orange:
        return OrthaStatusModel(
          level: OrthaStatusLevel.orange,
          title: 'Erhöhte Wetterlage',
          statusText: 'Aufmerksamkeit empfohlen',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation:
              'Aktuelle Entwicklung beobachten und Aktivitäten anpassen.',
          timestamp: DateTime.now(),
        );

      case RiskLevel.yellow:
        return OrthaStatusModel(
          level: OrthaStatusLevel.yellow,
          title: 'Veränderte Wetterlage',
          statusText: 'Beobachtung empfohlen',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation:
              'Wetterentwicklung verfolgen und vorbereitet bleiben.',
          timestamp: DateTime.now(),
        );

      case RiskLevel.green:
        return OrthaStatusModel(
          level: OrthaStatusLevel.green,
          title: 'Lage stabil',
          statusText: 'Keine besonderen Maßnahmen nötig',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation: 'Keine besonderen Maßnahmen erforderlich.',
          timestamp: DateTime.now(),
        );
    }
  }
}
