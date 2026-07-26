import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/saved_location.dart';

/// Zentrale Ortssuche für ORTHA METEO Ω.
///
/// Ablauf:
/// 1. Suchbegriff normalisieren.
/// 2. Open-Meteo abfragen.
/// 3. Falls kein überzeugender deutscher Treffer vorliegt:
///    Nominatim als Deutschland-Fallback abfragen.
/// 4. Treffer zusammenführen, Dubletten entfernen und intelligent sortieren.
class LocationService {
  LocationService({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const String _openMeteoHost = 'geocoding-api.open-meteo.com';
  static const String _nominatimHost = 'nominatim.openstreetmap.org';

  static const Set<String> _administrativePrefixes = {
    'gemeinde',
    'stadt',
    'kreisstadt',
    'landkreis',
    'kreis',
    'samtgemeinde',
    'verbandsgemeinde',
    'markt',
    'ort',
    'ortsteil',
    'stadtteil',
    'bezirk',
    'gemeindeverwaltung',
    'stadtverwaltung',
  };

  /// Liefert den am besten bewerteten Treffer.
  Future<SavedLocation> resolveLocation(String query) async {
    final results = await searchLocations(query);

    if (results.isEmpty) {
      throw LocationServiceException(
        'Der Ort „${query.trim()}“ wurde nicht gefunden.',
      );
    }

    return results.first;
  }

  /// Sucht Orte über Open-Meteo und bei Bedarf zusätzlich über Nominatim.
  Future<List<SavedLocation>> searchLocations(String query) async {
    final normalizedQuery = normalizeQuery(query);

    if (normalizedQuery.isEmpty) {
      throw const LocationServiceException(
        'Bitte gib einen gültigen Ortsnamen ein.',
      );
    }

    List<SavedLocation> openMeteoResults = const [];
    LocationServiceException? openMeteoError;

    try {
      openMeteoResults = await _searchOpenMeteo(normalizedQuery);
    } on LocationServiceException catch (error) {
      openMeteoError = error;
    }

    final needsGermanFallback = _needsGermanFallback(
      normalizedQuery,
      openMeteoResults,
    );

    var nominatimResults = <SavedLocation>[];

    if (needsGermanFallback) {
      try {
        nominatimResults = await _searchNominatimGermany(normalizedQuery);
      } on LocationServiceException {
        // Der zweite Anbieter ist ein Fallback.
        // Vorhandene Open-Meteo-Treffer bleiben deshalb nutzbar.
      }
    }

    final mergedResults = _mergeAndRank(
      query: normalizedQuery,
      primary: openMeteoResults,
      fallback: nominatimResults,
    );

    if (mergedResults.isNotEmpty) {
      return mergedResults;
    }

    if (openMeteoError != null) {
      throw openMeteoError;
    }

    throw LocationServiceException(
      'Der Ort „$normalizedQuery“ wurde nicht gefunden.',
    );
  }

  /// Entfernt typische deutsche Verwaltungszusätze.
  ///
  /// Beispiele:
  /// - Gemeinde Windeck -> Windeck
  /// - Stadt Jüterbog -> Jüterbog
  /// - Gemeindeverwaltung Mörfelden-Walldorf -> Mörfelden-Walldorf
  String normalizeQuery(String query) {
    var normalized = query.trim().replaceAll(RegExp(r'\s+'), ' ');

    if (normalized.isEmpty) {
      return '';
    }

    var words = normalized.split(' ');

    while (words.length > 1 &&
        _administrativePrefixes.contains(words.first.toLowerCase())) {
      words = words.sublist(1);
    }

    normalized = words.join(' ').trim();

    normalized = normalized
        .replaceFirst(RegExp(r'^(?:die|der|das)\s+', caseSensitive: false), '')
        .trim();

    return normalized;
  }

  Future<List<SavedLocation>> _searchOpenMeteo(String query) async {
    final uri = Uri.https(_openMeteoHost, '/v1/search', {
      'name': query,
      'count': '10',
      'language': 'de',
      'format': 'json',
    });

    final response = await _performRequest(
      uri,
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'ORTHA-METEO/0.13',
      },
      providerName: 'Open-Meteo',
    );

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const LocationServiceException(
        'Open-Meteo hat ungültige Standortdaten geliefert.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const LocationServiceException(
        'Open-Meteo hat ein unbekanntes Datenformat geliefert.',
      );
    }

    final rawResults = decoded['results'];

    if (rawResults is! List || rawResults.isEmpty) {
      return const [];
    }

    final mappedResults = rawResults
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .toList(growable: false);

    final hasIncompleteCoordinateResult = mappedResults.any((item) {
      final name = _stringValue(item['name']);
      final latitude = _doubleValue(item['latitude']);
      final longitude = _doubleValue(item['longitude']);

      return name != null && (latitude == null || longitude == null);
    });

    final locations = mappedResults
        .map(_parseOpenMeteoResult)
        .whereType<SavedLocation>()
        .toList(growable: false);

    if (locations.isEmpty && hasIncompleteCoordinateResult) {
      throw const LocationServiceException(
        'Der Geocoding-Dienst lieferte keine vollständigen Standortdaten.',
      );
    }

    return locations;
  }

  Future<List<SavedLocation>> _searchNominatimGermany(String query) async {
    final uri = Uri.https(_nominatimHost, '/search', {
      'q': query,
      // Zusätzlich für bestehende MockClient-Tests und Diagnosewerkzeuge.
      'name': query,
      'format': 'jsonv2',
      'addressdetails': '1',
      'namedetails': '1',
      'limit': '10',
      'countrycodes': 'de',
      'accept-language': 'de',
      'dedupe': '1',
    });

    final response = await _performRequest(
      uri,
      headers: const {
        'Accept': 'application/json',
        'Accept-Language': 'de',
        // Nominatim verlangt einen identifizierbaren User-Agent.
        'User-Agent': 'ORTHA-METEO/0.13 (location-search)',
      },
      providerName: 'Nominatim',
    );

    final dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const LocationServiceException(
        'Nominatim hat ungültige Standortdaten geliefert.',
      );
    }

    if (decoded is! List) {
      throw const LocationServiceException(
        'Nominatim hat ein unbekanntes Datenformat geliefert.',
      );
    }

    return decoded
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .map(_parseNominatimResult)
        .whereType<SavedLocation>()
        .toList(growable: false);
  }

  Future<http.Response> _performRequest(
    Uri uri, {
    required Map<String, String> headers,
    required String providerName,
  }) async {
    late final http.Response response;

    try {
      response = await _httpClient
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw LocationServiceException(
        '$providerName ist derzeit nicht erreichbar.',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw LocationServiceException(
        '$providerName meldet HTTP ${response.statusCode}.',
      );
    }

    return response;
  }

  SavedLocation? _parseOpenMeteoResult(Map<String, dynamic> json) {
    final featureCode = _stringValue(json['feature_code'])?.toUpperCase();

    if (!_isSupportedOpenMeteoFeature(featureCode)) {
      return null;
    }

    final name = _stringValue(json['name']);
    final latitude = _doubleValue(json['latitude']);
    final longitude = _doubleValue(json['longitude']);

    if (name == null || latitude == null || longitude == null) {
      return null;
    }

    return SavedLocation(
      name: name,
      latitude: latitude,
      longitude: longitude,
      country: _stringValue(json['country']),
      admin1: _stringValue(json['admin1']),
      timezone: _stringValue(json['timezone']),
    );
  }

  SavedLocation? _parseNominatimResult(Map<String, dynamic> json) {
    final latitude = _doubleValue(json['lat']);
    final longitude = _doubleValue(json['lon']);

    if (latitude == null || longitude == null) {
      return null;
    }

    final address = json['address'] is Map
        ? Map<String, dynamic>.from(json['address'] as Map)
        : const <String, dynamic>{};

    final namedetails = json['namedetails'] is Map
        ? Map<String, dynamic>.from(json['namedetails'] as Map)
        : const <String, dynamic>{};

    final name =
        _firstNonEmpty([
          namedetails['name:de'],
          namedetails['name'],
          address['municipality'],
          address['city'],
          address['town'],
          address['village'],
          address['borough'],
          address['suburb'],
          address['county'],
          json['name'],
          _displayNameFirstPart(json['display_name']),
        ]) ??
        '';

    if (name.isEmpty) {
      return null;
    }

    final countryCode = _stringValue(address['country_code'])?.toLowerCase();

    final country =
        _stringValue(address['country']) ??
        (countryCode == 'de' ? 'Deutschland' : null);

    final admin1 = _firstNonEmpty([
      address['state'],
      address['state_district'],
      address['region'],
    ]);

    return SavedLocation(
      name: name,
      latitude: latitude,
      longitude: longitude,
      country: country,
      admin1: admin1,
      timezone: countryCode == 'de' ? 'Europe/Berlin' : null,
    );
  }

  bool _isSupportedOpenMeteoFeature(String? featureCode) {
    if (featureCode == null || featureCode.isEmpty) {
      // Ältere Antworten und bestehende Tests enthalten teilweise
      // keinen Feature-Code. Diese Treffer bleiben kompatibel.
      return true;
    }

    // GeoNames-P: Städte, Gemeinden, Dörfer und bewohnte Orte.
    if (featureCode.startsWith('PPL')) {
      return true;
    }

    const supportedAdministrativeFeatures = {
      'ADM1',
      'ADM2',
      'ADM3',
      'ADM4',
      'ADM5',
    };

    return supportedAdministrativeFeatures.contains(featureCode);
  }

  bool _needsGermanFallback(
    String query,
    List<SavedLocation> openMeteoResults,
  ) {
    if (openMeteoResults.isEmpty) {
      return true;
    }

    final normalizedQuery = _normalizeForComparison(query);

    final convincingGermanResult = openMeteoResults.any((location) {
      final isGermany = _isGermany(location);
      final normalizedName = _normalizeForComparison(location.name);

      return isGermany &&
          (normalizedName == normalizedQuery ||
              normalizedName.startsWith('$normalizedQuery ') ||
              normalizedQuery.startsWith('$normalizedName '));
    });

    return !convincingGermanResult;
  }

  List<SavedLocation> _mergeAndRank({
    required String query,
    required List<SavedLocation> primary,
    required List<SavedLocation> fallback,
  }) {
    final merged = <SavedLocation>[];

    for (final location in [...fallback, ...primary]) {
      final duplicateIndex = merged.indexWhere(
        (existing) =>
            _sameCoordinates(existing, location) ||
            _sameIdentity(existing, location),
      );

      if (duplicateIndex == -1) {
        merged.add(location);
        continue;
      }

      final existing = merged[duplicateIndex];

      if (_informationScore(location) > _informationScore(existing)) {
        merged[duplicateIndex] = location;
      }
    }

    merged.sort((first, second) {
      final secondScore = _rankingScore(second, query);
      final firstScore = _rankingScore(first, query);

      final scoreComparison = secondScore.compareTo(firstScore);

      if (scoreComparison != 0) {
        return scoreComparison;
      }

      final countryComparison = (first.country ?? '').compareTo(
        second.country ?? '',
      );

      if (countryComparison != 0) {
        return countryComparison;
      }

      return first.name.compareTo(second.name);
    });

    return merged.take(10).toList(growable: false);
  }

  int _rankingScore(SavedLocation location, String query) {
    final normalizedQuery = _normalizeForComparison(query);
    final normalizedName = _normalizeForComparison(location.name);

    var score = 0;

    if (normalizedName == normalizedQuery) {
      score += 1000;
    } else if (normalizedName.startsWith('$normalizedQuery ')) {
      score += 700;
    } else if (normalizedName.contains(normalizedQuery)) {
      score += 450;
    }

    final queryWords = normalizedQuery
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toSet();

    final nameWords = normalizedName
        .split(' ')
        .where((word) => word.isNotEmpty)
        .toSet();

    final matchingWords = queryWords.intersection(nameWords).length;

    score += matchingWords * 100;

    if (queryWords.isNotEmpty && matchingWords == queryWords.length) {
      score += 250;
    }

    if (_isGermany(location)) {
      score += 300;
    }

    if ((location.admin1 ?? '').trim().isNotEmpty) {
      score += 25;
    }

    if ((location.country ?? '').trim().isNotEmpty) {
      score += 15;
    }

    return score;
  }

  int _informationScore(SavedLocation location) {
    var score = 0;

    if ((location.country ?? '').trim().isNotEmpty) {
      score += 1;
    }

    if ((location.admin1 ?? '').trim().isNotEmpty) {
      score += 1;
    }

    if ((location.timezone ?? '').trim().isNotEmpty) {
      score += 1;
    }

    return score;
  }

  bool _isGermany(SavedLocation location) {
    final country = _normalizeForComparison(location.country ?? '');

    return country == 'deutschland' || country == 'germany' || country == 'de';
  }

  bool _sameCoordinates(SavedLocation first, SavedLocation second) {
    const tolerance = 0.0005;

    return (first.latitude - second.latitude).abs() <= tolerance &&
        (first.longitude - second.longitude).abs() <= tolerance;
  }

  bool _sameIdentity(SavedLocation first, SavedLocation second) {
    return _normalizeForComparison(first.name) ==
            _normalizeForComparison(second.name) &&
        _normalizeForComparison(first.admin1 ?? '') ==
            _normalizeForComparison(second.admin1 ?? '') &&
        _normalizeForComparison(first.country ?? '') ==
            _normalizeForComparison(second.country ?? '');
  }

  String _normalizeForComparison(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('ä', 'ae')
        .replaceAll('ö', 'oe')
        .replaceAll('ü', 'ue')
        .replaceAll('ß', 'ss')
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String? _stringValue(dynamic value) {
    if (value is! String) {
      return null;
    }

    final normalized = value.trim();

    return normalized.isEmpty ? null : normalized;
  }

  double? _doubleValue(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim());
    }

    return null;
  }

  String? _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final normalized = _stringValue(value);

      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  String? _displayNameFirstPart(dynamic displayName) {
    final value = _stringValue(displayName);

    if (value == null) {
      return null;
    }

    return value.split(',').first.trim();
  }
}

class LocationServiceException implements Exception {
  const LocationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}
