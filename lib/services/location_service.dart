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

  Future<SavedLocation> resolveLocation(String place) async {
    final cleanedPlace = place.trim();

    if (cleanedPlace.isEmpty) {
      throw const LocationServiceException(
        'Für die Ortssuche wurde kein Ortsname angegeben.',
      );
    }

    final requestUri = geocodingUri.replace(
      queryParameters: {
        'name': cleanedPlace,
        'count': '1',
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

    final firstResult = results.first;

    if (firstResult is! Map<String, dynamic>) {
      throw const LocationServiceException(
        'Ortssuche hat einen ungültigen Treffer geliefert.',
      );
    }

    final name = firstResult['name'];
    final latitude = firstResult['latitude'];
    final longitude = firstResult['longitude'];

    if (name is! String ||
        name.trim().isEmpty ||
        latitude is! num ||
        longitude is! num) {
      throw const LocationServiceException(
        'Ortssuche hat unvollständige Standortdaten geliefert.',
      );
    }

    final country = firstResult['country'];
    final timezone = firstResult['timezone'];

    return SavedLocation(
      name: name.trim(),
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      country: country is String && country.trim().isNotEmpty
          ? country.trim()
          : null,
      timezone: timezone is String && timezone.trim().isNotEmpty
          ? timezone.trim()
          : null,
    );
  }
}
