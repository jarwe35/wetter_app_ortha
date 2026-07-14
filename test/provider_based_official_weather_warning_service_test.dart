import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/official_weather_warning.dart';
import 'package:wetter_app_ortha/services/provider_based_official_weather_warning_service.dart';
import 'package:wetter_app_ortha/services/warning_providers/official_warning_provider.dart';

class TestWarningProvider implements OfficialWarningProvider {
  final String id;
  final bool supported;
  final List<OfficialWeatherWarning> warnings;

  const TestWarningProvider({
    required this.id,
    required this.supported,
    required this.warnings,
  });

  @override
  String get providerId => id;

  @override
  String get sourceName => 'Testquelle $id';

  @override
  bool supportsLocation({required double latitude, required double longitude}) {
    return supported;
  }

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    return warnings;
  }
}

void main() {
  test(
    'supportsLocation ist true wenn mindestens ein Provider unterstützt',
    () {
      final service = ProviderBasedOfficialWeatherWarningService(
        providers: [
          TestWarningProvider(
            id: 'unsupported',
            supported: false,
            warnings: const [],
          ),
          TestWarningProvider(
            id: 'supported',
            supported: true,
            warnings: const [],
          ),
        ],
      );

      expect(
        service.supportsLocation(latitude: 51.4344, longitude: 6.7623),
        isTrue,
      );
    },
  );

  test('supportsLocation ist false wenn kein Provider unterstützt', () {
    final service = ProviderBasedOfficialWeatherWarningService(
      providers: [
        TestWarningProvider(
          id: 'unsupported',
          supported: false,
          warnings: const [],
        ),
      ],
    );

    expect(
      service.supportsLocation(latitude: 40.7128, longitude: -74.0060),
      isFalse,
    );
  });

  OfficialWeatherWarning createWarning({
    required String id,
    required OfficialWarningSeverity severity,
  }) {
    final now = DateTime.now();

    return OfficialWeatherWarning(
      id: id,
      title: 'Warnung $id',
      description: 'Testwarnung',
      instruction: 'Vorsicht',
      source: 'Testquelle',
      severity: severity,
      validFrom: now.subtract(const Duration(hours: 1)),
      validUntil: now.add(const Duration(hours: 1)),
    );
  }

  group('ProviderBasedOfficialWeatherWarningService', () {
    test('fragt nur unterstützte Provider ab', () async {
      final service = ProviderBasedOfficialWeatherWarningService(
        providers: [
          TestWarningProvider(
            id: 'supported',
            supported: true,
            warnings: [
              createWarning(
                id: 'warning-1',
                severity: OfficialWarningSeverity.moderate,
              ),
            ],
          ),
          TestWarningProvider(
            id: 'unsupported',
            supported: false,
            warnings: [
              createWarning(
                id: 'warning-2',
                severity: OfficialWarningSeverity.extreme,
              ),
            ],
          ),
        ],
      );

      final warnings = await service.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, hasLength(1));
      expect(warnings.single.id, 'warning-1');
    });

    test('führt Warnungen mehrerer Provider zusammen', () async {
      final service = ProviderBasedOfficialWeatherWarningService(
        providers: [
          TestWarningProvider(
            id: 'provider-a',
            supported: true,
            warnings: [
              createWarning(
                id: 'warning-a',
                severity: OfficialWarningSeverity.minor,
              ),
            ],
          ),
          TestWarningProvider(
            id: 'provider-b',
            supported: true,
            warnings: [
              createWarning(
                id: 'warning-b',
                severity: OfficialWarningSeverity.severe,
              ),
            ],
          ),
        ],
      );

      final warnings = await service.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, hasLength(2));
      expect(warnings.first.id, 'warning-b');
      expect(warnings.last.id, 'warning-a');
    });

    test('liefert leere Liste ohne Provider', () async {
      const service = ProviderBasedOfficialWeatherWarningService(providers: []);

      final warnings = await service.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
    });
  });
}
