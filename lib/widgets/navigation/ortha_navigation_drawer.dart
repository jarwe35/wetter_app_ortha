import 'package:flutter/material.dart';

class OrthaNavigationDrawer extends StatelessWidget {
  const OrthaNavigationDrawer({super.key, required this.onSelect});

  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF16324F),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 28),

            const Text(
              'ORTHA METEO Ω',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            _entry(context, Icons.home_outlined, 'Heute', 0),
            _entry(context, Icons.warning_amber_outlined, 'Warnungen', 1),
            _entry(context, Icons.shield_outlined, 'Risikoanalyse', 2),
            _entry(context, Icons.radar_outlined, 'Radar', 3),
            _entry(context, Icons.cloud_outlined, 'Satellit', 4),
            _entry(context, Icons.local_florist_outlined, 'Pollen', 5),
            _entry(context, Icons.location_on_outlined, 'Meine Orte', 6),

            const Divider(color: Colors.white24),

            _entry(
              context,
              Icons.notifications_outlined,
              'Benachrichtigungen',
              7,
            ),
            _entry(context, Icons.settings_outlined, 'Einstellungen', 8),
            _entry(context, Icons.info_outline, 'Impressum', 9),
            _entry(context, Icons.lock_outline, 'Datenschutz', 10),

            const Spacer(),

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

  Widget _entry(BuildContext context, IconData icon, String text, int index) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFE2B85C)),
      title: Text(text, style: const TextStyle(color: Colors.white)),
      onTap: () {
        Navigator.pop(context);
        onSelect(index);
      },
    );
  }
}
