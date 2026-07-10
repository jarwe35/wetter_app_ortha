import '../../models/official_weather_warning.dart';
import 'dwd_cap_download_client.dart';
import 'dwd_cap_parser.dart';
import 'dwd_cap_zip_decoder.dart';
import 'dwd_warning_location_filter.dart';
import 'official_warning_provider.dart';

class DwdWarningProvider implements OfficialWarningProvider {
  final DwdCapDownloadClient? downloadClient;
  final DwdCapZipDecoder zipDecoder;
  final DwdCapParser parser;
  final DwdWarningLocationFilter locationFilter;

  const DwdWarningProvider({
    this.downloadClient,
    this.zipDecoder = const DwdCapZipDecoder(),
    this.parser = const DwdCapParser(),
    this.locationFilter = const DwdWarningLocationFilter(),
  });

  @override
  String get providerId => 'dwd';

  @override
  String get sourceName => 'Deutscher Wetterdienst';

  @override
  bool supportsLocation({required double latitude, required double longitude}) {
    return latitude >= 47.0 &&
        latitude <= 55.5 &&
        longitude >= 5.5 &&
        longitude <= 15.5;
  }

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    final client = downloadClient;

    if (client == null) {
      return const [];
    }

    final zipBytes = await client.download();
    final xmlDocuments = zipDecoder.decode(zipBytes);

    final warnings = <OfficialWeatherWarning>[];

    for (final xmlDocument in xmlDocuments) {
      warnings.addAll(parser.parse(xmlDocument));
    }

    return locationFilter.filterForLocation(
      warnings: warnings,
      latitude: latitude,
      longitude: longitude,
    );
  }
}
