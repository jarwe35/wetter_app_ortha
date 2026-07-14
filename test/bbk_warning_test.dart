import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/warning_bridge/bbk_warning.dart';

void main() {
  group('BbkWarning', () {
    test('erkennt aktive Warnung innerhalb des Gültigkeitszeitraums', () {
      final warning = BbkWarning(
        identifier: 'mow.DE-NW-DU-test-1',
        headline: 'Rauchentwicklung',
        description: 'Im Stadtgebiet tritt Rauch auf.',
        instruction: 'Fenster und Türen geschlossen halten.',
        sender: 'Stadt Duisburg',
        severity: 'Severe',
        urgency: 'Immediate',
        certainty: 'Observed',
        messageType: 'Alert',
        sent: DateTime.utc(2026, 7, 14, 8),
        effective: DateTime.utc(2026, 7, 14, 8),
        expires: DateTime.utc(2026, 7, 14, 12),
        areaDescriptions: const ['Duisburg'],
      );

      expect(warning.isActiveAt(DateTime.utc(2026, 7, 14, 10)), isTrue);
    });

    test('erkennt abgelaufene Warnung', () {
      final warning = BbkWarning(
        identifier: 'mow.DE-NW-DU-test-2',
        headline: 'Gefahreninformation',
        description: 'Test',
        instruction: '',
        sender: 'Stadt Duisburg',
        severity: 'Moderate',
        urgency: 'Expected',
        certainty: 'Likely',
        messageType: 'Alert',
        sent: DateTime.utc(2026, 7, 14, 8),
        effective: DateTime.utc(2026, 7, 14, 8),
        expires: DateTime.utc(2026, 7, 14, 9),
      );

      expect(warning.isActiveAt(DateTime.utc(2026, 7, 14, 10)), isFalse);
    });

    test('erkennt Entwarnung über messageType', () {
      const warning = BbkWarning(
        identifier: 'mow.DE-NW-DU-test-3',
        headline: 'Gefahr beendet',
        description: 'Es besteht keine Gefahr mehr.',
        instruction: '',
        sender: 'Stadt Duisburg',
        severity: 'Minor',
        urgency: 'Past',
        certainty: 'Observed',
        messageType: 'Cancel',
        sent: null,
        effective: null,
        expires: null,
      );

      expect(warning.isCancellation, isTrue);
      expect(warning.isActiveAt(DateTime.utc(2026, 7, 14)), isFalse);
    });

    test('erkennt Entwarnung anhand der Überschrift', () {
      const warning = BbkWarning(
        identifier: 'mow.DE-NW-DU-test-4',
        headline: 'Entwarnung: Rauchentwicklung',
        description: 'Die Warnung wurde aufgehoben.',
        instruction: '',
        sender: 'Stadt Duisburg',
        severity: 'Minor',
        urgency: 'Past',
        certainty: 'Observed',
        messageType: 'Update',
        sent: null,
        effective: null,
        expires: null,
      );

      expect(warning.isCancellation, isTrue);
    });

    test('erkennt vorhandene Polygongeometrie', () {
      const warning = BbkWarning(
        identifier: 'mow.DE-NW-DU-test-5',
        headline: 'Gefahreninformation',
        description: 'Test',
        instruction: '',
        sender: 'Stadt Duisburg',
        severity: 'Moderate',
        urgency: 'Expected',
        certainty: 'Likely',
        messageType: 'Alert',
        sent: null,
        effective: null,
        expires: null,
        polygons: ['51.4,6.7 51.5,6.7 51.5,6.8 51.4,6.7'],
      );

      expect(warning.hasGeometry, isTrue);
    });
  });
}
