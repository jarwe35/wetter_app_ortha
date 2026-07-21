import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/satellite_layer.dart';
import 'package:wetter_app_ortha/services/satellite/esri_satellite_source.dart';

void main() {
  group('EsriSatelliteSource', () {
    final source = EsriSatelliteSource();

    test('stellt Quellenmetadaten bereit', () {
      expect(source.id, 'esri');
      expect(source.name, 'Esri World Imagery');
      expect(source.supportedLayerIds, const ['esri-world-imagery']);
    });

    test('unterstützt ausschließlich den Esri-Basislayer', () {
      expect(source.supportsLayer('esri-world-imagery'), isTrue);
      expect(source.supportsLayer('eumetsat-infrared'), isFalse);
      expect(source.supportsLayer('unknown-layer'), isFalse);
    });

    test('stellt eine gültige Tile-URL bereit', () {
      expect(
        EsriSatelliteSource.worldImageryUrlTemplate,
        contains('World_Imagery'),
      );
      expect(
        EsriSatelliteSource.worldImageryUrlTemplate,
        contains('{z}/{y}/{x}'),
      );
      expect(EsriSatelliteSource.attribution, contains('Esri'));
    });

    test('lädt den verfügbaren Satelliten-Basislayer', () async {
      final beforeLoad = DateTime.now().toUtc();

      final states = await source.load(latitude: 51.2277, longitude: 6.7735);

      final afterLoad = DateTime.now().toUtc();

      expect(states, hasLength(1));

      final state = states.single;

      expect(state.definition.id, 'esri-world-imagery');
      expect(state.definition.sourceName, 'Esri World Imagery');
      expect(state.definition.dataFormat, SatelliteLayerDataFormat.tile);
      expect(state.availability, SatelliteLayerAvailability.available);
      expect(state.isVisible, isTrue);
      expect(state.observationTimeUtc, isNull);
      expect(state.lastUpdatedUtc, isNotNull);
      expect(state.lastUpdatedUtc!.isBefore(beforeLoad), isFalse);
      expect(state.lastUpdatedUtc!.isAfter(afterLoad), isFalse);
      expect(state.statusMessage, 'Satelliten-Basiskarte verfügbar');
    });
  });
}
