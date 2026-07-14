import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_client.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_provider.dart';

class TestBbkWarningClient implements BbkWarningClient {
  final dynamic payload;
  int callCount = 0;

  TestBbkWarningClient(this.payload);

  @override
  Future<dynamic> fetchRawWarnings({
    required double latitude,
    required double longitude,
  }) async {
    callCount += 1;
    return payload;
  }

  @override
  Future<dynamic> fetchMapData() async {
    return const [];
  }

  @override
  Future<dynamic> fetchWarningDetail(String warningId) async {
    return const <String, dynamic>{};
  }

  @override
  Future<dynamic> fetchWarningGeometry(String warningId) async {
    return const <String, dynamic>{
      'type': 'FeatureCollection',
      'features': <dynamic>[],
    };
  }
}

void main() {
  group('BbkWarningProvider', () {
    test('unterstützt deutsche Koordinaten', () {
      final provider = BbkWarningProvider(
        client: TestBbkWarningClient(const []),
      );

      expect(
        provider.supportsLocation(latitude: 51.4344, longitude: 6.7623),
        isTrue,
      );
    });

    test('unterstützt New York nicht', () {
      final provider = BbkWarningProvider(
        client: TestBbkWarningClient(const []),
      );

      expect(
        provider.supportsLocation(latitude: 40.7128, longitude: -74.0060),
        isFalse,
      );
    });

    test('ruft bei nicht unterstütztem Ort den Client nicht auf', () async {
      final client = TestBbkWarningClient(const []);

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 40.7128,
        longitude: -74.0060,
      );

      expect(warnings, isEmpty);
      expect(client.callCount, 0);
    });

    test('parst und konvertiert aktive Warnungen', () async {
      final now = DateTime.now();

      final client = TestBbkWarningClient({
        'warnings': [
          {
            'identifier': 'bbk-active-1',
            'senderName': 'Stadt Duisburg',
            'sent': now.subtract(const Duration(hours: 1)).toIso8601String(),
            'msgType': 'Alert',
            'info': [
              {
                'headline': 'Rauchentwicklung',
                'description': 'Im Stadtgebiet kommt es zu Rauch.',
                'instruction': 'Fenster geschlossen halten.',
                'severity': 'Severe',
                'effective': now
                    .subtract(const Duration(minutes: 30))
                    .toIso8601String(),
                'expires': now.add(const Duration(hours: 2)).toIso8601String(),
                'area': [
                  {
                    'areaDesc': 'Duisburg',
                    'geocode': [
                      {'valueName': 'ARS', 'value': '051120000000'},
                    ],
                  },
                ],
              },
            ],
          },
        ],
      });

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, hasLength(1));
      expect(warnings.single.id, 'bbk-active-1');
      expect(warnings.single.title, 'Rauchentwicklung');
      expect(warnings.single.source, 'Stadt Duisburg');
      expect(warnings.single.areaDescriptions, ['Duisburg']);
    });

    test('filtert abgelaufene Warnungen', () async {
      final now = DateTime.now();

      final client = TestBbkWarningClient({
        'warnings': [
          {
            'identifier': 'bbk-expired-1',
            'sent': now.subtract(const Duration(hours: 4)).toIso8601String(),
            'msgType': 'Alert',
            'info': [
              {
                'headline': 'Abgelaufene Warnung',
                'severity': 'Moderate',
                'effective': now
                    .subtract(const Duration(hours: 3))
                    .toIso8601String(),
                'expires': now
                    .subtract(const Duration(hours: 1))
                    .toIso8601String(),
              },
            ],
          },
        ],
      });

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
    });

    test('filtert Entwarnungen', () async {
      final now = DateTime.now();

      final client = TestBbkWarningClient({
        'warnings': [
          {
            'identifier': 'bbk-cancel-1',
            'sent': now.toIso8601String(),
            'msgType': 'Cancel',
            'info': [
              {
                'headline': 'Entwarnung: Rauchentwicklung',
                'severity': 'Minor',
                'effective': now.toIso8601String(),
                'expires': now.add(const Duration(hours: 1)).toIso8601String(),
              },
            ],
          },
        ],
      });

      final provider = BbkWarningProvider(client: client);

      final warnings = await provider.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
    });
  });
}
