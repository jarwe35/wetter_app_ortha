import 'package:flutter/material.dart';

class OrthaImprintPage extends StatelessWidget {
  const OrthaImprintPage({super.key});

  static const Color _accentColor = Color(0xFFFFB536);
  static const Color _surfaceColor = Color(0xE6192B3A);
  static const Color _secondaryTextColor = Color(0xFFADB9C7);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Impressum')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _ImprintHeader(),
          SizedBox(height: 16),
          _ImprintSection(
            title: 'Angaben gemäß § 5 DDG',
            icon: Icons.business_outlined,
            children: [
              _ImprintEntry(label: 'Betreiber', value: 'Bernhard Klaffke'),
              _ImprintEntry(
                label: 'Anschrift',
                value: 'Straße und Hausnummer\nPLZ und Ort',
              ),
            ],
          ),
          SizedBox(height: 16),
          _ImprintSection(
            title: 'Kontakt',
            icon: Icons.contact_mail_outlined,
            children: [
              _ImprintEntry(
                label: 'E-Mail',
                value: 'info@ortha-system.de',
                selectable: true,
              ),
              _ImprintEntry(label: 'Telefon', value: 'wird später ergänzt'),
            ],
          ),
          SizedBox(height: 16),
          _ImprintSection(
            title: 'Verantwortlich für den Inhalt',
            icon: Icons.edit_document,
            children: [
              _ImprintEntry(
                label: 'Verantwortlicher',
                value: 'Bernhard Klaffke',
              ),
              _ImprintEntry(
                label: 'Anschrift',
                value: 'Straße und Hausnummer\nPLZ und Ort',
              ),
            ],
          ),
          SizedBox(height: 16),
          _ImprintSection(
            title: 'Hinweis zur Anwendung',
            icon: Icons.info_outline,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Text(
                  'ORTHA METEO Ω stellt Wetter-, Pollen- und '
                  'Warninformationen zur Unterstützung der persönlichen '
                  'Orientierung bereit. Die Anwendung ersetzt keine '
                  'amtlichen Anweisungen, keine behördliche Warnung und '
                  'keine eigenverantwortliche Gefahrenbeurteilung.',
                  style: TextStyle(color: _secondaryTextColor, height: 1.5),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _ImprintSection(
            title: 'Technische Informationen',
            icon: Icons.developer_mode_outlined,
            children: [
              _ImprintEntry(label: 'Anwendung', value: 'ORTHA METEO Ω'),
              _ImprintEntry(label: 'Version', value: '1.0.0+1'),
              _ImprintEntry(label: 'Sprint', value: '0.28'),
              _ImprintEntry(
                label: 'Entwicklungsstand',
                value: 'Development / Debug',
              ),
            ],
          ),
          SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ImprintHeader extends StatelessWidget {
  const _ImprintHeader();

  @override
  Widget build(BuildContext context) {
    return Card(
      color: OrthaImprintPage._surfaceColor,
      child: const Padding(
        padding: EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.gavel_outlined,
              color: OrthaImprintPage._accentColor,
              size: 30,
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORTHA METEO Ω',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Anbieterkennzeichnung und rechtliche '
                    'Kontaktinformationen.',
                    style: TextStyle(
                      color: OrthaImprintPage._secondaryTextColor,
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

class _ImprintSection extends StatelessWidget {
  const _ImprintSection({
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
      color: OrthaImprintPage._surfaceColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: OrthaImprintPage._accentColor),
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

class _ImprintEntry extends StatelessWidget {
  const _ImprintEntry({
    required this.label,
    required this.value,
    this.selectable = false,
  });

  final String label;
  final String value;
  final bool selectable;

  @override
  Widget build(BuildContext context) {
    final valueWidget = selectable
        ? SelectableText(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: OrthaImprintPage._secondaryTextColor,
              height: 1.4,
            ),
          )
        : Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: OrthaImprintPage._secondaryTextColor,
              height: 1.4,
            ),
          );

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
