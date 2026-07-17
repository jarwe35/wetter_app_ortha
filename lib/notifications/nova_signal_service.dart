import 'nova_signal_level.dart';
import 'nova_signal_policy.dart';

class NovaSignalDecision {
  final NovaSignalLevel level;
  final NovaSignalPolicy policy;

  const NovaSignalDecision({required this.level, required this.policy});
}

class NovaSignalService {
  const NovaSignalService();

  NovaSignalDecision evaluate(NovaSignalLevel level) {
    return NovaSignalDecision(
      level: level,
      policy: NovaSignalPolicy.forLevel(level),
    );
  }
}
