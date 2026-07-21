import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/satellite/satellite_controller.dart';

void main() {
  group('SatelliteController', () {
    final controller = SatelliteController();

    test('lädt den Standardlayer', () async {
      final result = await controller.loadDefault(
        latitude: 51.2277,
        longitude: 6.7735,
      );

      expect(result, hasLength(1));
      expect(result.single.definition.id, 'esri-world-imagery');
    });

    test('liefert leere Liste bei unbekanntem Layer', () async {
      final result = await controller.loadLayer(
        layerId: 'unknown-layer',
        latitude: 0,
        longitude: 0,
      );

      expect(result, isEmpty);
    });
  });
}
