import '../../models/satellite_layer.dart';

abstract class SatelliteSource {
  String get id;

  String get name;

  List<String> get supportedLayerIds;

  bool supportsLayer(String layerId) {
    return supportedLayerIds.contains(layerId);
  }

  Future<List<SatelliteLayerState>> load({
    required double latitude,
    required double longitude,
  });
}
