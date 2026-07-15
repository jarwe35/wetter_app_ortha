import 'official_warning_geometry.dart';

enum OfficialWarningSeverity { minor, moderate, severe, extreme, unknown }

class OfficialWeatherWarning {
  final String id;
  final String title;
  final String description;
  final String instruction;
  final String source;
  final OfficialWarningSeverity severity;
  final DateTime validFrom;
  final DateTime validUntil;
  final List<String> areaDescriptions;
  final Map<String, String> geocodes;
  final List<String> polygons;

  final OfficialWarningGeometry? geometry;

  const OfficialWeatherWarning({
    required this.id,
    required this.title,
    required this.description,
    required this.instruction,
    required this.source,
    required this.severity,
    required this.validFrom,
    required this.validUntil,
    this.areaDescriptions = const [],
    this.geocodes = const {},
    this.polygons = const [],
    this.geometry,
  });

  bool get isActive {
    final now = DateTime.now();

    return !now.isBefore(validFrom) && now.isBefore(validUntil);
  }

  Duration get remainingDuration {
    final now = DateTime.now();

    if (!now.isBefore(validUntil)) {
      return Duration.zero;
    }

    return validUntil.difference(now);
  }
}
