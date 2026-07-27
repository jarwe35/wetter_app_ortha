import 'package:flutter/material.dart';

import 'ortha_widget_settings.dart';
import 'ortha_widget_settings_store.dart';

class OrthaWidgetSettingsPage extends StatefulWidget {
  const OrthaWidgetSettingsPage({super.key});

  @override
  State<OrthaWidgetSettingsPage> createState() =>
      _OrthaWidgetSettingsPageState();
}

class _OrthaWidgetSettingsPageState extends State<OrthaWidgetSettingsPage> {
  static const _accentColor = Color(0xFF4BA8E8);
  static const _surfaceColor = Color(0xE6162938);
  static const _secondaryTextColor = Color(0xFFADB9C7);

  final OrthaWidgetSettingsStore _store = const OrthaWidgetSettingsStore();

  OrthaWidgetSettings _settings = OrthaWidgetSettings.defaults;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final settings = await _store.load();

      if (!mounted) return;

      setState(() {
        _settings = settings;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage('Die Widget-Einstellungen konnten nicht geladen werden.');
    }
  }

  Future<void> _save() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      await _store.save(_settings);

      if (!mounted) return;

      _showMessage('Widget-Einstellungen wurden gespeichert.');
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Die Widget-Einstellungen konnten nicht gespeichert werden.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _reset() async {
    setState(() {
      _settings = OrthaWidgetSettings.defaults;
    });

    await _store.reset();

    if (!mounted) return;

    _showMessage('Widget-Einstellungen wurden zurückgesetzt.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ORTHA Widget Ω'),
        actions: [
          IconButton(
            tooltip: 'Zurücksetzen',
            onPressed: _loading || _saving ? null : _reset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          IconButton(
            tooltip: 'Speichern',
            onPressed: _loading || _saving ? null : _save,
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _buildNotice(),
                const SizedBox(height: 16),
                _buildAppearanceSection(),
                const SizedBox(height: 16),
                _buildContentSection(),
                const SizedBox(height: 16),
                _buildPreviewSection(),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(
                    _saving
                        ? 'Wird gespeichert …'
                        : 'Widget-Einstellungen speichern',
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildNotice() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _accentColor.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accentColor.withValues(alpha: 0.32)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: _accentColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Die Einstellungen werden gespeichert und unmittelbar auf das '
              'Android-Startbildschirm-Widget übertragen.',
              style: TextStyle(color: _secondaryTextColor, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _WidgetSettingsCard(
      title: 'Darstellung',
      icon: Icons.palette_outlined,
      children: [
        const Text(
          'Hintergrund',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        SegmentedButton<OrthaWidgetBackgroundStyle>(
          segments: const [
            ButtonSegment(
              value: OrthaWidgetBackgroundStyle.gradient,
              icon: Icon(Icons.gradient_outlined),
              label: Text('Verlauf'),
            ),
            ButtonSegment(
              value: OrthaWidgetBackgroundStyle.solid,
              icon: Icon(Icons.square_outlined),
              label: Text('Einfarbig'),
            ),
          ],
          selected: {_settings.backgroundStyle},
          onSelectionChanged: (selection) {
            setState(() {
              _settings = _settings.copyWith(backgroundStyle: selection.first);
            });
          },
        ),
        const SizedBox(height: 20),
        const Text('Design', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 10),
        SegmentedButton<OrthaWidgetThemeStyle>(
          segments: const [
            ButtonSegment(
              value: OrthaWidgetThemeStyle.dark,
              label: Text('Dunkel'),
            ),
            ButtonSegment(
              value: OrthaWidgetThemeStyle.light,
              label: Text('Hell'),
            ),
            ButtonSegment(
              value: OrthaWidgetThemeStyle.automatic,
              label: Text('Auto'),
            ),
          ],
          selected: {_settings.themeStyle},
          onSelectionChanged: (selection) {
            setState(() {
              _settings = _settings.copyWith(themeStyle: selection.first);
            });
          },
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Transparenz',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            Text(
              '${_settings.transparencyPercent} %',
              style: const TextStyle(color: _secondaryTextColor),
            ),
          ],
        ),
        Slider(
          value: _settings.transparencyPercent.toDouble(),
          min: 0,
          max: 40,
          divisions: 8,
          label: '${_settings.transparencyPercent} %',
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(
                transparencyPercent: value.round(),
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return _WidgetSettingsCard(
      title: 'Inhalt',
      icon: Icons.widgets_outlined,
      children: [
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.location_on_outlined),
          title: const Text('Ort'),
          value: _settings.showPlace,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(showPlace: value);
            });
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.thermostat_outlined),
          title: const Text('Temperatur'),
          value: _settings.showTemperature,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(showTemperature: value);
            });
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.wb_cloudy_outlined),
          title: const Text('Wettericon'),
          value: _settings.showWeatherIcon,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(showWeatherIcon: value);
            });
          },
        ),
        SwitchListTile.adaptive(
          contentPadding: EdgeInsets.zero,
          secondary: const Icon(Icons.warning_amber_outlined),
          title: const Text('Warnampel'),
          value: _settings.showWarningLight,
          onChanged: (value) {
            setState(() {
              _settings = _settings.copyWith(showWarningLight: value);
            });
          },
        ),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return _WidgetSettingsCard(
      title: 'Vorschau',
      icon: Icons.preview_outlined,
      children: [_WidgetPreview(settings: _settings)],
    );
  }
}

class _WidgetPreview extends StatelessWidget {
  const _WidgetPreview({required this.settings});

  final OrthaWidgetSettings settings;

  @override
  Widget build(BuildContext context) {
    final useLightTheme = settings.themeStyle == OrthaWidgetThemeStyle.light;

    final textColor = useLightTheme ? const Color(0xFF071522) : Colors.white;

    final secondaryColor = useLightTheme
        ? const Color(0xFF526573)
        : const Color(0xFF9BB1C1);

    final backgroundColors = useLightTheme
        ? const [Color(0xFFF4F7FA), Color(0xFFD6E1E9)]
        : const [Color(0xFF06131E), Color(0xFF0B2638)];

    final opacity = 1 - settings.transparencyPercent / 100;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: opacity,
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: settings.backgroundStyle == OrthaWidgetBackgroundStyle.solid
              ? backgroundColors.first
              : null,
          gradient:
              settings.backgroundStyle == OrthaWidgetBackgroundStyle.gradient
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: backgroundColors,
                )
              : null,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: const Color(0xFF4BA8E8).withValues(alpha: 0.45),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              spreadRadius: 1,
              color: const Color(0xFF4BA8E8).withValues(alpha: 0.10),
            ),
          ],
        ),
        child: Row(
          children: [
            if (settings.showWarningLight) ...[
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '●',
                    style: TextStyle(color: Color(0xFF43D36B), fontSize: 28),
                  ),
                  Text(
                    'Keine Warnung',
                    style: TextStyle(color: Color(0xFF59DD82), fontSize: 9),
                  ),
                ],
              ),
              const SizedBox(width: 18),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (settings.showPlace)
                    Text(
                      'Duisburg',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                  if (settings.showPlace) const SizedBox(height: 3),
                  Text(
                    'Aktuelles Wetter',
                    style: TextStyle(color: secondaryColor, fontSize: 10),
                  ),
                  if (settings.showTemperature)
                    Text(
                      '21 °C',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 34,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                ],
              ),
            ),
            if (settings.showWeatherIcon)
              const Text('🌦️', style: TextStyle(fontSize: 42)),
          ],
        ),
      ),
    );
  }
}

class _WidgetSettingsCard extends StatelessWidget {
  const _WidgetSettingsCard({
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
      color: _OrthaWidgetSettingsPageState._surfaceColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, color: _OrthaWidgetSettingsPageState._accentColor),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
