import 'package:flutter/material.dart';

class OrthaPrivacyPage extends StatelessWidget {
  const OrthaPrivacyPage({super.key});

  static const Color _accentColor = Color(0xFFFFB536);
  static const Color _surfaceColor = Color(0xE6192B3A);
  static const Color _secondaryTextColor = Color(0xFFADB9C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Datenschutz')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _PrivacyHeader(),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Verantwortlicher',
            icon: Icons.person_outline,
            children: [
              _PrivacyEntry(label: 'Name', value: 'Bernhard Klaffke'),
              _PrivacyEntry(
                label: 'Anschrift',
                value: 'Straße und Hausnummer\nPLZ und Ort',
              ),
              _PrivacyEntry(
                label: 'E-Mail',
                value: 'info@ortha-system.de',
                selectable: true,
              ),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Grundsatz',
            icon: Icons.shield_outlined,
            children: [
              _PrivacyParagraph(
                text:
                    'ORTHA METEO Ω verarbeitet nur solche Daten, die für '
                    'die Bereitstellung der App-Funktionen erforderlich '
                    'sind. Einstellungen werden soweit möglich lokal auf '
                    'dem verwendeten Gerät gespeichert.',
              ),
              _PrivacyParagraph(
                text:
                    'Eine Weitergabe personenbezogener Daten zu '
                    'Werbezwecken ist nicht vorgesehen.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Standortdaten',
            icon: Icons.location_on_outlined,
            children: [
              _PrivacyParagraph(
                text:
                    'Die App kann Standortdaten verwenden, um Wetter-, '
                    'Pollen- und Warninformationen für den aktuellen oder '
                    'einen ausgewählten Ort bereitzustellen.',
              ),
              _PrivacyParagraph(
                text:
                    'Der Standortzugriff erfolgt nur nach Erteilung der '
                    'entsprechenden Geräteberechtigung. Die Berechtigung '
                    'kann über die Systemeinstellungen widerrufen werden.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Externe Datenabfragen',
            icon: Icons.cloud_outlined,
            children: [
              _PrivacyParagraph(
                text:
                    'Für ortsbezogene Wetter-, Pollen- und Warninformationen '
                    'können geografische Koordinaten, Ortsangaben und '
                    'technische Anfrageinformationen an externe '
                    'Datenanbieter übermittelt werden.',
              ),
              _PrivacyEntry(label: 'Wetterdaten', value: 'Open-Meteo'),
              _PrivacyEntry(
                label: 'Wetterwarnungen',
                value: 'Deutscher Wetterdienst',
              ),
              _PrivacyEntry(label: 'Bevölkerungsschutz', value: 'BBK / MoWaS'),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Lokale Speicherung',
            icon: Icons.storage_outlined,
            children: [
              _PrivacyParagraph(
                text:
                    'Ausgewählte Orte, Einheiten, Warnpräferenzen sowie '
                    'NOVA- und Spracheinstellungen können lokal auf dem '
                    'verwendeten Gerät gespeichert werden.',
              ),
              _PrivacyParagraph(
                text:
                    'Die Speicherung dient dazu, die gewählten Einstellungen '
                    'bei einem späteren App-Start wiederherzustellen.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Benachrichtigungen und Sprachausgabe',
            icon: Icons.notifications_outlined,
            children: [
              _PrivacyParagraph(
                text:
                    'Sofern die entsprechenden Berechtigungen vorliegen, '
                    'kann ORTHA METEO Ω lokale Benachrichtigungen, '
                    'Warnsignale, Vibration und Sprachausgabe verwenden.',
              ),
              _PrivacyParagraph(
                text:
                    'Die Funktionen können im ORTHA Control Center Ω '
                    'deaktiviert oder eingeschränkt werden.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Berechtigungen',
            icon: Icons.admin_panel_settings_outlined,
            children: [
              _PrivacyEntry(
                label: 'Standort',
                value: 'Ortsbezogene Informationen',
              ),
              _PrivacyEntry(
                label: 'Benachrichtigungen',
                value: 'Lokale Warnmeldungen',
              ),
              _PrivacyEntry(label: 'Vibration', value: 'Haptische Warnsignale'),
              _PrivacyEntry(label: 'Netzwerk', value: 'Abruf externer Daten'),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Speicherdauer und Löschung',
            icon: Icons.delete_outline,
            children: [
              _PrivacyParagraph(
                text:
                    'Lokal gespeicherte Einstellungen bleiben grundsätzlich '
                    'erhalten, bis sie geändert, zurückgesetzt oder durch '
                    'die Deinstallation der App entfernt werden.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Entwicklungsstand',
            icon: Icons.developer_mode_outlined,
            children: [
              _PrivacyParagraph(
                text:
                    'ORTHA METEO Ω befindet sich derzeit im Entwicklungs- '
                    'und Demonstrationsbetrieb. Vor einer öffentlichen '
                    'Veröffentlichung muss diese Datenschutzerklärung '
                    'anhand der final eingesetzten Dienste, Berechtigungen '
                    'und Datenflüsse rechtlich geprüft werden.',
              ),
            ],
          ),
          SizedBox(height: 16),
          _PrivacySection(
            title: 'Kontakt',
            icon: Icons.contact_support_outlined,
            children: [
              _PrivacyEntry(
                label: 'E-Mail',
                value: 'info@ortha-system.de',
                selectable: true,
              ),
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _PrivacyHeader extends StatelessWidget {
  const _PrivacyHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: OrthaPrivacyPage._surfaceColor,
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.privacy_tip_outlined,
              color: OrthaPrivacyPage._accentColor,
              size: 30,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Datenschutz bei ORTHA METEO Ω',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Informationen zu Datenverarbeitung, Speicherung '
                    'und Geräteberechtigungen.',
                    style: TextStyle(
                      color: OrthaPrivacyPage._secondaryTextColor,
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

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({
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
      color: OrthaPrivacyPage._surfaceColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: OrthaPrivacyPage._accentColor),
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

class _PrivacyParagraph extends StatelessWidget {
  const _PrivacyParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(
            color: OrthaPrivacyPage._secondaryTextColor,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _PrivacyEntry extends StatelessWidget {
  const _PrivacyEntry({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final Widget valueWidget;

    if (selectable) {
      valueWidget = SelectableText(
        value,
        textAlign: TextAlign.end,
        style: const TextStyle(
          color: OrthaPrivacyPage._secondaryTextColor,
          height: 1.4,
        ),
      );
    } else {
      valueWidget = Text(
        value,
        textAlign: TextAlign.end,
        style: const TextStyle(
          color: OrthaPrivacyPage._secondaryTextColor,
          height: 1.4,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(flex: 3, child: valueWidget),
        ],
      ),
    );
  }
}
