import 'package:xml/xml.dart';

import '../../models/official_weather_warning.dart';

class DwdCapParser {
  const DwdCapParser();

  List<OfficialWeatherWarning> parse(String xmlContent) {
    final document = XmlDocument.parse(xmlContent);

    final alerts = document.descendants.whereType<XmlElement>().where(
      (element) => element.name.local == 'alert',
    );

    return alerts.map(_parseAlert).toList();
  }

  OfficialWeatherWarning _parseAlert(XmlElement alert) {
    final identifier = _firstText(alert, 'identifier') ?? '';
    final sent = _firstText(alert, 'sent');

    final info = alert.descendants.whereType<XmlElement>().firstWhere(
      (element) => element.name.local == 'info',
    );

    final headline = _firstText(info, 'headline') ?? 'Amtliche Wetterwarnung';
    final description = _firstText(info, 'description') ?? '';
    final instruction = _firstText(info, 'instruction') ?? '';
    final severityText = _firstText(info, 'severity') ?? 'Unknown';
    final effective = _firstText(info, 'effective') ?? sent;
    final expires = _firstText(info, 'expires');

    final areaDescriptions = <String>[];
    final geocodes = <String, String>{};
    final polygons = <String>[];

    final areas = info.descendants.whereType<XmlElement>().where(
      (element) => element.name.local == 'area',
    );

    for (final area in areas) {
      final areaDescription = _firstText(area, 'areaDesc');

      if (areaDescription != null && areaDescription.isNotEmpty) {
        areaDescriptions.add(areaDescription);
      }

      final areaGeocodes = area.children.whereType<XmlElement>().where(
        (element) => element.name.local == 'geocode',
      );

      for (final geocode in areaGeocodes) {
        final valueName = _firstText(geocode, 'valueName');
        final value = _firstText(geocode, 'value');

        if (valueName != null &&
            valueName.isNotEmpty &&
            value != null &&
            value.isNotEmpty) {
          geocodes[valueName] = value;
        }
      }

      final areaPolygons = area.children.whereType<XmlElement>().where(
        (element) => element.name.local == 'polygon',
      );

      for (final polygon in areaPolygons) {
        final value = polygon.innerText.trim();

        if (value.isNotEmpty) {
          polygons.add(value);
        }
      }
    }

    return OfficialWeatherWarning(
      id: identifier,
      title: headline,
      description: description,
      instruction: instruction,
      source: 'Deutscher Wetterdienst',
      severity: _parseSeverity(severityText),
      validFrom: DateTime.parse(effective ?? DateTime.now().toIso8601String()),
      validUntil: DateTime.parse(expires ?? DateTime.now().toIso8601String()),
      areaDescriptions: areaDescriptions,
      geocodes: geocodes,
      polygons: polygons,
    );
  }

  OfficialWarningSeverity _parseSeverity(String value) {
    switch (value.toLowerCase()) {
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

  String? _firstText(XmlElement parent, String localName) {
    for (final element in parent.descendants.whereType<XmlElement>()) {
      if (element.name.local == localName) {
        return element.innerText.trim();
      }
    }

    return null;
  }
}
