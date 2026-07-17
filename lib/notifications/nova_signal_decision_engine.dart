import 'nova_signal_level.dart';
import 'nova_signal_policy.dart';
import 'nova_signal_settings.dart';

class NovaSignalDecisionResult {
  final NovaSignalLevel level;
  final bool push;
  final bool sound;
  final bool vibration;
  final bool speak;

  const NovaSignalDecisionResult({
    required this.level,
    required this.push,
    required this.sound,
    required this.vibration,
    required this.speak,
  });
}

class NovaSignalDecisionEngine {
  const NovaSignalDecisionEngine();

  NovaSignalDecisionResult evaluate({
    required NovaSignalLevel level,
    required NovaSignalSettings settings,
  }) {
    final policy = NovaSignalPolicy.forLevel(level);

    final allowed = settings.allows(level);

    return NovaSignalDecisionResult(
      level: level,
      push: allowed,
      sound: allowed && settings.soundEnabled && policy.sound,
      vibration: allowed && settings.vibrationEnabled && policy.vibration,
      speak: false,
    );
  }
}
