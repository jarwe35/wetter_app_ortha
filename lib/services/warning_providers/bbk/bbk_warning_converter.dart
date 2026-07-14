import '../../../models/official_weather_warning.dart';
import '../../../models/warning_bridge/bbk_warning.dart';

class BbkWarningConverter {
  static const Duration defaultValidityDuration = Duration(hours: 24);

  const BbkWarningConverter();

  OfficialWeatherWarning convert(BbkWarning warning) {
    if (warning.isCancellation) {
      throw const FormatException(
        'BBK-Entwarnung kann nicht als aktive Warnung konvertiert werden.',
      );
    }

    final validFrom = warning.effective ?? warning.sent;

    if (validFrom == null) {
      throw const FormatException(
        'BBK-Warnung enthält keinen gültigen Startzeitpunkt.',
      );
    }

    final validUntil =
        warning.expires ?? validFrom.add(defaultValidityDuration);

    if (!validUntil.isAfter(validFrom)) {
      throw const FormatException(
        'BBK-Warnung enthält einen ungültigen Gültigkeitszeitraum.',
      );
    }

    return OfficialWeatherWarning(
      id: warning.identifier,
      title: warning.headline,
      description: warning.description,
      instruction: warning.instruction,
      source: warning.sender.trim().isEmpty
          ? 'BBK / warnung.bund.de'
          : warning.sender.trim(),
      severity: _mapSeverity(warning.severity),
      validFrom: validFrom,
      validUntil: validUntil,
      areaDescriptions: List<String>.unmodifiable(warning.areaDescriptions),
      geocodes: Map<String, String>.unmodifiable(warning.geocodes),
      polygons: List<String>.unmodifiable(warning.polygons),
    );
  }

  List<OfficialWeatherWarning> convertAll(Iterable<BbkWarning> warnings) {
    final result = <OfficialWeatherWarning>[];

    for (final warning in warnings) {
      try {
        result.add(convert(warning));
      } on FormatException {
        continue;
      }
    }

    return List<OfficialWeatherWarning>.unmodifiable(result);
  }

  OfficialWarningSeverity _mapSeverity(String value) {
    switch (value.trim().toLowerCase()) {
      case 'minor':
        return OfficialWarningSeverity.minor;
      case 'moderate':
        return OfficialWarningSeverity.moderate;
      case 'severe':
        return OfficialWarningSeverity.severe;
      case 'extreme':
        return OfficialWarningSeverity.extreme;
      default:
        return OfficialWarningSeverity.unknown;
    }
  }
}
