import 'esri_satellite_source.dart';
import 'rainviewer_satellite_source.dart';
import 'satellite_source.dart';

abstract final class SatelliteSourceRegistry {
  static final List<SatelliteSource> sources = [
    EsriSatelliteSource(),
    RainViewerSatelliteSource(),
  ];

  static SatelliteSource? findById(String id) {
    for (final source in sources) {
      if (source.id == id) {
        return source;
      }
    }
    return null;
  }

  static List<SatelliteSource> findSupportingLayer(String layerId) {
    return sources
        .where((source) => source.supportsLayer(layerId))
        .toList(growable: false);
  }
}
