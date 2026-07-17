import 'nova_signal_settings.dart';
import 'nova_signal_settings_store.dart';

class NovaSignalSettingsProvider {
  NovaSignalSettingsProvider(this._store);

  final NovaSignalSettingsStore _store;

  Future<NovaSignalSettings> load() async {
    return _store.load();
  }

  Future<void> save(NovaSignalSettings settings) async {
    await _store.save(settings);
  }
}
