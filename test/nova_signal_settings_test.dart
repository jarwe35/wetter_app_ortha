import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_level.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings.dart';

void main() {
  test('Standard Einstellungen erlauben Warnungen', () {
    const settings = NovaSignalSettings();

    expect(settings.allows(NovaSignalLevel.warning), true);
  });

  test('Silent Modus blockiert normale Signale', () {
    const settings = NovaSignalSettings.silent();

    expect(settings.soundEnabled, false);

    expect(settings.vibrationEnabled, false);

    expect(settings.allows(NovaSignalLevel.warning), false);
  });

  test('Emergency bleibt im Silent Modus erlaubt', () {
    const settings = NovaSignalSettings.silent();

    expect(settings.allows(NovaSignalLevel.emergency), true);
  });
}
