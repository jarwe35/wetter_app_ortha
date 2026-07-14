import '../../../models/warning_bridge/bbk_map_warning.dart';

class BbkMapDataParser {
  const BbkMapDataParser();

  List<BbkMapWarning> parse(dynamic payload) {
    if (payload is! List) {
      throw const FormatException('BBK-MapData muss eine JSON-Liste sein.');
    }

    final warnings = <BbkMapWarning>[];

    for (final item in payload) {
      final warning = _parseItem(item);

      if (warning != null) {
        warnings.add(warning);
      }
    }

    return List<BbkMapWarning>.unmodifiable(warnings);
  }

  BbkMapWarning? _parseItem(dynamic item) {
    if (item is! Map) {
      return null;
    }

    final id = _readRequiredString(item, 'id');
    final startDateValue = _readRequiredString(item, 'startDate');
    final startDate = DateTime.tryParse(startDateValue);

    if (startDate == null) {
      return null;
    }

    final versionValue = item['version'];
    final version = versionValue is int
        ? versionValue
        : int.tryParse(versionValue?.toString() ?? '');

    if (version == null) {
      return null;
    }

    return BbkMapWarning(
      id: id,
      version: version,
      startDate: startDate,
      severity: _readOptionalString(item, 'severity'),
      urgency: _readOptionalString(item, 'urgency'),
      type: _readOptionalString(item, 'type'),
      titles: _readStringMap(item['i18nTitle']),
      translationKeys: _readStringMap(item['transKeys']),
    );
  }

  String _readRequiredString(Map<dynamic, dynamic> map, String key) {
    final value = map[key];

    if (value is! String || value.trim().isEmpty) {
      throw FormatException(
        'BBK-MapData-Eintrag enthält kein gültiges Feld "$key".',
      );
    }

    return value.trim();
  }

  String _readOptionalString(Map<dynamic, dynamic> map, String key) {
    final value = map[key];

    if (value is String) {
      return value.trim();
    }

    return '';
  }

  Map<String, String> _readStringMap(dynamic value) {
    if (value is! Map) {
      return const {};
    }

    final result = <String, String>{};

    for (final entry in value.entries) {
      final key = entry.key;
      final mapValue = entry.value;

      if (key is String && mapValue is String) {
        result[key] = mapValue;
      }
    }

    return Map<String, String>.unmodifiable(result);
  }
}
