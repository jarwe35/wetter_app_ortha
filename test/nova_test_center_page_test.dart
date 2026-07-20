import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wetter_app_ortha/notifications/notification_request.dart';
import 'package:wetter_app_ortha/notifications/nova_alert_dispatcher.dart';
import 'package:wetter_app_ortha/notifications/nova_alert_history_store.dart';
import 'package:wetter_app_ortha/notifications/nova_duplicate_alert_guard.dart';
import 'package:wetter_app_ortha/notifications/nova_notification_gateway.dart';
import 'package:wetter_app_ortha/notifications/nova_speech_service.dart';
import 'package:wetter_app_ortha/notifications/nova_speech_voice.dart';
import 'package:wetter_app_ortha/pages/nova_test_center_page.dart';

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

class RecordingNotificationGateway implements NovaNotificationGateway {
  int showCalls = 0;
  NotificationRequest? lastRequest;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> show(NotificationRequest request) async {
    showCalls++;
    lastRequest = request;
  }
}

class RecordingSpeechService implements NovaSpeechService {
  int speakCalls = 0;
  String? lastMessage;

  @override
  Future<List<NovaSpeechVoice>> getAvailableVoices() async => const [];

  @override
  Future<void> initialize() async {}

  @override
  Future<void> selectVoice(NovaSpeechVoice? voice) async {}

  @override
  Future<void> speak(String message) async {
    speakCalls++;
    lastMessage = message;
  }

  @override
  Future<void> stop() async {}
}

Widget createTestApp({
  required RecordingNotificationGateway gateway,
  required RecordingSpeechService speechService,
  required MemoryAlertHistoryStore historyStore,
}) {
  final dispatcher = NovaAlertDispatcher(
    notificationGateway: gateway,
    speechService: speechService,
  );

  final duplicateGuard = NovaDuplicateAlertGuard(historyStore: historyStore);

  return MaterialApp(
    home: Scaffold(
      body: NovaTestCenterPage(
        dispatcher: dispatcher,
        duplicateAlertGuard: duplicateGuard,
      ),
    ),
  );
}

void main() {
  testWidgets('zeigt das NOVA Test Center mit allen Teststufen', (
    tester,
  ) async {
    final gateway = RecordingNotificationGateway();
    final speechService = RecordingSpeechService();
    final historyStore = MemoryAlertHistoryStore();

    await tester.pumpWidget(
      createTestApp(
        gateway: gateway,
        speechService: speechService,
        historyStore: historyStore,
      ),
    );

    expect(find.text('NOVA Test Center Ω'), findsOneWidget);
    expect(find.text('Information testen'), findsOneWidget);
    expect(find.text('Wetterwarnung testen'), findsOneWidget);
    expect(find.text('Akutwarnung testen'), findsOneWidget);
    expect(find.text('Extremwarnung testen'), findsOneWidget);
  });

  testWidgets('Informationstest wird an Dispatcher übergeben', (tester) async {
    final gateway = RecordingNotificationGateway();
    final speechService = RecordingSpeechService();
    final historyStore = MemoryAlertHistoryStore();

    await tester.pumpWidget(
      createTestApp(
        gateway: gateway,
        speechService: speechService,
        historyStore: historyStore,
      ),
    );

    await tester.tap(find.byKey(const Key('nova-test-information')));
    await tester.pumpAndSettle();

    expect(gateway.showCalls, 1);
    expect(gateway.lastRequest?.title, 'NOVA Testinformation');
    expect(gateway.lastRequest?.playSound, isFalse);
    expect(gateway.lastRequest?.speakMessage, isFalse);
  });

  testWidgets('Extremwarnung fordert Ton und Sprache an', (tester) async {
    final gateway = RecordingNotificationGateway();
    final speechService = RecordingSpeechService();
    final historyStore = MemoryAlertHistoryStore();

    await tester.pumpWidget(
      createTestApp(
        gateway: gateway,
        speechService: speechService,
        historyStore: historyStore,
      ),
    );

    final extremeButton = find.byKey(const Key('nova-test-extreme'));

    await tester.ensureVisible(extremeButton);
    await tester.pump();

    await tester.tap(extremeButton);
    await tester.pumpAndSettle();

    expect(gateway.showCalls, 1);
    expect(gateway.lastRequest?.title, 'NOVA Test-Extremwarnung');
    expect(gateway.lastRequest?.playSound, isTrue);
    expect(gateway.lastRequest?.speakMessage, isTrue);
    expect(speechService.speakCalls, 1);
  });

  testWidgets('Duplicate Guard blockiert identische Wiederholung', (
    tester,
  ) async {
    final gateway = RecordingNotificationGateway();
    final speechService = RecordingSpeechService();
    final historyStore = MemoryAlertHistoryStore();

    await tester.pumpWidget(
      createTestApp(
        gateway: gateway,
        speechService: speechService,
        historyStore: historyStore,
      ),
    );

    final button = find.byKey(const Key('nova-test-information'));

    await tester.tap(button);
    await tester.pumpAndSettle();

    await tester.tap(button);
    await tester.pumpAndSettle();

    expect(gateway.showCalls, 1);
    expect(find.textContaining('Duplicate Guard blockiert'), findsOneWidget);
  });

  testWidgets('Duplicate Guard kann zurückgesetzt werden', (tester) async {
    final gateway = RecordingNotificationGateway();
    final speechService = RecordingSpeechService();
    final historyStore = MemoryAlertHistoryStore();

    await tester.pumpWidget(
      createTestApp(
        gateway: gateway,
        speechService: speechService,
        historyStore: historyStore,
      ),
    );

    await tester.tap(find.byKey(const Key('nova-test-information')));
    await tester.pumpAndSettle();

    final resetButton = find.byKey(const Key('nova-reset-duplicate-guard'));

    await tester.ensureVisible(resetButton);
    await tester.pump();

    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    expect(historyStore.fingerprint, isNull);
  }, skip: true);
}
