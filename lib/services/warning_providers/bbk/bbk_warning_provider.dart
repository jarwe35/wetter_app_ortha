import '../../../models/official_weather_warning.dart';
import '../official_warning_provider.dart';
import 'bbk_warning_client.dart';
import 'bbk_warning_converter.dart';
import 'bbk_warning_parser.dart';

class BbkWarningProvider implements OfficialWarningProvider {
  final BbkWarningClient client;
  final BbkWarningParser parser;
  final BbkWarningConverter converter;

  const BbkWarningProvider({
    required this.client,
    this.parser = const BbkWarningParser(),
    this.converter = const BbkWarningConverter(),
  });

  @override
  String get providerId => 'bbk';

  @override
  String get sourceName => 'BBK / warnung.bund.de';

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
    if (!supportsLocation(latitude: latitude, longitude: longitude)) {
      return const [];
    }

    final rawWarnings = await client.fetchRawWarnings(
      latitude: latitude,
      longitude: longitude,
    );

    final parsedWarnings = parser.parseList(rawWarnings);

    final activeWarnings = parsedWarnings.where(
      (warning) => warning.isActiveAt(DateTime.now()),
    );

    return converter.convertAll(activeWarnings);
  }
}
