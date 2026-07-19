import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_decision_engine.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_level.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_settings.dart';

void main() {
  test('Warnung erzeugt Standard Signalentscheidung', () {
    const engine = NovaSignalDecisionEngine();

    final result = engine.evaluate(
      level: NovaSignalLevel.warning,
      settings: const NovaSignalSettings(),
    );

    expect(result.push, true);
    expect(result.sound, false);
    expect(result.vibration, false);
    expect(result.speak, false);
  });

  test('Silent Modus verhindert normale Warnsignale', () {
    const engine = NovaSignalDecisionEngine();

    final result = engine.evaluate(
      level: NovaSignalLevel.warning,
      settings: const NovaSignalSettings.silent(),
    );

    expect(result.push, false);
    expect(result.sound, false);
    expect(result.vibration, false);
  });

  test('Notfall bleibt trotz Silent Modus aktiv', () {
    const engine = NovaSignalDecisionEngine();

    final result = engine.evaluate(
      level: NovaSignalLevel.emergency,
      settings: const NovaSignalSettings.silent(),
    );

    expect(result.push, true);
  });

  test('Aktivierte Sprachausgabe setzt speak auf true', () {
    const engine = NovaSignalDecisionEngine();

    final result = engine.evaluate(
      level: NovaSignalLevel.warning,
      settings: const NovaSignalSettings(speechEnabled: true),
    );

    expect(result.speak, isTrue);
  });

  test('Deaktivierte Sprachausgabe setzt speak auf false', () {
    const engine = NovaSignalDecisionEngine();

    final result = engine.evaluate(
      level: NovaSignalLevel.warning,
      settings: const NovaSignalSettings(speechEnabled: false),
    );

    expect(result.speak, isFalse);
  });
}
