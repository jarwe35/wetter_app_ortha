import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/saved_location.dart';

class LocationServiceException implements Exception {
  final String message;

  const LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

class LocationService {
  static final Uri defaultGeocodingUri = Uri.https(
    'geocoding-api.open-meteo.com',
    '/v1/search',
  );

  final http.Client httpClient;
  final Uri geocodingUri;
  final Duration requestTimeout;

  LocationService({
    required this.httpClient,
    Uri? geocodingUri,
    this.requestTimeout = const Duration(seconds: 15),
  }) : geocodingUri = geocodingUri ?? defaultGeocodingUri;

  Future<List<SavedLocation>> searchLocations(String place) async {
    final cleanedPlace = place.trim();

    if (cleanedPlace.isEmpty) {
      throw const LocationServiceException(
        'Für die Ortssuche wurde kein Ortsname angegeben.',
      );
    }

    final requestUri = geocodingUri.replace(
      queryParameters: {
        'name': cleanedPlace,
        'count': '10',
        'language': 'de',
        'format': 'json',
      },
    );

    http.Response response;

    try {
      response = await httpClient.get(requestUri).timeout(requestTimeout);
    } catch (error) {
      throw LocationServiceException(
        'Ortssuche konnte nicht durchgeführt werden: $error',
      );
    }

    if (response.statusCode != 200) {
      throw LocationServiceException(
        'Ortssuche fehlgeschlagen: HTTP ${response.statusCode}.',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (error) {
      throw LocationServiceException(
        'Ortssuche hat ungültige Daten geliefert: $error',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const LocationServiceException(
        'Ortssuche hat ein ungültiges Datenformat geliefert.',
      );
    }

    final results = decoded['results'];

    if (results is! List || results.isEmpty) {
      throw LocationServiceException(
        'Der Ort "$cleanedPlace" wurde nicht gefunden.',
      );
    }

    final locations = results
        .whereType<Map<String, dynamic>>()
        .map(_savedLocationFromResult)
        .whereType<SavedLocation>()
        .toList();

    if (locations.isEmpty) {
      throw const LocationServiceException(
        'Ortssuche hat keine vollständigen Standortdaten geliefert.',
      );
    }

    return List<SavedLocation>.unmodifiable(locations);
  }

  Future<SavedLocation> resolveLocation(String place) async {
    final cleanedPlace = place.trim();
    final locations = await searchLocations(cleanedPlace);
    final normalizedSearch = cleanedPlace.toLowerCase();

    for (final location in locations) {
      if (location.name.trim().toLowerCase() == normalizedSearch) {
        return location;
      }
    }

    return locations.first;
  }

  SavedLocation? _savedLocationFromResult(Map<String, dynamic> result) {
    final name = result['name'];
    final latitude = result['latitude'];
    final longitude = result['longitude'];

    if (name is! String ||
        name.trim().isEmpty ||
        latitude is! num ||
        longitude is! num) {
      return null;
    }

    final country = result['country'];
    final admin1 = result['admin1'];
    final timezone = result['timezone'];

    return SavedLocation(
      name: name.trim(),
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      country: country is String && country.trim().isNotEmpty
          ? country.trim()
          : null,
      admin1: admin1 is String && admin1.trim().isNotEmpty
          ? admin1.trim()
          : null,
      timezone: timezone is String && timezone.trim().isNotEmpty
          ? timezone.trim()
          : null,
    );
  }
}
