import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings_provider.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings_store.dart';
import 'package:wetter_app_ortha/pages/nova_page.dart';

void main() {
  testWidgets('NOVA-Seite lädt gespeicherte Einstellungen', (tester) async {
    SharedPreferences.setMockInitialValues({
      'nova_signal_sound_enabled': true,
      'nova_signal_vibration_enabled': false,
      'nova_signal_minimum_level': 2,
    });

    final provider = NovaSignalSettingsProvider(
      const NovaSignalSettingsStore(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NovaPage(settingsProvider: provider)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('NOVA Ω'), findsOneWidget);
    expect(find.text('Signalisierung'), findsOneWidget);
    expect(find.text('Mindestwarnstufe'), findsOneWidget);

    final soundSwitch = tester.widget<SwitchListTile>(
      find.byKey(const Key('nova-sound-switch')),
    );
    final vibrationSwitch = tester.widget<SwitchListTile>(
      find.byKey(const Key('nova-vibration-switch')),
    );

    expect(soundSwitch.value, isTrue);
    expect(vibrationSwitch.value, isFalse);
  });

  testWidgets('NOVA-Seite speichert geänderte Toneinstellung', (tester) async {
    SharedPreferences.setMockInitialValues({});

    final provider = NovaSignalSettingsProvider(
      const NovaSignalSettingsStore(),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: NovaPage(settingsProvider: provider)),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('nova-sound-switch')));
    await tester.pumpAndSettle();

    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getBool('nova_signal_sound_enabled'), isFalse);
  });
}
