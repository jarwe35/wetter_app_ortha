import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:wetter_app_ortha/notifications/nova_signal_level.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings_store.dart';

void main() {
  test('lädt Standardwerte ohne Speicherung', () async {
    SharedPreferences.setMockInitialValues({});

    const store = NovaSignalSettingsStore();

    final settings = await store.load();

    expect(settings.soundEnabled, true);

    expect(settings.vibrationEnabled, true);

    expect(settings.minimumLevel, NovaSignalLevel.warning);
  });

  test('speichert und lädt Einstellungen', () async {
    SharedPreferences.setMockInitialValues({});

    const store = NovaSignalSettingsStore();

    const settings = NovaSignalSettings(
      soundEnabled: false,
      vibrationEnabled: false,
      minimumLevel: NovaSignalLevel.emergency,
    );

    await store.save(settings);

    final loaded = await store.load();

    expect(loaded.soundEnabled, false);

    expect(loaded.vibrationEnabled, false);

    expect(loaded.minimumLevel, NovaSignalLevel.emergency);
  });
}
