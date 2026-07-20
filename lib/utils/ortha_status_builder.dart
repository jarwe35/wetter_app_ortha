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

    final warningText = warningActive ? 'Aktiv' : 'Keine';

    switch (risk.level) {
      case RiskLevel.red:
        return OrthaStatusModel(
          level: OrthaStatusLevel.red,
          title: 'Aktuelle Lage',
          statusText: 'Akute Warnlage',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation:
              'Es besteht eine ernst zu nehmende Wetterlage. '
              'Amtliche Warnhinweise beachten und geeignete '
              'Sicherheitsmaßnahmen ergreifen.',
          timestamp: DateTime.now(),
        );

      case RiskLevel.orange:
        return OrthaStatusModel(
          level: OrthaStatusLevel.orange,
          title: 'Aktuelle Lage',
          statusText: warningActive
              ? 'Amtliche Warnlage'
              : 'Erhöhte Wetterlage',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation:
              'Die Wetterlage weist deutliche Auffälligkeiten auf. '
              'Die weitere Entwicklung sollte aufmerksam verfolgt werden.',
          timestamp: DateTime.now(),
        );

      case RiskLevel.yellow:
        return OrthaStatusModel(
          level: OrthaStatusLevel.yellow,
          title: 'Aktuelle Lage',
          statusText: warningActive
              ? 'Amtliche Warnlage'
              : 'Normale Wetterlage',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation: warningActive
              ? 'Es liegt mindestens eine amtliche Warnung vor. '
                    'Die zugehörigen Hinweise sollten beachtet werden.'
              : 'Zurzeit liegen keine amtlichen Wetterwarnungen vor. '
                    'ORTHA erkennt einzelne Wetterfaktoren und überwacht '
                    'deren weitere Entwicklung.',
          timestamp: DateTime.now(),
        );

      case RiskLevel.green:
        return OrthaStatusModel(
          level: OrthaStatusLevel.green,
          title: 'Aktuelle Lage',
          statusText: warningActive
              ? 'Amtliche Warnlage'
              : 'Normale Wetterlage',
          riskText: risk.message,
          warningText: warningText,
          location: location,
          recommendation: warningActive
              ? 'Es liegt mindestens eine amtliche Warnung vor. '
                    'Die zugehörigen Hinweise sollten beachtet werden.'
              : 'Es bestehen derzeit keine besonderen Wetterrisiken. '
                    'Die Wetterlage wird weiterhin automatisch überwacht.',
          timestamp: DateTime.now(),
        );
    }
  }
}
