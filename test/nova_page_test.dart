import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings_provider.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings_store.dart';
import 'package:wetter_app_ortha/notifications/nova_speech_service.dart';
import 'package:wetter_app_ortha/notifications/nova_speech_voice.dart';
import 'package:wetter_app_ortha/pages/nova_page.dart';

class RecordingNovaSpeechService implements NovaSpeechService {
  int initializeCalls = 0;
  int speakCalls = 0;
  int stopCalls = 0;
  String? lastMessage;

  @override
  Future<List<NovaSpeechVoice>> getAvailableVoices() async => const [];

  @override
  Future<void> selectVoice(NovaSpeechVoice? voice) async {}

  @override
  Future<void> initialize() async {
    initializeCalls++;
  }

  @override
  Future<void> speak(String message) async {
    speakCalls++;
    lastMessage = message;
  }

  @override
  Future<void> stop() async {
    stopCalls++;
  }
}

NovaSignalSettingsProvider createProvider() {
  return NovaSignalSettingsProvider(const NovaSignalSettingsStore());
}

void main() {
  testWidgets('NOVA-Seite lädt gespeicherte Einstellungen', (tester) async {
    SharedPreferences.setMockInitialValues({
      'nova_signal_sound_enabled': true,
      'nova_signal_vibration_enabled': false,
      'nova_signal_speech_enabled': true,
      'nova_signal_minimum_level': 2,
    });

    final provider = createProvider();
    final speechService = RecordingNovaSpeechService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NovaPage(
            settingsProvider: provider,
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('NOVA Ω'), findsOneWidget);
    expect(find.text('Signalisierung'), findsOneWidget);
    expect(find.text('Warnungen vorlesen'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Mindestwarnstufe'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text('Mindestwarnstufe'), findsOneWidget);

    final soundSwitch = tester.widget<SwitchListTile>(
      find.byKey(const Key('nova-sound-switch')),
    );
    final vibrationSwitch = tester.widget<SwitchListTile>(
      find.byKey(const Key('nova-vibration-switch')),
    );
    final speechSwitch = tester.widget<SwitchListTile>(
      find.byKey(const Key('nova-speech-switch')),
    );

    expect(soundSwitch.value, isTrue);
    expect(vibrationSwitch.value, isFalse);
    expect(speechSwitch.value, isTrue);
  });

  testWidgets('NOVA-Seite speichert geänderte Toneinstellung', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final provider = createProvider();
    final speechService = RecordingNovaSpeechService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NovaPage(
            settingsProvider: provider,
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nova-sound-switch')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getBool('nova_signal_sound_enabled'), isFalse);
    expect(preferences.getBool('nova_signal_speech_enabled'), isFalse);
  });

  testWidgets('NOVA-Seite speichert aktivierte Sprachausgabe', (tester) async {
    SharedPreferences.setMockInitialValues({
      'nova_signal_speech_enabled': false,
    });

    final provider = createProvider();
    final speechService = RecordingNovaSpeechService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NovaPage(
            settingsProvider: provider,
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nova-speech-switch')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getBool('nova_signal_speech_enabled'), isTrue);
  });

  testWidgets('Testbutton ist bei aktivierter Sprachausgabe sichtbar', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'nova_signal_speech_enabled': true,
    });

    final provider = createProvider();
    final speechService = RecordingNovaSpeechService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NovaPage(
            settingsProvider: provider,
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('nova-speech-test-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('nova-speech-test-button')), findsOneWidget);
    expect(find.text('Sprachausgabe testen'), findsOneWidget);
  });

  testWidgets('Testbutton führt NOVA-Testansage aus', (tester) async {
    SharedPreferences.setMockInitialValues({
      'nova_signal_speech_enabled': true,
    });

    final provider = createProvider();
    final speechService = RecordingNovaSpeechService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NovaPage(
            settingsProvider: provider,
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byKey(const Key('nova-speech-test-button')),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    await tester.tap(find.byKey(const Key('nova-speech-test-button')));
    await tester.pumpAndSettle();

    expect(speechService.speakCalls, 1);
    expect(
      speechService.lastMessage,
      'NOVA Sprachausgabe ist aktiviert. '
      'Warnmeldungen können vorgelesen werden.',
    );
    expect(find.text('NOVA-Testansage wurde ausgeführt.'), findsOneWidget);
  });

  testWidgets('Testbutton bleibt bei deaktivierter Sprachausgabe verborgen', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'nova_signal_speech_enabled': false,
    });

    final provider = createProvider();
    final speechService = RecordingNovaSpeechService();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NovaPage(
            settingsProvider: provider,
            speechService: speechService,
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Aktivieren Sie zunächst den Schalter „Warnungen vorlesen“.'),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.byKey(const Key('nova-speech-test-button')), findsNothing);
    expect(
      find.text('Aktivieren Sie zunächst den Schalter „Warnungen vorlesen“.'),
      findsOneWidget,
    );
  });
}
