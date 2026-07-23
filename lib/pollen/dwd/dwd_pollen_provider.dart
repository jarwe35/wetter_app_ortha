import '../../models/pollen_forecast.dart';
import '../models/pollen_provider.dart';
import 'dwd_pollen_download_client.dart';
import 'dwd_pollen_forecast_mapper.dart';
import 'dwd_pollen_parser.dart';
import 'dwd_pollen_region_locator.dart';

class DwdPollenProvider implements PollenProvider {
  DwdPollenProvider({
    required this.regionLocator,
    DwdPollenDownloadClient? downloadClient,
    this.parser = const DwdPollenParser(),
    this.mapper = const DwdPollenForecastMapper(),
    DateTime Function()? clock,
  }) : downloadClient = downloadClient ?? DwdPollenDownloadClient(),
       _clock = clock ?? DateTime.now;

  final DwdPollenDownloadClient downloadClient;
  final DwdPollenParser parser;
  final DwdPollenRegionLocator regionLocator;
  final DwdPollenForecastMapper mapper;
  final DateTime Function() _clock;

  @override
  String get id => 'dwd-pollen';

  @override
  String get displayName => 'Deutscher Wetterdienst';

  @override
  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final source = await downloadClient.download();
      final dataset = parser.parseString(source);

      final region = regionLocator.locate(
        latitude: latitude,
        longitude: longitude,
        dataset: dataset,
      );

      final referenceDate = dataset.lastUpdate ?? _clock();

      return mapper.map(
        region: region,
        latitude: latitude,
        longitude: longitude,
        referenceDate: referenceDate,
      );
    } on PollenProviderException {
      rethrow;
    } on DwdPollenDownloadException catch (error) {
      throw PollenProviderException(
        providerId: id,
        message: error.message,
        cause: error,
      );
    } on DwdPollenParseException catch (error) {
      throw PollenProviderException(
        providerId: id,
        message: error.message,
        cause: error,
      );
    } on DwdPollenRegionLocatorException catch (error) {
      throw PollenProviderException(
        providerId: id,
        message: error.message,
        cause: error,
      );
    } on Exception catch (error) {
      throw PollenProviderException(
        providerId: id,
        message: 'Die DWD-Pollenvorhersage konnte nicht verarbeitet werden.',
        cause: error,
      );
    }
  }
}
