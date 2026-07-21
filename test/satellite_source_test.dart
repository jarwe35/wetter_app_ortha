import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/satellite_layer.dart';
import 'package:wetter_app_ortha/services/satellite/satellite_source.dart';

class _TestSatelliteSource extends SatelliteSource {
  @override
  String get id => 'test-source';

  @override
  String get name => 'Test Source';

  @override
  List<String> get supportedLayerIds => const [
    'esri-world-imagery',
    'test-overlay',
  ];

  @override
  Future<List<SatelliteLayerState>> load({
    required double latitude,
    required double longitude,
  }) async {
    const definition = SatelliteLayerDefinition(
      id: 'test-overlay',
      type: SatelliteLayerType.orthaRisk,
      name: 'Test Overlay',
      description: 'Testdaten für den SatelliteSource-Vertrag.',
      sourceName: 'Test Source',
      dataFormat: SatelliteLayerDataFormat.generatedOverlay,
    );

    return [
      SatelliteLayerState(
        definition: definition,
        availability: SatelliteLayerAvailability.available,
        observationTimeUtc: DateTime.utc(2026, 7, 21, 6),
        lastUpdatedUtc: DateTime.utc(2026, 7, 21, 6, 5),
      ),
    ];
  }
}

void main() {
  group('SatelliteSource', () {
    final source = _TestSatelliteSource();

    test('stellt eine eindeutige Quellenkennung bereit', () {
      expect(source.id, 'test-source');
      expect(source.name, 'Test Source');
    });

    test('erkennt unterstützte Layer', () {
      expect(source.supportsLayer('esri-world-imagery'), isTrue);
      expect(source.supportsLayer('test-overlay'), isTrue);
      expect(source.supportsLayer('unknown-layer'), isFalse);
    });

    test('liefert SatelliteLayerState-Objekte', () async {
      final states = await source.load(latitude: 51.2277, longitude: 6.7735);

      expect(states, hasLength(1));
      expect(states.single.definition.id, 'test-overlay');
      expect(states.single.availability, SatelliteLayerAvailability.available);
      expect(states.single.observationTimeUtc, isNotNull);
      expect(states.single.lastUpdatedUtc, isNotNull);
    });
  });
}
