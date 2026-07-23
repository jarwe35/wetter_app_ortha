import 'package:http/http.dart' as http;

class DwdPollenDownloadException implements Exception {
  const DwdPollenDownloadException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'DwdPollenDownloadException: $message';
}

class DwdPollenDownloadClient {
  DwdPollenDownloadClient({
    http.Client? httpClient,
    Uri? sourceUri,
    this.timeout = const Duration(seconds: 20),
  }) : _httpClient = httpClient ?? http.Client(),
       sourceUri =
           sourceUri ??
           Uri.parse(
             'https://opendata.dwd.de/'
             'climate_environment/health/alerts/s31fg.json',
           );

  final http.Client _httpClient;
  final Uri sourceUri;
  final Duration timeout;

  Future<String> download() async {
    http.Response response;

    try {
      response = await _httpClient.get(sourceUri).timeout(timeout);
    } on Exception catch (error) {
      throw DwdPollenDownloadException(
        'Netzwerkfehler beim Abruf der DWD-Pollendaten.',
        cause: error,
      );
    }

    if (response.statusCode != 200) {
      throw DwdPollenDownloadException(
        'DWD-Pollendaten konnten nicht geladen werden '
        '(HTTP ${response.statusCode}).',
      );
    }

    if (response.body.trim().isEmpty) {
      throw const DwdPollenDownloadException(
        'Die DWD-Datenquelle hat keine Pollendaten geliefert.',
      );
    }

    return response.body;
  }
}
