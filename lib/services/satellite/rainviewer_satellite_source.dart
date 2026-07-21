import 'package:http/http.dart' as http;

import '../../models/satellite_layer.dart';
import '../radar/rainviewer_radar_service.dart';
import 'satellite_layer_registry.dart';
import 'satellite_source.dart';

class RainViewerSatelliteSource extends SatelliteSource {
  final RainViewerRadarService radarService;

  RainViewerSatelliteSource({
    RainViewerRadarService? radarService,
    http.Client? httpClient,
  }) : assert(
         radarService == null || httpClient == null,
         'Entweder radarService oder httpClient übergeben, nicht beides.',
       ),
       radarService =
           radarService ??
           RainViewerRadarService(httpClient: httpClient ?? http.Client());

  @override
  String get id => 'rainviewer';

  @override
  String get name => 'RainViewer';

  @override
  List<String> get supportedLayerIds => const ['rainviewer-radar'];

  Future<RainViewerRadarMetadata> loadMetadata({bool forceRefresh = false}) {
    return radarService.fetchMetadata(forceRefresh: forceRefresh);
  }

  String tileUrlTemplate(RainViewerRadarMetadata metadata) {
    return metadata.tileUrlTemplate(frame: metadata.latestFrame);
  }

  @override
  Future<List<SatelliteLayerState>> load({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final metadata = await loadMetadata();
      final latestFrame = metadata.latestFrame;

      return [
        SatelliteLayerState(
          definition: SatelliteLayerRegistry.rainViewerRadar,
          availability: SatelliteLayerAvailability.available,
          isVisible: false,
          observationTimeUtc: latestFrame.time.toUtc(),
          lastUpdatedUtc: metadata.generatedAt.toUtc(),
          statusMessage: metadata.isStale
              ? 'Radar verfügbar – zwischengespeicherter Datenstand'
              : 'Aktuelles Niederschlagsradar verfügbar',
        ),
      ];
    } on RainViewerRadarException catch (error) {
      return [
        SatelliteLayerState(
          definition: SatelliteLayerRegistry.rainViewerRadar,
          availability: SatelliteLayerAvailability.error,
          isVisible: false,
          statusMessage: error.message,
        ),
      ];
    } catch (error) {
      return [
        SatelliteLayerState(
          definition: SatelliteLayerRegistry.rainViewerRadar,
          availability: SatelliteLayerAvailability.error,
          isVisible: false,
          statusMessage: 'Radar konnte nicht geladen werden: $error',
        ),
      ];
    }
  }
}
