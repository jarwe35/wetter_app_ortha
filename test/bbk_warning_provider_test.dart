import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_client.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_provider.dart';

class TestBbkWarningClient implements BbkWarningClient {
  final dynamic mapData;
  final Map<String, dynamic> details;
  final Map<String, dynamic> geometries;
  final Set<String> failingDetailIds;
  final Set<String> failingGeometryIds;

  int mapDataCallCount = 0;
  final List<String> detailCalls = [];
  final List<String> geometryCalls = [];

  TestBbkWarningClient({
    required this.mapData,
    this.details = const {},
    this.geometries = const {},
    this.failingDetailIds = const {},
    this.failingGeometryIds = const {},
  });

  @override
  Future<dynamic> fetchMapData() async {
    mapDataCallCount++;
    return mapData;
  }

  @override
  Future<dynamic> fetchWarningDetail(String warningId) async {
    detailCalls.add(warningId);

    if (failingDetailIds.contains(warningId)) {
      throw const BbkWarningClientException('Simulierter Detailfehler');
    }

    return details[warningId] ?? const <String, dynamic>{};
  }

  @override
  Future<dynamic> fetchWarningGeometry(String warningId) async {
    geometryCalls.add(warningId);

    if (failingGeometryIds.contains(warningId)) {
      throw const BbkWarningClientException('Simulierter Geometriefehler');
    }

    return geometries[warningId] ??
        const <String, dynamic>{
          'type': 'FeatureCollection',
          'features': <dynamic>[],
        };
  }

  @override
  Future<dynamic> fetchRawWarnings({
    required double latitude,
    required double longitude,
  }) async {
    return const [];
  }
}

Map<String, dynamic> createMapEntry({
  required String id,
  String type = 'Alert',
  String severity = 'Severe',
}) {
  return {
    'id': id,
    'version': 1,
    'startDate': '2026-07-14T10:00:00+02:00',
    'severity': severity,
    'urgency': 'Immediate',
    'type': type,
    'i18nTitle': {'de': 'MapData-Titel'},
  };
}

Map<String, dynamic> createDetail({
  required String id,
  String messageType = 'Alert',
  String headline = 'Rauchentwicklung',
  String severity = 'Severe',
  bool includeExpiry = true,
}) {
  return {
    'identifier': id,
    'sender': 'Stadt Duisburg',
    'sent': '2026-07-14T10:00:00+02:00',
    'msgType': messageType,
    'info': [
      {
        'language': 'de',
        'headline': headline,
        'description': 'Amtliche Beschreibung',
        'instruction': 'Fenster und Türen geschlossen halten.',
        'severity': severity,
        'urgency': 'Immediate',
        'certainty': 'Observed',
        if (includeExpiry) 'expires': '2026-07-14T18:00:00+02:00',
        'area': [
          {
            'areaDesc': 'Stadt Duisburg',
            'geocode': [
              {'valueName': 'ARS', 'value': '051120000000'},
            ],
          },
        ],
      },
    ],
  };
}

Map<String, dynamic> createGeometry({
  required String id,
  double minimumLongitude = 6.0,
  double minimumLatitude = 51.0,
  double maximumLongitude = 7.0,
  double maximumLatitude = 52.0,
}) {
  return {
    'type': 'FeatureCollection',
    'features': [
      {
        'type': 'Feature',
        'properties': {'warnId': id, 'areaId': 0},
        'geometry': {
          'type': 'Polygon',
          'coordinates': [
            [
              [minimumLongitude, minimumLatitude],
              [maximumLongitude, minimumLatitude],
              [maximumLongitude, maximumLatitude],
              [minimumLongitude, maximumLatitude],
              [minimumLongitude, minimumLatitude],
            ],
          ],
        },
      },
    ],
  };
}

void main() {
  group('BbkWarningProvider reale MoWaS-Kette', () {
    test('unterstützt deutsche Koordinaten', () {
      final provider = BbkWarningProvider(
        client: TestBbkWarningClient(mapData: const []),
      );

      expect(
        provider.supportsLocation(latitude: 51.4344, longitude: 6.7623),
        isTrue,
      );
    });

    test('unterstützt New York nicht', () {
      final provider = BbkWarningProvider(
        client: TestBbkWarningClient(mapData: const []),
      );

      expect(
        provider.supportsLocation(latitude: 40.7128, longitude: -74.0060),
        isFalse,
      );
    });

    test('ruft für nicht unterstützten Ort keine BBK-Daten ab', () async {
      final client = TestBbkWarningClient(mapData: const []);
      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(warnings, isEmpty);
      expect(client.mapDataCallCount, 0);
    });

    test('liefert leere Liste bei leerer MapData', () async {
      final client = TestBbkWarningClient(mapData: const []);
      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
      expect(client.mapDataCallCount, 1);
      expect(client.geometryCalls, isEmpty);
      expect(client.detailCalls, isEmpty);
    });

    test('ordnet reale Warnung über GeoJSON dem Ort zu', () async {
      const id = 'mow.DE-NW-DU-test-1';

      final client = TestBbkWarningClient(
        mapData: [createMapEntry(id: id)],
        geometries: {id: createGeometry(id: id)},
        details: {id: createDetail(id: id)},
      );

      final provider = BbkWarningProvider(
        client: client,
        nowProvider: () => DateTime.utc(2026, 7, 14, 12),
      );

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, hasLength(1));

      final warning = warnings.single;

      expect(warning.id, id);
      expect(warning.title, 'Rauchentwicklung');
      expect(warning.source, 'Stadt Duisburg');
      expect(warning.severity, OfficialWarningSeverity.severe);
      expect(warning.areaDescriptions, ['Stadt Duisburg']);
      expect(warning.geocodes['ARS'], '051120000000');

      expect(client.geometryCalls, [id]);
      expect(client.detailCalls, [id]);
    });

    test('lädt Detaildaten nur bei geografisch relevantem Polygon', () async {
      const id = 'mow.DE-SL-test-outside';

      final client = TestBbkWarningClient(
        mapData: [createMapEntry(id: id)],
        geometries: {
          id: createGeometry(
            id: id,
            minimumLongitude: 10.0,
            minimumLatitude: 48.0,
            maximumLongitude: 11.0,
            maximumLatitude: 49.0,
          ),
        },
        details: {id: createDetail(id: id)},
      );

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
      expect(client.geometryCalls, [id]);
      expect(client.detailCalls, isEmpty);
    });

    test('überspringt Cancel-Einträge bereits in MapData', () async {
      const id = 'mow.cancel-mapdata';

      final client = TestBbkWarningClient(
        mapData: [createMapEntry(id: id, type: 'Cancel')],
      );

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
      expect(client.geometryCalls, isEmpty);
      expect(client.detailCalls, isEmpty);
    });

    test('überspringt Entwarnung im Detaildatensatz', () async {
      const id = 'mow.cancel-detail';

      final client = TestBbkWarningClient(
        mapData: [createMapEntry(id: id, type: 'Update')],
        geometries: {id: createGeometry(id: id)},
        details: {
          id: createDetail(
            id: id,
            messageType: 'Cancel',
            headline: 'Entwarnung: Rauchentwicklung',
          ),
        },
      );

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
    });

    test('nutzt technisches Gültigkeitsfenster wenn expires fehlt', () async {
      const id = 'mow.no-expiry';
      final now = DateTime.utc(2026, 7, 14, 12);

      final client = TestBbkWarningClient(
        mapData: [createMapEntry(id: id)],
        geometries: {id: createGeometry(id: id)},
        details: {id: createDetail(id: id, includeExpiry: false)},
      );

      final provider = BbkWarningProvider(
        client: client,
        nowProvider: () => now,
        fallbackValidityDuration: const Duration(minutes: 30),
      );

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, hasLength(1));
      expect(warnings.single.validUntil, now.add(const Duration(minutes: 30)));
    });

    test('Fehler einer Einzelwarnung blockiert andere Warnung nicht', () async {
      const failingId = 'mow.failing';
      const validId = 'mow.valid';

      final client = TestBbkWarningClient(
        mapData: [
          createMapEntry(id: failingId),
          createMapEntry(id: validId),
        ],
        failingGeometryIds: const {failingId},
        geometries: {validId: createGeometry(id: validId)},
        details: {validId: createDetail(id: validId)},
      );

      final provider = BbkWarningProvider(
        client: client,
        nowProvider: () => DateTime.utc(2026, 7, 14, 12),
      );

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, hasLength(1));
      expect(warnings.single.id, validId);
    });

    test('überspringt Geometrie mit abweichender Warn-ID', () async {
      const mapId = 'mow.expected';
      const geometryId = 'mow.other';

      final client = TestBbkWarningClient(
        mapData: [createMapEntry(id: mapId)],
        geometries: {mapId: createGeometry(id: geometryId)},
        details: {mapId: createDetail(id: mapId)},
      );

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
      expect(client.detailCalls, isEmpty);
    });
  });
}
