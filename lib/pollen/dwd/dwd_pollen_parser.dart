import 'dart:convert';

import 'dwd_pollen_dataset.dart';

class DwdPollenParseException implements Exception {
  const DwdPollenParseException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'DwdPollenParseException: $message';
}

class DwdPollenParser {
  const DwdPollenParser();

  static const Map<String, DwdPollenType> _typeByDwdKey = {
    'Hasel': DwdPollenType.hazel,
    'Erle': DwdPollenType.alder,
    'Esche': DwdPollenType.ash,
    'Birke': DwdPollenType.birch,
    'Graeser': DwdPollenType.grass,
    'Roggen': DwdPollenType.rye,
    'Beifuss': DwdPollenType.mugwort,
    'Ambrosia': DwdPollenType.ragweed,
  };

  DwdPollenDataset parseString(String source) {
    if (source.trim().isEmpty) {
      throw const DwdPollenParseException('Die DWD-Pollendatei ist leer.');
    }

    Object? decoded;

    try {
      decoded = jsonDecode(source);
    } on FormatException catch (error) {
      throw DwdPollenParseException(
        'Die DWD-Pollendatei enthält kein gültiges JSON.',
        cause: error,
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const DwdPollenParseException(
        'Die DWD-Pollendatei besitzt ein unerwartetes Wurzelformat.',
      );
    }

    return parseJson(decoded);
  }

  DwdPollenDataset parseJson(Map<String, dynamic> json) {
    final rawContent = json['content'];

    if (rawContent is! List) {
      throw const DwdPollenParseException(
        'Die DWD-Pollendatei enthält keine Regionsdaten.',
      );
    }

    final regions = <DwdPollenRegion>[];

    for (final rawRegion in rawContent) {
      if (rawRegion is! Map) {
        continue;
      }

      final regionJson = Map<String, dynamic>.from(rawRegion);

      final regionId = _readInt(regionJson['region_id']);
      final partRegionId = _readInt(regionJson['partregion_id']);

      if (regionId == null || partRegionId == null) {
        continue;
      }

      final rawPollen = regionJson['Pollen'];

      if (rawPollen is! Map) {
        continue;
      }

      final pollen = <DwdPollenType, DwdPollenDayValues>{};

      for (final entry in _typeByDwdKey.entries) {
        final rawValues = rawPollen[entry.key];

        if (rawValues is! Map) {
          continue;
        }

        final values = Map<String, dynamic>.from(rawValues);

        pollen[entry.value] = DwdPollenDayValues(
          today: parseIndex(values['today']),
          tomorrow: parseIndex(values['tomorrow']),
          dayAfterTomorrow: parseIndex(values['dayafter_to']),
        );
      }

      regions.add(
        DwdPollenRegion(
          regionId: regionId,
          partRegionId: partRegionId,
          regionName: regionJson['region_name']?.toString() ?? '',
          partRegionName: regionJson['partregion_name']?.toString() ?? '',
          pollen: Map.unmodifiable(pollen),
        ),
      );
    }

    if (regions.isEmpty) {
      throw const DwdPollenParseException(
        'Die DWD-Pollendatei enthält keine verwertbaren Regionsdaten.',
      );
    }

    return DwdPollenDataset(
      name: json['name']?.toString() ?? 'DWD Pollenflug-Gefahrenindex',
      sender: json['sender']?.toString() ?? 'Deutscher Wetterdienst',
      lastUpdate: _parseDwdDate(json['last_update']),
      nextUpdate: _parseDwdDate(json['next_update']),
      legend: Map.unmodifiable(_parseLegend(json['legend'])),
      regions: List.unmodifiable(regions),
    );
  }

  static DwdPollenIndex? parseIndex(Object? rawValue) {
    final value = rawValue?.toString().trim();

    return switch (value) {
      '0' => DwdPollenIndex.none,
      '0-1' => DwdPollenIndex.noneToLow,
      '1' => DwdPollenIndex.low,
      '1-2' => DwdPollenIndex.lowToModerate,
      '2' => DwdPollenIndex.moderate,
      '2-3' => DwdPollenIndex.moderateToHigh,
      '3' => DwdPollenIndex.high,
      '-1' || null || '' => null,
      _ => null,
    };
  }

  static Map<String, String> _parseLegend(Object? rawLegend) {
    if (rawLegend is! Map) {
      return const {};
    }

    return rawLegend.map(
      (key, value) => MapEntry(key.toString(), value.toString()),
    );
  }

  static int? _readInt(Object? value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '');
  }

  static DateTime? _parseDwdDate(Object? rawValue) {
    final value = rawValue?.toString().trim();

    if (value == null || value.isEmpty) {
      return null;
    }

    final match = RegExp(
      r'^(\d{4})-(\d{2})-(\d{2})[ T](\d{2}):(\d{2})',
    ).firstMatch(value);

    if (match == null) {
      return null;
    }

    return DateTime(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
      int.parse(match.group(4)!),
      int.parse(match.group(5)!),
    );
  }
}
