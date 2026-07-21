import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/satellite_layer.dart';

void main() {
  group('SatelliteLayerDefinition', () {
    const definition = SatelliteLayerDefinition(
      id: 'dwd-cloud-top-height',
      type: SatelliteLayerType.cloudTopHeight,
      name: 'Wolkenobergrenze',
      description: 'Höhe der Wolkenobergrenze',
      sourceName: 'DWD Open Data',
      dataFormat: SatelliteLayerDataFormat.netCdf,
      requiresLegend: true,
    );

    test('speichert technische Metadaten', () {
      expect(definition.id, 'dwd-cloud-top-height');
      expect(definition.type, SatelliteLayerType.cloudTopHeight);
      expect(definition.sourceName, 'DWD Open Data');
      expect(definition.dataFormat, SatelliteLayerDataFormat.netCdf);
      expect(definition.requiresLegend, isTrue);
      expect(definition.requiresTimestamp, isTrue);
      expect(definition.enabledByDefault, isFalse);
    });

    test('copyWith verändert nur angegebene Werte', () {
      final changed = definition.copyWith(enabledByDefault: true);

      expect(changed.enabledByDefault, isTrue);
      expect(changed.id, definition.id);
      expect(changed.type, definition.type);
      expect(changed.dataFormat, definition.dataFormat);
    });
  });

  group('SatelliteLayerState', () {
    const definition = SatelliteLayerDefinition(
      id: 'satellite-base-map',
      type: SatelliteLayerType.baseMap,
      name: 'Satelliten-Basiskarte',
      description: 'Geografische Satellitenkarte',
      sourceName: 'Esri World Imagery',
      dataFormat: SatelliteLayerDataFormat.tile,
      enabledByDefault: true,
      requiresTimestamp: false,
    );

    test('ist standardmäßig nicht verfügbar und nicht sichtbar', () {
      const state = SatelliteLayerState(definition: definition);

      expect(state.availability, SatelliteLayerAvailability.unavailable);
      expect(state.isVisible, isFalse);
      expect(state.observationTimeUtc, isNull);
      expect(state.lastUpdatedUtc, isNull);
    });

    test('kann Verfügbarkeit und Sichtbarkeit aktualisieren', () {
      const state = SatelliteLayerState(definition: definition);

      final updated = state.copyWith(
        availability: SatelliteLayerAvailability.available,
        isVisible: true,
        lastUpdatedUtc: DateTime.utc(2026, 7, 21, 6, 30),
      );

      expect(updated.availability, SatelliteLayerAvailability.available);
      expect(updated.isVisible, isTrue);
      expect(updated.lastUpdatedUtc, DateTime.utc(2026, 7, 21, 6, 30));
    });

    test('kann optionale Statuswerte gezielt löschen', () {
      final state = SatelliteLayerState(
        definition: definition,
        observationTimeUtc: DateTime.utc(2026, 7, 21, 6),
        statusMessage: 'Aktuell',
      );

      final cleared = state.copyWith(
        clearObservationTime: true,
        clearStatusMessage: true,
      );

      expect(cleared.observationTimeUtc, isNull);
      expect(cleared.statusMessage, isNull);
    });
  });
}
