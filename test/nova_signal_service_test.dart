import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_level.dart';
import 'package:wetter_app_ortha/notifications/nova_signal_service.dart';

void main() {
  test('Signal Service erzeugt Policy für Warnung', () {
    const service = NovaSignalService();

    final decision = service.evaluate(NovaSignalLevel.warning);

    expect(decision.level, NovaSignalLevel.warning);

    expect(decision.policy.push, true);

    expect(decision.policy.sound, false);
  });

  test('Signal Service erzeugt maximale Policy für Notfall', () {
    const service = NovaSignalService();

    final decision = service.evaluate(NovaSignalLevel.emergency);

    expect(decision.policy.sound, true);

    expect(decision.policy.vibration, true);
  });
}
