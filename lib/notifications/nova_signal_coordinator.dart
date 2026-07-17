import 'nova_signal_decision_engine.dart';
import 'nova_signal_level.dart';
import 'nova_signal_settings_provider.dart';

class NovaSignalCoordinator {
  NovaSignalCoordinator({
    required this._settingsProvider,
    NovaSignalDecisionEngine? decisionEngine,
  }) : _decisionEngine = decisionEngine ?? const NovaSignalDecisionEngine();

  final NovaSignalSettingsProvider _settingsProvider;
  final NovaSignalDecisionEngine _decisionEngine;

  Future<NovaSignalDecisionResult> evaluate(NovaSignalLevel level) async {
    final settings = await _settingsProvider.load();

    return _decisionEngine.evaluate(level: level, settings: settings);
  }
}
