import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/warning_bridge/bbk_warning.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_map_data_parser.dart';
import 'package:wetter_app_ortha/services/warning_providers/bbk/bbk_warning_lifecycle.dart';

BbkWarning createDetail({
  String messageType = 'Alert',
  DateTime? effective,
  DateTime? expires,
}) {
  return BbkWarning(
    identifier: 'mow.test-warning',
    headline: 'Testwarnung',
    description: 'Beschreibung',
    instruction: 'Hinweis',
    sender: 'Test',
    severity: 'Moderate',
    urgency: 'Immediate',
    certainty: 'Observed',
    messageType: messageType,
    sent: DateTime.utc(2026, 7, 13, 8),
    effective: effective,
    expires: expires,
    areaDescriptions: const ['Testgebiet'],
    geocodes: const {},
    polygons: const [],
  );
}

Map<String, dynamic> createMapEntry({
  required String id,
  required int version,
  required String type,
  required String startDate,
}) {
  return {
    'id': id,
    'version': version,
    'startDate': startDate,
    'severity': 'Moderate',
    'urgency': 'Immediate',
    'type': type,
    'i18nTitle': {'de': 'Testmeldung'},
    'transKeys': <String, dynamic>{},
  };
}

void main() {
  const lifecycle = BbkWarningLifecycle();
  const parser = BbkMapDataParser();

  group('BbkWarningLifecycle', () {
    test('verwendet höchste Version', () {
      final warnings = parser.parse([
        createMapEntry(
          id: 'warn-1',
          version: 1,
          type: 'Alert',
          startDate: '2026-07-13T08:00:00+02:00',
        ),
        createMapEntry(
          id: 'warn-1',
          version: 3,
          type: 'Update',
          startDate: '2026-07-15T08:00:00+02:00',
        ),
      ]);

      final result = lifecycle.selectCurrentMapWarnings(warnings);

      expect(result, hasLength(1));
      expect(result.single.version, 3);
    });

    test('Cancel entfernt Warnung', () {
      final warnings = parser.parse([
        createMapEntry(
          id: 'warn-2',
          version: 4,
          type: 'Update',
          startDate: '2026-07-14T08:00:00+02:00',
        ),
        createMapEntry(
          id: 'warn-2',
          version: 5,
          type: 'Cancel',
          startDate: '2026-07-15T08:00:00+02:00',
        ),
      ]);

      expect(lifecycle.selectCurrentMapWarnings(warnings), isEmpty);
    });

    test('abgelaufen ist nicht aktiv', () {
      expect(
        lifecycle.isDetailActive(
          createDetail(
            effective: DateTime.utc(2026, 7, 13),
            expires: DateTime.utc(2026, 7, 14),
          ),
          moment: DateTime.utc(2026, 7, 15),
        ),
        isFalse,
      );
    });

    test('aktuelle Warnung ist aktiv', () {
      expect(
        lifecycle.isDetailActive(
          createDetail(
            effective: DateTime.utc(2026, 7, 14),
            expires: DateTime.utc(2026, 7, 16),
          ),
          moment: DateTime.utc(2026, 7, 15),
        ),
        isTrue,
      );
    });
  });
}
