import 'dart:typed_data';

import 'package:http/http.dart' as http;

class DwdCapDownloadException implements Exception {
  final String message;

  const DwdCapDownloadException(this.message);

  @override
  String toString() => 'DwdCapDownloadException: $message';
}

class DwdCapDownloadClient {
  final http.Client httpClient;
  final Uri sourceUri;

  const DwdCapDownloadClient({
    required this.httpClient,
    required this.sourceUri,
  });

  Future<Uint8List> download() async {
    http.Response response;

    try {
      response = await httpClient.get(sourceUri);
    } catch (error) {
      throw DwdCapDownloadException(
        'Netzwerkfehler beim Abruf der DWD-Warndaten: $error',
      );
    }

    if (response.statusCode != 200) {
      throw DwdCapDownloadException(
        'DWD-Warndaten konnten nicht geladen werden '
        '(HTTP ${response.statusCode}).',
      );
    }

    if (response.bodyBytes.isEmpty) {
      throw const DwdCapDownloadException(
        'Die DWD-Datenquelle hat keine Warndaten geliefert.',
      );
    }

    return response.bodyBytes;
  }
}
