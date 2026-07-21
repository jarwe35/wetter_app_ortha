import '../../models/satellite_layer.dart';
import 'satellite_layer_registry.dart';
import 'satellite_source.dart';

class EsriSatelliteSource extends SatelliteSource {
  static const String worldImageryUrlTemplate =
      'https://server.arcgisonline.com/ArcGIS/rest/services/'
      'World_Imagery/MapServer/tile/{z}/{y}/{x}';

  static const String attribution =
      'Tiles © Esri — Source: Esri, Maxar, Earthstar Geographics';

  @override
  String get id => 'esri';

  @override
  String get name => 'Esri World Imagery';

  @override
  List<String> get supportedLayerIds => const ['esri-world-imagery'];

  @override
  Future<List<SatelliteLayerState>> load({
    required double latitude,
    required double longitude,
  }) async {
    return [
      SatelliteLayerState(
        definition: SatelliteLayerRegistry.esriWorldImagery,
        availability: SatelliteLayerAvailability.available,
        isVisible: SatelliteLayerRegistry.esriWorldImagery.enabledByDefault,
        lastUpdatedUtc: DateTime.now().toUtc(),
        statusMessage: 'Satelliten-Basiskarte verfügbar',
      ),
    ];
  }
}
