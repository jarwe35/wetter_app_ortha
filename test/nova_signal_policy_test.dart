import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_level.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_policy.dart';

void main() {
  test('Information erzeugt keine aktive Signalisierung', () {
    final policy = NovaSignalPolicy.forLevel(NovaSignalLevel.information);

    expect(policy.push, false);
    expect(policy.sound, false);
    expect(policy.vibration, false);
  });

  test('Warnung erzeugt Push aber keinen Alarmton', () {
    final policy = NovaSignalPolicy.forLevel(NovaSignalLevel.warning);

    expect(policy.push, true);
    expect(policy.sound, false);
    expect(policy.vibration, false);
  });

  test('Gefahr erzeugt Ton und Vibration', () {
    final policy = NovaSignalPolicy.forLevel(NovaSignalLevel.danger);

    expect(policy.push, true);
    expect(policy.sound, true);
    expect(policy.vibration, true);
  });

  test('Notfall erzeugt maximale Signalisierung', () {
    final policy = NovaSignalPolicy.forLevel(NovaSignalLevel.emergency);

    expect(
      policy,
      const NovaSignalPolicy(push: true, sound: true, vibration: true),
    );
  });
}
