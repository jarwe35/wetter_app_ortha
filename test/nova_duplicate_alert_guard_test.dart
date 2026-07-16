import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_alert_history_store.dart';
import 'package:wetter_app_ortha/notifications/nova_duplicate_alert_guard.dart';
import 'package:wetter_app_ortha/notifications/notification_level.dart';
import 'package:wetter_app_ortha/notifications/notification_request.dart';

class MemoryAlertHistoryStore implements NovaAlertHistoryStore {
  String? fingerprint;

  @override
  Future<void> clear() async {
    fingerprint = null;
  }

  @override
  Future<String?> loadLastFingerprint() async {
    return fingerprint;
  }

  @override
  Future<void> saveLastFingerprint(String fingerprint) async {
    this.fingerprint = fingerprint;
  }
}

void main() {
  NotificationRequest request({
    NotificationLevel level = NotificationLevel.warning,
    String title = 'NOVA Wetterwarnung',
    String message = 'Starke Windböen möglich.',
    bool playSound = true,
    bool speakMessage = false,
  }) {
    return NotificationRequest(
      level: level,
      title: title,
      message: message,
      playSound: playSound,
      speakMessage: speakMessage,
    );
  }

  test('erlaubt eine neue Warnung', () async {
    final guard = NovaDuplicateAlertGuard(
      historyStore: MemoryAlertHistoryStore(),
    );

    final result = await guard.shouldDispatch(
      request: request(),
      locationName: 'Duisburg',
    );

    expect(result, isTrue);
  });

  test('blockiert eine identische Warnung', () async {
    final guard = NovaDuplicateAlertGuard(
      historyStore: MemoryAlertHistoryStore(),
    );

    final first = await guard.shouldDispatch(
      request: request(),
      locationName: 'Duisburg',
    );

    final second = await guard.shouldDispatch(
      request: request(),
      locationName: 'Duisburg',
    );

    expect(first, isTrue);
    expect(second, isFalse);
  });

  test('erlaubt eine Warnung für einen anderen Ort', () async {
    final guard = NovaDuplicateAlertGuard(
      historyStore: MemoryAlertHistoryStore(),
    );

    await guard.shouldDispatch(request: request(), locationName: 'Duisburg');

    final result = await guard.shouldDispatch(
      request: request(),
      locationName: 'Düsseldorf',
    );

    expect(result, isTrue);
  });

  test('erlaubt eine geänderte Warnstufe', () async {
    final guard = NovaDuplicateAlertGuard(
      historyStore: MemoryAlertHistoryStore(),
    );

    await guard.shouldDispatch(
      request: request(level: NotificationLevel.warning),
      locationName: 'Duisburg',
    );

    final result = await guard.shouldDispatch(
      request: request(
        level: NotificationLevel.emergency,
        title: 'NOVA Akutwarnung',
        speakMessage: true,
      ),
      locationName: 'Duisburg',
    );

    expect(result, isTrue);
  });

  test('erlaubt einen geänderten Warntext', () async {
    final guard = NovaDuplicateAlertGuard(
      historyStore: MemoryAlertHistoryStore(),
    );

    await guard.shouldDispatch(request: request(), locationName: 'Duisburg');

    final result = await guard.shouldDispatch(
      request: request(message: 'Schwere Sturmgefahr.'),
      locationName: 'Duisburg',
    );

    expect(result, isTrue);
  });

  test('normalisiert Leerzeichen und Großschreibung', () async {
    final guard = NovaDuplicateAlertGuard(
      historyStore: MemoryAlertHistoryStore(),
    );

    await guard.shouldDispatch(
      request: request(
        title: 'NOVA Wetterwarnung',
        message: 'Starke Windböen möglich.',
      ),
      locationName: 'Duisburg',
    );

    final result = await guard.shouldDispatch(
      request: request(
        title: '  nova   wetterwarnung ',
        message: ' starke   windböen möglich. ',
      ),
      locationName: '  DUISBURG ',
    );

    expect(result, isFalse);
  });

  test('reset erlaubt dieselbe Warnung erneut', () async {
    final guard = NovaDuplicateAlertGuard(
      historyStore: MemoryAlertHistoryStore(),
    );

    await guard.shouldDispatch(request: request(), locationName: 'Duisburg');

    await guard.reset();

    final result = await guard.shouldDispatch(
      request: request(),
      locationName: 'Duisburg',
    );

    expect(result, isTrue);
  });
}
