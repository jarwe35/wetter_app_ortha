import 'package:flutter/material.dart';

import '../notifications/nova_signal_level.dart';
import '../notifications/nova_signal_settings.dart';
import '../notifications/nova_signal_settings_provider.dart';

const Color _orthaSurface = Color(0xFFFFFFFF);
const Color _orthaSurfaceElevated = Color(0xFFF5FAFE);
const Color _orthaPrimaryText = Color(0xFF163247);
const Color _orthaSecondaryText = Color(0xFF587080);
const Color _orthaAccent = Color(0xFFD5A84A);
const Color _orthaBorder = Color(0xFFD3E2EC);

class NovaPage extends StatefulWidget {
  const NovaPage({super.key, required this.settingsProvider});

  final NovaSignalSettingsProvider settingsProvider;

  @override
  State<NovaPage> createState() => _NovaPageState();
}

class _NovaPageState extends State<NovaPage> {
  NovaSignalSettings? _settings;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settings = await widget.settingsProvider.load();

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _errorMessage = 'Die NOVA-Einstellungen konnten nicht geladen werden.';
      });
    }
  }

  Future<void> _saveSettings(NovaSignalSettings settings) async {
    setState(() {
      _settings = settings;
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      await widget.settingsProvider.save(settings);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage =
            'Die NOVA-Einstellungen konnten nicht gespeichert werden.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _setSoundEnabled(bool enabled) async {
    final current = _settings;

    if (current == null) {
      return;
    }

    await _saveSettings(
      NovaSignalSettings(
        soundEnabled: enabled,
        vibrationEnabled: current.vibrationEnabled,
        minimumLevel: current.minimumLevel,
      ),
    );
  }

  Future<void> _setVibrationEnabled(bool enabled) async {
    final current = _settings;

    if (current == null) {
      return;
    }

    await _saveSettings(
      NovaSignalSettings(
        soundEnabled: current.soundEnabled,
        vibrationEnabled: enabled,
        minimumLevel: current.minimumLevel,
      ),
    );
  }

  Future<void> _setMinimumLevel(NovaSignalLevel level) async {
    final current = _settings;

    if (current == null) {
      return;
    }

    await _saveSettings(
      NovaSignalSettings(
        soundEnabled: current.soundEnabled,
        vibrationEnabled: current.vibrationEnabled,
        minimumLevel: level,
      ),
    );
  }

  String _levelLabel(NovaSignalLevel level) {
    switch (level) {
      case NovaSignalLevel.none:
        return 'Alle';
      case NovaSignalLevel.information:
        return 'Information';
      case NovaSignalLevel.warning:
        return 'Warnung';
      case NovaSignalLevel.danger:
        return 'Gefahr';
      case NovaSignalLevel.emergency:
        return 'Notfall';
    }
  }

  String _levelDescription(NovaSignalLevel level) {
    switch (level) {
      case NovaSignalLevel.none:
        return 'NOVA berücksichtigt sämtliche Signalstufen.';
      case NovaSignalLevel.information:
        return 'Auch allgemeine Wetterhinweise werden berücksichtigt.';
      case NovaSignalLevel.warning:
        return 'Warnungen, Gefahren und Notfälle werden berücksichtigt.';
      case NovaSignalLevel.danger:
        return 'Nur Gefahrenlagen und Notfälle werden berücksichtigt.';
      case NovaSignalLevel.emergency:
        return 'Nur akute Notfallmeldungen werden berücksichtigt.';
    }
  }

  IconData _levelIcon(NovaSignalLevel level) {
    switch (level) {
      case NovaSignalLevel.none:
        return Icons.notifications_none_outlined;
      case NovaSignalLevel.information:
        return Icons.info_outline;
      case NovaSignalLevel.warning:
        return Icons.warning_amber_outlined;
      case NovaSignalLevel.danger:
        return Icons.report_problem_outlined;
      case NovaSignalLevel.emergency:
        return Icons.emergency_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final settings = _settings;

    if (settings == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: _orthaSecondaryText,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage ??
                    'Die NOVA-Einstellungen stehen nicht zur Verfügung.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: _orthaPrimaryText, fontSize: 16),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadSettings,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut laden'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      key: const Key('nova-page'),
      children: [
        _buildHeader(),
        const SizedBox(height: 18),
        if (_errorMessage != null) ...[
          _buildErrorCard(_errorMessage!),
          const SizedBox(height: 18),
        ],
        _buildStatusCard(settings),
        const SizedBox(height: 18),
        _buildSignalSettingsCard(settings),
        const SizedBox(height: 18),
        _buildMinimumLevelCard(settings),
        const SizedBox(height: 18),
        _buildAccessibilityPreviewCard(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _orthaSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _orthaBorder.withValues(alpha: 0.85)),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _orthaAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _orthaAccent.withValues(alpha: 0.35)),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: _orthaAccent,
              size: 29,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOVA Ω',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _orthaPrimaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Intelligente Warn- und Signaleinstellungen',
                  style: TextStyle(color: _orthaSecondaryText),
                ),
              ],
            ),
          ),
          if (_isSaving)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.4),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(NovaSignalSettings settings) {
    return _NovaCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: _orthaAccent, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NOVA ist aktiv',
                  style: TextStyle(
                    color: _orthaPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Meldungen werden ab der Stufe '
                  '„${_levelLabel(settings.minimumLevel)}“ berücksichtigt.',
                  style: const TextStyle(
                    color: _orthaSecondaryText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalSettingsCard(NovaSignalSettings settings) {
    return _NovaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.tune_outlined,
            title: 'Signalisierung',
            subtitle: 'Akustische und haptische Warnsignale',
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            key: const Key('nova-sound-switch'),
            contentPadding: EdgeInsets.zero,
            value: settings.soundEnabled,
            onChanged: _isSaving ? null : _setSoundEnabled,
            secondary: const Icon(
              Icons.volume_up_outlined,
              color: _orthaAccent,
            ),
            title: const Text(
              'Warnton',
              style: TextStyle(
                color: _orthaPrimaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Bei Gefahren- und Notfallmeldungen einen Ton ausgeben.',
              style: TextStyle(color: _orthaSecondaryText),
            ),
          ),
          const Divider(color: _orthaBorder),
          SwitchListTile(
            key: const Key('nova-vibration-switch'),
            contentPadding: EdgeInsets.zero,
            value: settings.vibrationEnabled,
            onChanged: _isSaving ? null : _setVibrationEnabled,
            secondary: const Icon(
              Icons.vibration_outlined,
              color: _orthaAccent,
            ),
            title: const Text(
              'Vibration',
              style: TextStyle(
                color: _orthaPrimaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Gefahrenmeldungen zusätzlich durch Vibration signalisieren.',
              style: TextStyle(color: _orthaSecondaryText),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumLevelCard(NovaSignalSettings settings) {
    final selectableLevels = <NovaSignalLevel>{
      NovaSignalLevel.information,
      NovaSignalLevel.warning,
      NovaSignalLevel.danger,
      NovaSignalLevel.emergency,
    };

    return _NovaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.notification_important_outlined,
            title: 'Mindestwarnstufe',
            subtitle: 'Ab welcher Stufe NOVA Meldungen ausgeben darf',
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<NovaSignalLevel>(
              key: const Key('nova-minimum-level-control'),
              segments: selectableLevels
                  .map(
                    (level) => ButtonSegment<NovaSignalLevel>(
                      value: level,
                      icon: Icon(_levelIcon(level)),
                      label: Text(_levelLabel(level)),
                    ),
                  )
                  .toList(),
              selected: <NovaSignalLevel>{settings.minimumLevel},
              showSelectedIcon: false,
              multiSelectionEnabled: false,
              emptySelectionAllowed: false,
              onSelectionChanged: _isSaving
                  ? null
                  : (selection) {
                      if (selection.isNotEmpty) {
                        _setMinimumLevel(selection.first);
                      }
                    },
            ),
          ),
          const SizedBox(height: 16),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Container(
              key: ValueKey(settings.minimumLevel),
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _orthaSurfaceElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _orthaBorder),
              ),
              child: Text(
                _levelDescription(settings.minimumLevel),
                style: const TextStyle(color: _orthaSecondaryText, height: 1.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityPreviewCard() {
    return const _NovaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardTitle(
            icon: Icons.accessibility_new_outlined,
            title: 'Barrierefreiheit',
            subtitle: 'Vorbereitung für gesprochene Warnmeldungen',
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.record_voice_over_outlined,
                color: _orthaSecondaryText,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Die optionale Sprachausgabe für sehbehinderte Menschen '
                  'wird im nächsten NOVA-Schritt direkt mit der vorhandenen '
                  'TTS-Infrastruktur verbunden.',
                  style: TextStyle(color: _orthaSecondaryText, height: 1.45),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB94A48).withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFB94A48)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: _orthaPrimaryText),
            ),
          ),
        ],
      ),
    );
  }
}

class _NovaCard extends StatelessWidget {
  const _NovaCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _orthaSurface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: _orthaBorder.withValues(alpha: 0.85)),
        ),
        child: child,
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: _orthaAccent),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _orthaPrimaryText,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _orthaSecondaryText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
