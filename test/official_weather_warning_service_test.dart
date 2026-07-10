import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/official_weather_warning_service.dart';

void main() {
  group('EmptyOfficialWeatherWarningService', () {
    test('liefert eine leere Warnungsliste', () async {
      const service = EmptyOfficialWeatherWarningService();

      final warnings = await service.fetchWarnings(
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(warnings, isEmpty);
    });

    test(
      'liefert für unterschiedliche Koordinaten weiterhin eine leere Liste',
      () async {
        const service = EmptyOfficialWeatherWarningService();

        final duisburgWarnings = await service.fetchWarnings(
          latitude: 51.4344,
          longitude: 6.7623,
        );

        final dinardWarnings = await service.fetchWarnings(
          latitude: 48.6329,
          longitude: -2.0617,
        );

        expect(duisburgWarnings, isEmpty);
        expect(dinardWarnings, isEmpty);
      },
    );
  });
}
