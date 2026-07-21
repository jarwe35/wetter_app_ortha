import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/satellite/satellite_source_registry.dart';

void main() {
  group('SatelliteSourceRegistry', () {
    test('enthält mindestens eine Datenquelle', () {
      expect(SatelliteSourceRegistry.sources, isNotEmpty);
    });

    test('findet die Esri-Quelle', () {
      final source = SatelliteSourceRegistry.findById('esri');

      expect(source, isNotNull);
      expect(source!.name, 'Esri World Imagery');
    });

    test('liefert den Provider für den Basislayer', () {
      final providers = SatelliteSourceRegistry.findSupportingLayer(
        'esri-world-imagery',
      );

      expect(providers, hasLength(1));
      expect(providers.single.id, 'esri');
    });

    test('liefert keine Quelle bei unbekanntem Layer', () {
      expect(
        SatelliteSourceRegistry.findSupportingLayer('unknown-layer'),
        isEmpty,
      );
    });
  });
}
