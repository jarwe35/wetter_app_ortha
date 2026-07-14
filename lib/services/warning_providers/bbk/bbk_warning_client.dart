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
}

class HttpBbkWarningClient implements BbkWarningClient {
  final http.Client httpClient;
  final Uri endpoint;
  final Duration requestTimeout;

  const HttpBbkWarningClient({
    required this.httpClient,
    required this.endpoint,
    this.requestTimeout = const Duration(seconds: 15),
  });

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

    http.Response response;

    try {
      response = await httpClient.get(requestUri).timeout(requestTimeout);
    } catch (error) {
      throw BbkWarningClientException(
        'BBK-Warnungen konnten nicht abgerufen werden: $error',
      );
    }

    if (response.statusCode != 200) {
      throw BbkWarningClientException(
        'BBK-Warnungsabruf fehlgeschlagen: HTTP ${response.statusCode}.',
      );
    }

    try {
      return jsonDecode(response.body);
    } catch (error) {
      throw BbkWarningClientException(
        'BBK-Warnungsdaten sind ungültig: $error',
      );
    }
  }
}
