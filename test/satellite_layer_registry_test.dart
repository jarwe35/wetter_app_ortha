import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/satellite_layer.dart';
import 'package:wetter_app_ortha/services/satellite/satellite_layer_registry.dart';

void main() {
  group('SatelliteLayerRegistry', () {
    test('enthält eindeutige Layer-IDs', () {
      final ids = SatelliteLayerRegistry.definitions
          .map((definition) => definition.id)
          .toList();

      expect(ids.toSet().length, ids.length);
    });

    test('findet Layer über ID', () {
      final result = SatelliteLayerRegistry.findById('esri-world-imagery');

      expect(result, isNotNull);
      expect(result!.type, SatelliteLayerType.baseMap);
      expect(result.sourceName, 'Esri World Imagery');
    });

    test('liefert null bei unbekannter ID', () {
      final result = SatelliteLayerRegistry.findById('unknown-layer');

      expect(result, isNull);
    });

    test('filtert Layer nach Typ', () {
      final results = SatelliteLayerRegistry.findByType(
        SatelliteLayerType.infrared,
      );

      expect(results, hasLength(1));
      expect(results.single.id, 'eumetsat-infrared');
    });

    test('erstellt einen Initialzustand für jeden Layer', () {
      final states = SatelliteLayerRegistry.createInitialStates();

      expect(states, hasLength(SatelliteLayerRegistry.definitions.length));
      expect(
        states.map((state) => state.definition.id).toSet(),
        SatelliteLayerRegistry.definitions
            .map((definition) => definition.id)
            .toSet(),
      );
    });

    test('aktiviert nur die Basiskarte standardmäßig', () {
      final states = SatelliteLayerRegistry.createInitialStates();

      final visibleStates = states
          .where((state) => state.isVisible)
          .toList(growable: false);

      expect(visibleStates, hasLength(1));
      expect(visibleStates.single.definition.id, 'esri-world-imagery');
      expect(
        visibleStates.single.availability,
        SatelliteLayerAvailability.available,
      );
    });

    test('weitere Datenlayer beginnen als nicht verfügbar', () {
      final states = SatelliteLayerRegistry.createInitialStates();

      final dataStates = states.where(
        (state) => state.definition.id != 'esri-world-imagery',
      );

      expect(
        dataStates.every(
          (state) =>
              state.availability == SatelliteLayerAvailability.unavailable &&
              !state.isVisible,
        ),
        isTrue,
      );
    });
  });
}
