import 'package:flutter/material.dart';

class OrthaNavigationDrawer extends StatelessWidget {
  const OrthaNavigationDrawer({super.key, required this.onSelect});

  final ValueChanged<int> onSelect;

  static const Color _backgroundColor = Color(0xFF16324F);
  static const Color _accentColor = Color(0xFFE2B85C);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _backgroundColor,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 28),
            const Text(
              'ORTHA METEO Ω',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Wetter · Warnungen · Risiko',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60, fontSize: 12),
            ),
            const SizedBox(height: 24),

            _sectionTitle('WETTER'),
            _entry(context, Icons.home_outlined, 'Übersicht', 0),
            _entry(context, Icons.radar_outlined, 'Live-Radar', 3),
            _entry(context, Icons.local_florist_outlined, 'Pollen', 5),

            _sectionTitle('SICHERHEIT'),
            _entry(context, Icons.campaign_outlined, 'Warnzentrale', 11),
            _entry(context, Icons.warning_amber_outlined, 'Warnungen', 1),

            // _entry(context, Icons.shield_outlined, 'Risikoanalyse', 2),
            _sectionTitle('ORTE'),
            _entry(context, Icons.location_on_outlined, 'Meine Orte', 6),

            _sectionTitle('ORTHA'),
            _entry(context, Icons.notifications_active_outlined, 'NOVA', 7),
            _entry(context, Icons.settings_outlined, 'Einstellungen', 8),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Divider(color: Colors.white24, height: 1),
            ),

            _sectionTitle('INFORMATIONEN'),
            _entry(context, Icons.info_outline, 'Impressum', 9),
            _entry(context, Icons.lock_outline, 'Datenschutz', 10),

            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'ORTHA METEO Ω\nSprint 0.16',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Text(
        text,
        style: const TextStyle(
          color: _accentColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _entry(BuildContext context, IconData icon, String text, int index) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      leading: Icon(icon, color: _accentColor),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onSelect(index);
      },
    );
  }
}
