import 'package:flutter/material.dart';

import 'nova_speech_settings.dart';
import 'nova_speech_settings_store.dart';
import '../notifications/flutter_nova_speech_service.dart';

class NovaSpeechSettingsPage extends StatefulWidget {
  const NovaSpeechSettingsPage({super.key});

  @override
  State<NovaSpeechSettingsPage> createState() => _NovaSpeechSettingsPageState();
}

class _NovaSpeechSettingsPageState extends State<NovaSpeechSettingsPage> {
  static const Color _accentColor = Color(0xFFFFB536);
  static const Color _surfaceColor = Color(0xE6192B3A);
  static const Color _secondaryTextColor = Color(0xFFADB9C7);

  final NovaSpeechSettingsStore _store = NovaSpeechSettingsStore();

  late final FlutterNovaSpeechService _speechService = FlutterNovaSpeechService(
    settingsStore: _store,
  );

  NovaSpeechSettings _settings = NovaSpeechSettings.defaults;

  bool _loading = true;
  bool _saving = false;
  bool _testingSpeech = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _store.load();

      if (!mounted) {
        return;
      }

      setState(() {
        _settings = settings;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = false;
      });

      _showMessage('NOVA-Spracheinstellungen konnten nicht geladen werden.');
    }
  }

  Future<void> _save() async {
    if (_saving) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _store.save(_settings);

      if (!mounted) {
        return;
      }

      _showMessage('NOVA-Spracheinstellungen wurden gespeichert.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'NOVA-Spracheinstellungen konnten nicht gespeichert werden.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _testSpeech() async {
    if (_testingSpeech || _saving) {
      return;
    }

    setState(() {
      _testingSpeech = true;
    });

    try {
      await _store.save(_settings);
      await _speechService.speakTestMessage();

      if (!mounted) {
        return;
      }

      _showMessage('NOVA-Testansage wurde gestartet.');
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('Die NOVA-Testansage konnte nicht gestartet werden.');
    } finally {
      if (mounted) {
        setState(() {
          _testingSpeech = false;
        });
      }
    }
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Spracheinstellungen zurücksetzen?'),
          content: const Text(
            'Alle erweiterten NOVA-Sprachparameter werden '
            'auf die ORTHA-Standardwerte zurückgesetzt.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Zurücksetzen'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    setState(() {
      _settings = NovaSpeechSettings.defaults;
    });

    await _save();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _percentageLabel(double value) {
    return '${(value * 100).round()} %';
  }

  String _speechRateLabel(double value) {
    if (value < 0.38) {
      return 'Langsam';
    }

    if (value < 0.58) {
      return 'Normal';
    }

    return 'Schnell';
  }

  String _pitchLabel(double value) {
    if (value < 0.85) {
      return 'Tief';
    }

    if (value <= 1.15) {
      return 'Normal';
    }

    return 'Hoch';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NOVA Sprachausgabe'),
        actions: [
          IconButton(
            tooltip: 'Standardwerte wiederherstellen',
            onPressed: _loading || _saving ? null : _reset,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const _SpeechHeader(),
                const SizedBox(height: 16),
                _buildLanguageSection(),
                const SizedBox(height: 16),
                _buildVoiceSection(),
                const SizedBox(height: 16),
                _buildContentSection(),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    _saving ? 'Wird gespeichert …' : 'Einstellungen speichern',
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: _saving || _testingSpeech ? null : _testSpeech,
                  icon: _testingSpeech
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.volume_up_outlined),
                  label: Text(
                    _testingSpeech
                        ? 'Testansage läuft …'
                        : 'NOVA-Testansage anhören',
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildLanguageSection() {
    return _SpeechSection(
      title: 'Sprache',
      icon: Icons.language_outlined,
      children: [
        RadioGroup<String>(
          groupValue: _settings.language,
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _settings = _settings.copyWith(language: value);
            });
          },
          child: const Column(
            children: [
              RadioListTile<String>(
                value: 'de-DE',
                title: Text('Deutsch'),
                subtitle: Text('Deutsch – Deutschland'),
              ),
              RadioListTile<String>(
                value: 'en-US',
                title: Text('Englisch'),
                subtitle: Text('English – United States'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoiceSection() {
    return _SpeechSection(
      title: 'Stimme',
      icon: Icons.record_voice_over_outlined,
      children: [
        _SpeechSlider(
          title: 'Sprechgeschwindigkeit',
          subtitle: _speechRateLabel(_settings.speechRate),
          value: _settings.speechRate,
          minimum: 0.2,
          maximum: 0.8,
          divisions: 12,
          valueLabel: _settings.speechRate.toStringAsFixed(2),
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(speechRate: value);
            });
          },
        ),
        const Divider(height: 1),
        _SpeechSlider(
          title: 'Tonhöhe',
          subtitle: _pitchLabel(_settings.pitch),
          value: _settings.pitch,
          minimum: 0.5,
          maximum: 2.0,
          divisions: 15,
          valueLabel: _settings.pitch.toStringAsFixed(2),
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(pitch: value);
            });
          },
        ),
        const Divider(height: 1),
        _SpeechSlider(
          title: 'Lautstärke',
          subtitle: _percentageLabel(_settings.volume),
          value: _settings.volume,
          minimum: 0.0,
          maximum: 1.0,
          divisions: 10,
          valueLabel: _percentageLabel(_settings.volume),
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(volume: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return _SpeechSection(
      title: 'Warnansagen',
      icon: Icons.campaign_outlined,
      children: [
        SwitchListTile.adaptive(
          value: _settings.announceLocation,
          title: const Text('Ort ansagen'),
          subtitle: const Text(
            'NOVA nennt den betroffenen Ort in der Warnansage.',
          ),
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(announceLocation: value);
            });
          },
        ),
        const Divider(height: 1),
        SwitchListTile.adaptive(
          value: _settings.announceWarningSource,
          title: const Text('Warnquelle ansagen'),
          subtitle: const Text(
            'NOVA nennt beispielsweise DWD oder BBK als Quelle.',
          ),
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(announceWarningSource: value);
            });
          },
        ),
        const Divider(height: 1),
        SwitchListTile.adaptive(
          value: _settings.repeatCriticalWarnings,
          title: const Text('Kritische Warnungen wiederholen'),
          subtitle: const Text(
            'Gefahren- und Notfallwarnungen werden zur '
            'besseren Wahrnehmung wiederholt.',
          ),
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(repeatCriticalWarnings: value);
            });
          },
        ),
      ],
    );
  }
}

class _SpeechHeader extends StatelessWidget {
  const _SpeechHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _NovaSpeechSettingsPageState._surfaceColor,
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.graphic_eq,
              color: _NovaSpeechSettingsPageState._accentColor,
              size: 30,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'NOVA Voice Engine Ω',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Passe Sprache, Geschwindigkeit, Tonhöhe, '
                    'Lautstärke und den Inhalt der Warnansagen an.',
                    style: TextStyle(
                      color: _NovaSpeechSettingsPageState._secondaryTextColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpeechSection extends StatelessWidget {
  const _SpeechSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _NovaSpeechSettingsPageState._surfaceColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              icon,
              color: _NovaSpeechSettingsPageState._accentColor,
            ),
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

class _SpeechSlider extends StatelessWidget {
  const _SpeechSlider({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.divisions,
    required this.valueLabel,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final double minimum;
  final double maximum;
  final int divisions;
  final String valueLabel;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _NovaSpeechSettingsPageState._secondaryTextColor,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: minimum,
            max: maximum,
            divisions: divisions,
            label: valueLabel,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
