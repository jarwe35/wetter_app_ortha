import 'package:flutter/material.dart';

import '../notifications/nova_signal_level.dart';
import '../pages/ortha_imprint_page.dart';
import '../notifications/nova_signal_settings.dart';
import '../notifications/nova_signal_settings_store.dart';
import '../services/location_startup_preference_service.dart';
import 'unit_settings.dart';
import 'unit_settings_page.dart';
import 'unit_settings_service.dart';
import 'nova_speech_settings_page.dart';
import '../pages/ortha_privacy_page.dart';

class OrthaControlCenterPage extends StatefulWidget {
  const OrthaControlCenterPage({super.key});

  @override
  State<OrthaControlCenterPage> createState() => _OrthaControlCenterPageState();
}

class _OrthaControlCenterPageState extends State<OrthaControlCenterPage> {
  static const Color _accentColor = Color(0xFFFFB536);
  static const Color _surfaceColor = Color(0xE6192B3A);
  static const Color _secondaryTextColor = Color(0xFFADB9C7);

  final UnitSettingsService _unitSettingsService = UnitSettingsService();

  final NovaSignalSettingsStore _novaSignalSettingsStore =
      const NovaSignalSettingsStore();

  final LocationStartupPreferenceService _locationPreferenceService =
      const LocationStartupPreferenceService();

  UnitSettings _unitSettings = const UnitSettings();
  NovaSignalSettings _novaSignalSettings = const NovaSignalSettings();

  bool _useCurrentLocationAtStartup = false;
  bool _isLoading = true;
  bool _isSaving = false;

  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final results = await Future.wait<Object?>([
        _unitSettingsService.load(),
        _novaSignalSettingsStore.load(),
        _locationPreferenceService.loadUseCurrentLocationAtStartup(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _unitSettings = results[0] as UnitSettings;
        _novaSignalSettings = results[1] as NovaSignalSettings;
        _useCurrentLocationAtStartup = results[2] as bool? ?? false;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _statusMessage =
            'Die gespeicherten Einstellungen konnten nicht geladen werden.';
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
      _statusMessage = null;
    });

    try {
      await Future.wait([
        _unitSettingsService.save(_unitSettings),
        _novaSignalSettingsStore.save(_novaSignalSettings),
        _locationPreferenceService.saveUseCurrentLocationAtStartup(
          _useCurrentLocationAtStartup,
        ),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'Alle Einstellungen wurden gespeichert.';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _statusMessage = 'Die Einstellungen konnten nicht gespeichert werden.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _openUnitSettings() async {
    final updatedSettings = await Navigator.push<UnitSettings>(
      context,
      MaterialPageRoute(
        builder: (_) => UnitSettingsPage(initialSettings: _unitSettings),
      ),
    );

    if (updatedSettings == null || !mounted) {
      return;
    }

    setState(() {
      _unitSettings = updatedSettings;
      _statusMessage = null;
    });

    await _unitSettingsService.save(updatedSettings);
  }

  void _updateNovaSignalSettings({
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? speechEnabled,
    NovaSignalLevel? minimumLevel,
  }) {
    setState(() {
      _novaSignalSettings = NovaSignalSettings(
        soundEnabled: soundEnabled ?? _novaSignalSettings.soundEnabled,
        vibrationEnabled:
            vibrationEnabled ?? _novaSignalSettings.vibrationEnabled,
        speechEnabled: speechEnabled ?? _novaSignalSettings.speechEnabled,
        minimumLevel: minimumLevel ?? _novaSignalSettings.minimumLevel,
      );

      _statusMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ORTHA Control Center Ω'),
        actions: [
          IconButton(
            tooltip: 'Einstellungen speichern',
            onPressed: _isLoading || _isSaving ? null : _saveSettings,
            icon: const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildIntroductionCard(),
                const SizedBox(height: 16),
                _buildGeneralSection(),
                const SizedBox(height: 16),
                _buildNovaSection(),
                const SizedBox(height: 16),
                _buildLegalSection(),
                const SizedBox(height: 16),
                _buildSystemSection(),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildStatusMessage(),
                ],
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveSettings,
                  icon: _isSaving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _isSaving
                        ? 'Einstellungen werden gespeichert …'
                        : 'Alle Einstellungen speichern',
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildIntroductionCard() {
    return Card(
      color: _surfaceColor,
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.tune_outlined, color: _accentColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Zentrale App-Steuerung',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Text(
              'Hier werden die grundlegenden Einstellungen von '
              'ORTHA METEO Ω zentral verwaltet. Die Werte werden '
              'lokal auf diesem Gerät gespeichert.',
              style: TextStyle(color: _secondaryTextColor, height: 1.45),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralSection() {
    return _SettingsSection(
      title: 'Allgemein',
      icon: Icons.settings_outlined,
      children: [
        ListTile(
          leading: const Icon(Icons.straighten_outlined, color: _accentColor),
          title: const Text('Einheiten'),
          subtitle: Text(_unitSettingsSummary),
          trailing: const Icon(Icons.chevron_right),
          onTap: _openUnitSettings,
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(
            Icons.my_location_outlined,
            color: _accentColor,
          ),
          value: _useCurrentLocationAtStartup,
          title: const Text('Aktuellen Standort beim Start verwenden'),
          subtitle: const Text(
            'ORTHA METEO Ω versucht beim App-Start, die aktuelle '
            'Geräteposition zu bestimmen.',
          ),
          onChanged: (value) {
            setState(() {
              _useCurrentLocationAtStartup = value;
              _statusMessage = null;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNovaSection() {
    return _SettingsSection(
      title: 'NOVA-Warnsignale',
      icon: Icons.notifications_active_outlined,
      children: [
        ListTile(
          leading: const Icon(
            Icons.record_voice_over_outlined,
            color: _accentColor,
          ),
          title: const Text('Erweiterte Sprachausgabe'),
          subtitle: const Text(
            'Sprache, Geschwindigkeit, Tonhöhe und Warnansagen.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const NovaSpeechSettingsPage(),
              ),
            );
          },
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(Icons.volume_up_outlined, color: _accentColor),
          value: _novaSignalSettings.soundEnabled,
          title: const Text('Warnton'),
          subtitle: const Text(
            'Akustisches Signal bei freigegebenen Warnstufen.',
          ),
          onChanged: (value) {
            _updateNovaSignalSettings(soundEnabled: value);
          },
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(Icons.vibration_outlined, color: _accentColor),
          value: _novaSignalSettings.vibrationEnabled,
          title: const Text('Vibration'),
          subtitle: const Text(
            'Vibrationssignal bei freigegebenen Warnstufen.',
          ),
          onChanged: (value) {
            _updateNovaSignalSettings(vibrationEnabled: value);
          },
        ),
        const Divider(height: 1),
        SwitchListTile(
          secondary: const Icon(
            Icons.record_voice_over_outlined,
            color: _accentColor,
          ),
          value: _novaSignalSettings.speechEnabled,
          title: const Text('Warnmeldungen vorlesen'),
          subtitle: const Text(
            'NOVA darf geeignete Warnmeldungen per '
            'Sprachausgabe wiedergeben.',
          ),
          onChanged: (value) {
            _updateNovaSignalSettings(speechEnabled: value);
          },
        ),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<NovaSignalLevel>(
            initialValue: _novaSignalSettings.minimumLevel,
            decoration: const InputDecoration(
              labelText: 'Mindestwarnstufe',
              helperText: 'Signale werden erst ab dieser Stufe ausgelöst.',
              border: OutlineInputBorder(),
            ),
            items: NovaSignalLevel.values.map((level) {
              return DropdownMenuItem<NovaSignalLevel>(
                value: level,
                child: Text(_novaSignalLevelLabel(level)),
              );
            }).toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }

              _updateNovaSignalSettings(minimumLevel: value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection() {
    return _SettingsSection(
      title: 'Rechtliches',
      icon: Icons.gavel_outlined,
      children: [
        ListTile(
          leading: const Icon(Icons.business_outlined, color: _accentColor),
          title: const Text('Impressum'),
          subtitle: const Text(
            'Anbieterkennzeichnung und Kontaktinformationen.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const OrthaImprintPage()),
            );
          },
        ),
        const Divider(height: 1),
        ListTile(
          leading: const Icon(Icons.privacy_tip_outlined, color: _accentColor),
          title: const Text('Datenschutz'),
          subtitle: const Text(
            'Datenverarbeitung, Speicherung und Berechtigungen.',
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const OrthaPrivacyPage()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSystemSection() {
    return const _SettingsSection(
      title: 'Systeminformationen',
      icon: Icons.info_outline,
      children: [
        _SystemInformationTile(label: 'App', value: 'ORTHA METEO Ω'),
        _SystemInformationTile(label: 'Version', value: '1.0.0+1'),
        _SystemInformationTile(label: 'Sprint', value: '0.28'),
        _SystemInformationTile(label: 'Branch', value: 'develop-v0.13.0'),
        _SystemInformationTile(label: 'Wetterdaten', value: 'Open-Meteo'),
        _SystemInformationTile(
          label: 'Warnsysteme',
          value: 'DWD · BBK / MoWaS',
        ),
      ],
    );
  }

  Widget _buildStatusMessage() {
    final message = _statusMessage!;

    final isError = message.contains('nicht') || message.contains('konnten');

    return Card(
      color: isError ? const Color(0x553D1515) : const Color(0x55315A3A),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.redAccent : Colors.greenAccent,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  String get _unitSettingsSummary {
    final temperature = _unitSettings.temperatureUnit == TemperatureUnit.celsius
        ? 'Celsius (°C)'
        : 'Fahrenheit (°F)';

    final wind = _unitSettings.windSpeedUnit == WindSpeedUnit.kilometersPerHour
        ? 'km/h'
        : 'Knoten';

    final visibility = _unitSettings.visibilityUnit == VisibilityUnit.kilometers
        ? 'km'
        : 'Meilen';

    final precipitation =
        _unitSettings.precipitationUnit == PrecipitationUnit.millimeters
        ? 'mm'
        : 'Inch';

    return '$temperature · $wind · $visibility · $precipitation';
  }

  String _novaSignalLevelLabel(NovaSignalLevel level) {
    switch (level.name) {
      case 'none':
        return 'Keine Mindeststufe';
      case 'information':
        return 'Information';
      case 'warning':
        return 'Warnung';
      case 'danger':
        return 'Gefahr';
      case 'emergency':
        return 'Notfall';
      default:
        return level.name;
    }
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  static const Color _accentColor = Color(0xFFFFB536);
  static const Color _surfaceColor = Color(0xE6192B3A);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _surfaceColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: _accentColor),
            title: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _SystemInformationTile extends StatelessWidget {
  const _SystemInformationTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 190),
        child: Text(
          value,
          textAlign: TextAlign.end,
          style: const TextStyle(color: Color(0xFFADB9C7)),
        ),
      ),
    );
  }
}
