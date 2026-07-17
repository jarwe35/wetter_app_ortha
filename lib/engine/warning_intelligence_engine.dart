import '../models/official_weather_warning.dart';

enum OrthaWarningLevel { none, yellow, orange, red, darkRed }

class WarningIntelligenceResult {
  final OrthaWarningLevel level;
  final bool shouldNotify;
  final bool shouldSpeak;
  final String recommendation;

  const WarningIntelligenceResult({
    required this.level,
    required this.shouldNotify,
    required this.shouldSpeak,
    required this.recommendation,
  });
}

class WarningIntelligenceEngine {
  const WarningIntelligenceEngine();

  WarningIntelligenceResult analyze(OfficialWeatherWarning warning) {
    switch (warning.severity) {
      case OfficialWarningSeverity.extreme:
        return const WarningIntelligenceResult(
          level: OrthaWarningLevel.darkRed,
          shouldNotify: true,
          shouldSpeak: true,
          recommendation:
              'Extreme Wettergefahr. Sofortige Schutzmaßnahmen beachten.',
        );

      case OfficialWarningSeverity.severe:
        return const WarningIntelligenceResult(
          level: OrthaWarningLevel.red,
          shouldNotify: true,
          shouldSpeak: true,
          recommendation:
              'Schwere Wettergefahr. Verhalten anpassen und Warnhinweise beachten.',
        );

      case OfficialWarningSeverity.moderate:
        return const WarningIntelligenceResult(
          level: OrthaWarningLevel.orange,
          shouldNotify: true,
          shouldSpeak: false,
          recommendation:
              'Erhöhte Wettergefahr. Vorsicht im betroffenen Gebiet.',
        );

      case OfficialWarningSeverity.minor:
        return const WarningIntelligenceResult(
          level: OrthaWarningLevel.yellow,
          shouldNotify: false,
          shouldSpeak: false,
          recommendation: 'Leichte Wetterbeeinträchtigung möglich.',
        );

      case OfficialWarningSeverity.unknown:
        return const WarningIntelligenceResult(
          level: OrthaWarningLevel.yellow,
          shouldNotify: false,
          shouldSpeak: false,
          recommendation: 'Warnung konnte nicht eindeutig bewertet werden.',
        );
    }
  }
}
