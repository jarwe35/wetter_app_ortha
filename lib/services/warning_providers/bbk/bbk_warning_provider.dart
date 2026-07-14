import '../../../models/official_weather_warning.dart';
import '../official_warning_provider.dart';
import 'bbk_geojson_parser.dart';
import 'bbk_map_data_parser.dart';
import 'bbk_warning_client.dart';
import 'bbk_warning_converter.dart';
import 'bbk_warning_parser.dart';

class BbkWarningProvider implements OfficialWarningProvider {
  final BbkWarningClient client;
  final BbkMapDataParser mapDataParser;
  final BbkWarningParser warningParser;
  final BbkGeoJsonParser geoJsonParser;
  final BbkWarningConverter converter;
  final DateTime Function() nowProvider;

  /// Technisches Gültigkeitsfenster bis zum nächsten BBK-Abruf.
  ///
  /// Es ist keine amtliche Ablaufzeit. Wenn das BBK kein `expires` liefert,
  /// bleibt eine in MapData vorhandene Warnung damit kurzfristig darstellbar.
  final Duration fallbackValidityDuration;

  BbkWarningProvider({
    required this.client,
    this.mapDataParser = const BbkMapDataParser(),
    this.warningParser = const BbkWarningParser(),
    this.geoJsonParser = const BbkGeoJsonParser(),
    this.converter = const BbkWarningConverter(),
    DateTime Function()? nowProvider,
    this.fallbackValidityDuration = const Duration(minutes: 30),
  }) : nowProvider = nowProvider ?? DateTime.now;

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

    final rawMapData = await client.fetchMapData();
    final mapWarnings = mapDataParser.parse(rawMapData);
    final now = nowProvider();

    final relevantWarnings = <OfficialWeatherWarning>[];

    for (final mapWarning in mapWarnings) {
      if (!mapWarning.isAlertOrUpdate || mapWarning.isCancellation) {
        continue;
      }

      try {
        final rawGeometry = await client.fetchWarningGeometry(mapWarning.id);

        final geometry = geoJsonParser.parse(rawGeometry);

        if (geometry.warningId != mapWarning.id) {
          continue;
        }

        if (!geometry.contains(latitude: latitude, longitude: longitude)) {
          continue;
        }

        final rawDetail = await client.fetchWarningDetail(mapWarning.id);

        if (rawDetail is! Map<String, dynamic>) {
          continue;
        }

        final warning = warningParser.parse(rawDetail);

        if (warning.identifier != mapWarning.id || warning.isCancellation) {
          continue;
        }

        final converted = converter.convert(
          warning,
          fallbackValidFrom: mapWarning.startDate,
          fallbackValidUntil: now.add(fallbackValidityDuration),
        );

        relevantWarnings.add(converted);
      } on BbkWarningClientException {
        // Eine einzelne defekte oder vorübergehend nicht erreichbare Meldung
        // darf die übrigen amtlichen Warnmeldungen nicht blockieren.
        continue;
      } on FormatException {
        // Beschädigte Einzelmeldungen oder Geometrien werden übersprungen.
        continue;
      }
    }

    return List<OfficialWeatherWarning>.unmodifiable(relevantWarnings);
  }
}
