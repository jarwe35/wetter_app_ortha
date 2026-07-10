import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/warning_providers/dwd_warning_provider.dart';

void main() {
  group('DwdWarningProvider', () {
    const provider = DwdWarningProvider();

    test('besitzt eindeutige Providerkennung', () {
      expect(provider.providerId, 'dwd');
      expect(provider.sourceName, 'Deutscher Wetterdienst');
    });

    test('unterstützt Duisburg', () {
      expect(
        provider.supportsLocation(latitude: 51.4344, longitude: 6.7623),
        isTrue,
      );
    });

    test('unterstützt Berlin', () {
      expect(
        provider.supportsLocation(latitude: 52.5200, longitude: 13.4050),
        isTrue,
      );
    });

    test('unterstützt Dinard nicht', () {
      expect(
        provider.supportsLocation(latitude: 48.6329, longitude: -2.0617),
        isFalse,
      );
    });

    test('unterstützt Wien nicht', () {
      expect(
        provider.supportsLocation(latitude: 48.2082, longitude: 16.3738),
        isFalse,
      );
    });

    test(
      'liefert vor Anbindung der Datenquelle eine leere Warnungsliste',
      () async {
        final warnings = await provider.fetchWarnings(
          latitude: 51.4344,
          longitude: 6.7623,
        );

        expect(warnings, isEmpty);
      },
    );
  });
}
