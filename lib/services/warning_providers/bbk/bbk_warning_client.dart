import 'dart:convert';

import 'package:http/http.dart' as http;

class BbkWarningClientException implements Exception {
  final String message;

  const BbkWarningClientException(this.message);

  @override
  String toString() => 'BbkWarningClientException: $message';
}

abstract class BbkWarningClient {
  Future<dynamic> fetchRawWarnings({
    required double latitude,
    required double longitude,
  });

  Future<dynamic> fetchMapData();

  Future<dynamic> fetchWarningDetail(String warningId);

  Future<dynamic> fetchWarningGeometry(String warningId);
}

class HttpBbkWarningClient implements BbkWarningClient {
  final http.Client httpClient;

  /// Alter Endpunkt bleibt vorübergehend erhalten, damit die bestehende
  /// Provider-Architektur bis zur nächsten Umstellung kompatibel bleibt.
  final Uri endpoint;

  /// Basis-URI der realen BBK-/NINA-Warnquellen.
  final Uri warningBaseUri;

  final Duration requestTimeout;

  HttpBbkWarningClient({
    required this.httpClient,
    required this.endpoint,
    Uri? warningBaseUri,
    this.requestTimeout = const Duration(seconds: 15),
  }) : warningBaseUri =
           warningBaseUri ?? Uri.https('warnung.bund.de', '/api31/');

  @override
  Future<dynamic> fetchRawWarnings({
    required double latitude,
    required double longitude,
  }) async {
    final requestUri = endpoint.replace(
      queryParameters: {
        ...endpoint.queryParameters,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      },
    );

    return _getJson(requestUri, requestDescription: 'BBK-Warnungen');
  }

  @override
  Future<dynamic> fetchMapData() {
    return _getJson(
      _resolvePath('mowas/mapData.json'),
      requestDescription: 'BBK-MapData',
    );
  }

  @override
  Future<dynamic> fetchWarningDetail(String warningId) {
    final normalizedId = _validateWarningId(warningId);

    return _getJson(
      _resolvePath('warnings/${Uri.encodeComponent(normalizedId)}.json'),
      requestDescription: 'BBK-Warndetail',
    );
  }

  @override
  Future<dynamic> fetchWarningGeometry(String warningId) {
    final normalizedId = _validateWarningId(warningId);

    return _getJson(
      _resolvePath('warnings/${Uri.encodeComponent(normalizedId)}.geojson'),
      requestDescription: 'BBK-Warngeometrie',
    );
  }

  Uri _resolvePath(String relativePath) {
    final normalizedBasePath = warningBaseUri.path.endsWith('/')
        ? warningBaseUri.path
        : '${warningBaseUri.path}/';

    return warningBaseUri.replace(
      path: '$normalizedBasePath$relativePath',
      queryParameters: const {},
      fragment: '',
    );
  }

  String _validateWarningId(String warningId) {
    final normalizedId = warningId.trim();

    if (normalizedId.isEmpty) {
      throw const BbkWarningClientException(
        'BBK-Warn-ID darf nicht leer sein.',
      );
    }

    return normalizedId;
  }

  Future<dynamic> _getJson(
    Uri requestUri, {
    required String requestDescription,
  }) async {
    http.Response response;

    try {
      response = await httpClient.get(requestUri).timeout(requestTimeout);
    } catch (error) {
      throw BbkWarningClientException(
        '$requestDescription konnte nicht abgerufen werden: $error',
      );
    }

    if (response.statusCode != 200) {
      throw BbkWarningClientException(
        '$requestDescription-Abruf fehlgeschlagen: '
        'HTTP ${response.statusCode}.',
      );
    }

    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (error) {
      throw BbkWarningClientException(
        '$requestDescription enthält ungültige JSON-Daten: $error',
      );
    }
  }
}
