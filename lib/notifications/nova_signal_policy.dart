import 'nova_signal_level.dart';

class NovaSignalPolicy {
  final bool push;
  final bool sound;
  final bool vibration;

  const NovaSignalPolicy({
    required this.push,
    required this.sound,
    required this.vibration,
  });

  factory NovaSignalPolicy.forLevel(NovaSignalLevel level) {
    switch (level) {
      case NovaSignalLevel.none:
        return const NovaSignalPolicy(
          push: false,
          sound: false,
          vibration: false,
        );

      case NovaSignalLevel.information:
        return const NovaSignalPolicy(
          push: false,
          sound: false,
          vibration: false,
        );

      case NovaSignalLevel.warning:
        return const NovaSignalPolicy(
          push: true,
          sound: false,
          vibration: false,
        );

      case NovaSignalLevel.danger:
        return const NovaSignalPolicy(push: true, sound: true, vibration: true);

      case NovaSignalLevel.emergency:
        return const NovaSignalPolicy(push: true, sound: true, vibration: true);
    }
  }
}
