import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/warning_bridge/bbk_map_warning.dart';

void main() {
  group('BbkMapWarning', () {
    test('liefert bevorzugt deutschen Titel', () {
      final warning = BbkMapWarning(
        id: 'mow.test-1',
        version: 1,
        startDate: DateTime.utc(2026, 7, 14),
        severity: 'Minor',
        urgency: 'Immediate',
        type: 'Alert',
        titles: const {'en': 'English title', 'de': 'Deutscher Titel'},
        translationKeys: const {'event': 'BBK-EVC-001'},
      );

      expect(warning.germanTitle, 'Deutscher Titel');
    });

    test('verwendet ersten Titel als Fallback', () {
      final warning = BbkMapWarning(
        id: 'mow.test-2',
        version: 1,
        startDate: DateTime.utc(2026, 7, 14),
        severity: 'Minor',
        urgency: 'Immediate',
        type: 'Update',
        titles: const {'en': 'Fallback title'},
        translationKeys: const {},
      );

      expect(warning.germanTitle, 'Fallback title');
    });

    test('verwendet ID wenn kein Titel vorhanden ist', () {
      final warning = BbkMapWarning(
        id: 'mow.test-3',
        version: 1,
        startDate: DateTime.utc(2026, 7, 14),
        severity: 'Minor',
        urgency: 'Immediate',
        type: 'Alert',
        titles: const {},
        translationKeys: const {},
      );

      expect(warning.germanTitle, 'mow.test-3');
    });

    test('erkennt Alert und Update als aktive Meldungstypen', () {
      BbkMapWarning create(String type) {
        return BbkMapWarning(
          id: 'mow.test',
          version: 1,
          startDate: DateTime.utc(2026, 7, 14),
          severity: 'Minor',
          urgency: 'Immediate',
          type: type,
          titles: const {},
          translationKeys: const {},
        );
      }

      expect(create('Alert').isAlertOrUpdate, isTrue);
      expect(create('Update').isAlertOrUpdate, isTrue);
      expect(create('Cancel').isAlertOrUpdate, isFalse);
    });

    test('erkennt Cancel als Entwarnung', () {
      final warning = BbkMapWarning(
        id: 'mow.test-4',
        version: 1,
        startDate: DateTime.utc(2026, 7, 14),
        severity: 'Minor',
        urgency: 'Immediate',
        type: 'Cancel',
        titles: const {},
        translationKeys: const {},
      );

      expect(warning.isCancellation, isTrue);
    });
  });
}
