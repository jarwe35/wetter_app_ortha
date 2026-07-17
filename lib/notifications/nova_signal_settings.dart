import 'nova_signal_level.dart';

class NovaSignalSettings {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final NovaSignalLevel minimumLevel;

  const NovaSignalSettings({
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.minimumLevel = NovaSignalLevel.warning,
  });

  const NovaSignalSettings.silent()
    : soundEnabled = false,
      vibrationEnabled = false,
      minimumLevel = NovaSignalLevel.emergency;

  bool allows(NovaSignalLevel level) {
    return level.index >= minimumLevel.index;
  }
}
