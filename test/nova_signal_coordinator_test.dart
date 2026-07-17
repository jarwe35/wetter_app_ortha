import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_coordinator.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_level.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings_provider.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings_store.dart';

class FakeNovaSignalSettingsProvider extends NovaSignalSettingsProvider {
  FakeNovaSignalSettingsProvider(this.settings)
    : super(NovaSignalSettingsStore());

  final NovaSignalSettings settings;

  @override
  Future<NovaSignalSettings> load() async {
    return settings;
  }
}

void main() {
  test('Coordinator erzeugt Standard Warnentscheidung', () async {
    final coordinator = NovaSignalCoordinator(
      settingsProvider: FakeNovaSignalSettingsProvider(
        const NovaSignalSettings(),
      ),
    );

    final result = await coordinator.evaluate(NovaSignalLevel.warning);

    expect(result.push, true);
  });

  test('Coordinator respektiert Silent Einstellungen', () async {
    final coordinator = NovaSignalCoordinator(
      settingsProvider: FakeNovaSignalSettingsProvider(
        const NovaSignalSettings.silent(),
      ),
    );

    final result = await coordinator.evaluate(NovaSignalLevel.warning);

    expect(result.push, false);
  });

  test('Coordinator lässt Notfall trotz Silent durch', () async {
    final coordinator = NovaSignalCoordinator(
      settingsProvider: FakeNovaSignalSettingsProvider(
        const NovaSignalSettings.silent(),
      ),
    );

    final result = await coordinator.evaluate(NovaSignalLevel.emergency);

    expect(result.push, true);
  });
}
