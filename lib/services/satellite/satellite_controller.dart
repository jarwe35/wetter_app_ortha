import '../../models/satellite_layer.dart';
import 'satellite_source_registry.dart';

class SatelliteController {
  Future<List<SatelliteLayerState>> loadLayer({
    required String layerId,
    required double latitude,
    required double longitude,
  }) async {
    final providers = SatelliteSourceRegistry.findSupportingLayer(layerId);

    if (providers.isEmpty) {
      return const [];
    }

    return providers.first.load(latitude: latitude, longitude: longitude);
  }

  Future<List<SatelliteLayerState>> loadDefault({
    required double latitude,
    required double longitude,
  }) {
    return loadLayer(
      layerId: 'esri-world-imagery',
      latitude: latitude,
      longitude: longitude,
    );
  }
}
