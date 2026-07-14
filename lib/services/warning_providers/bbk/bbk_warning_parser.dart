import '../../../models/warning_bridge/bbk_warning.dart';

class BbkWarningParser {
  const BbkWarningParser();

  BbkWarning parse(Map<String, dynamic> json) {
    final info = _selectPreferredInfo(json['info']);

    final area =
        _firstMapFromList(info['area']) ??
        _asMap(info['area']) ??
        const <String, dynamic>{};

    final identifier = _firstNonEmptyString([
      json['identifier'],
      json['id'],
      json['warnId'],
    ]);

    if (identifier == null) {
      throw const FormatException('BBK-Warnung enthält keine gültige Kennung.');
    }

    return BbkWarning(
      identifier: identifier,
      headline:
          _firstNonEmptyString([
            info['headline'],
            json['headline'],
            json['title'],
          ]) ??
          'Amtliche Warnung',
      description:
          _firstNonEmptyString([
            info['description'],
            json['description'],
            json['text'],
          ]) ??
          '',
      instruction:
          _firstNonEmptyString([
            info['instruction'],
            json['instruction'],
            json['recommendation'],
          ]) ??
          '',
      sender:
          _firstNonEmptyString([
            json['senderName'],
            json['sender'],
            info['senderName'],
          ]) ??
          'BBK / warnung.bund.de',
      severity:
          _firstNonEmptyString([info['severity'], json['severity']]) ??
          'Unknown',
      urgency:
          _firstNonEmptyString([info['urgency'], json['urgency']]) ?? 'Unknown',
      certainty:
          _firstNonEmptyString([info['certainty'], json['certainty']]) ??
          'Unknown',
      messageType:
          _firstNonEmptyString([
            json['msgType'],
            json['messageType'],
            json['type'],
          ]) ??
          'Alert',
      sent: _parseDateTime(json['sent']),
      effective: _parseDateTime(
        info['effective'] ?? json['effective'] ?? json['start'],
      ),
      expires: _parseDateTime(
        info['expires'] ?? json['expires'] ?? json['end'],
      ),
      areaDescriptions: _readAreaDescriptions(info, area),
      geocodes: _readGeocodes(info, area),
      polygons: _readPolygons(info, area),
    );
  }

  List<BbkWarning> parseList(dynamic json) {
    final rawWarnings = switch (json) {
      List<dynamic> value => value,
      Map<String, dynamic> value when value['warnings'] is List<dynamic> =>
        value['warnings'] as List<dynamic>,
      Map<String, dynamic> value when value['items'] is List<dynamic> =>
        value['items'] as List<dynamic>,
      _ => const <dynamic>[],
    };

    final warnings = <BbkWarning>[];

    for (final rawWarning in rawWarnings) {
      if (rawWarning is! Map<String, dynamic>) {
        continue;
      }

      try {
        warnings.add(parse(rawWarning));
      } on FormatException {
        continue;
      }
    }

    return List<BbkWarning>.unmodifiable(warnings);
  }

  List<String> _readAreaDescriptions(
    Map<String, dynamic> info,
    Map<String, dynamic> area,
  ) {
    final result = <String>[];

    void addValue(dynamic value) {
      if (value is String && value.trim().isNotEmpty) {
        result.add(value.trim());
      }
    }

    addValue(area['areaDesc']);
    addValue(info['areaDesc']);

    final rawAreas = info['area'];

    if (rawAreas is List<dynamic>) {
      for (final rawArea in rawAreas) {
        final areaMap = _asMap(rawArea);
        addValue(areaMap?['areaDesc']);
      }
    }

    return _uniqueStrings(result);
  }

  Map<String, String> _readGeocodes(
    Map<String, dynamic> info,
    Map<String, dynamic> area,
  ) {
    final result = <String, String>{};

    void addGeocode(dynamic value) {
      final geocode = _asMap(value);

      if (geocode == null) return;

      final key = _firstNonEmptyString([
        geocode['valueName'],
        geocode['name'],
        geocode['key'],
      ]);

      final geocodeValue = _firstNonEmptyString([
        geocode['value'],
        geocode['code'],
      ]);

      if (key != null && geocodeValue != null) {
        result[key] = geocodeValue;
      }
    }

    final rawAreas = info['area'];

    if (rawAreas is List<dynamic>) {
      for (final rawArea in rawAreas) {
        final areaMap = _asMap(rawArea);

        if (areaMap == null) {
          continue;
        }

        final areaGeocodes = areaMap['geocode'];

        if (areaGeocodes is List<dynamic>) {
          for (final geocode in areaGeocodes) {
            addGeocode(geocode);
          }
        } else {
          addGeocode(areaGeocodes);
        }
      }
    } else {
      final areaGeocodes = area['geocode'];

      if (areaGeocodes is List<dynamic>) {
        for (final geocode in areaGeocodes) {
          addGeocode(geocode);
        }
      } else {
        addGeocode(areaGeocodes);
      }
    }

    final infoGeocodes = info['geocode'];

    if (infoGeocodes is List<dynamic>) {
      for (final geocode in infoGeocodes) {
        addGeocode(geocode);
      }
    } else {
      addGeocode(infoGeocodes);
    }

    final directGeocodes = info['geocodes'];

    if (directGeocodes is Map<String, dynamic>) {
      for (final entry in directGeocodes.entries) {
        final value = entry.value;

        if (value is String && value.trim().isNotEmpty) {
          result[entry.key] = value.trim();
        }
      }
    }

    return Map<String, String>.unmodifiable(result);
  }

  List<String> _readPolygons(
    Map<String, dynamic> info,
    Map<String, dynamic> area,
  ) {
    final result = <String>[];

    void addPolygon(dynamic value) {
      if (value is String && value.trim().isNotEmpty) {
        result.add(value.trim());
      }
    }

    final areaPolygons = area['polygon'];

    if (areaPolygons is List<dynamic>) {
      for (final polygon in areaPolygons) {
        addPolygon(polygon);
      }
    } else {
      addPolygon(areaPolygons);
    }

    final infoPolygons = info['polygon'];

    if (infoPolygons is List<dynamic>) {
      for (final polygon in infoPolygons) {
        addPolygon(polygon);
      }
    } else {
      addPolygon(infoPolygons);
    }

    return _uniqueStrings(result);
  }

  Map<String, dynamic> _selectPreferredInfo(dynamic value) {
    final directInfo = _asMap(value);

    if (directInfo != null) {
      return directInfo;
    }

    if (value is! List<dynamic>) {
      return const <String, dynamic>{};
    }

    final infos = value.whereType<Map<String, dynamic>>().toList();

    if (infos.isEmpty) {
      return const <String, dynamic>{};
    }

    Map<String, dynamic>? findByLanguage(
      bool Function(String language) matches,
    ) {
      for (final info in infos) {
        final language = info['language'];

        if (language is String && matches(language.trim().toLowerCase())) {
          return info;
        }
      }

      return null;
    }

    return findByLanguage((language) => language == 'de') ??
        findByLanguage((language) => language == 'de-de') ??
        findByLanguage((language) => language.startsWith('de-')) ??
        infos.first;
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value.trim());
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    return value is Map<String, dynamic> ? value : null;
  }

  Map<String, dynamic>? _firstMapFromList(dynamic value) {
    if (value is! List<dynamic>) return null;

    for (final item in value) {
      if (item is Map<String, dynamic>) {
        return item;
      }
    }

    return null;
  }

  String? _firstNonEmptyString(List<dynamic> values) {
    for (final value in values) {
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }

    return null;
  }

  List<String> _uniqueStrings(List<String> values) {
    final seen = <String>{};
    final result = <String>[];

    for (final value in values) {
      final normalized = value.toLowerCase();

      if (seen.add(normalized)) {
        result.add(value);
      }
    }

    return List<String>.unmodifiable(result);
  }
}
