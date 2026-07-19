import 'package:flutter/material.dart';

import '../widgets/ortha_ui/ortha_card.dart';
import '../widgets/ortha_ui/ortha_section_header.dart';

const Color _orthaSurface = Color(0xFFFFFFFF);
const Color _orthaSecondaryText = Color(0xFF587080);
const Color _orthaAccent = Color(0xFFD5A84A);

class PollenPage extends StatelessWidget {
  final String place;
  final VoidCallback onRefresh;

  const PollenPage({super.key, required this.place, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        OrthaSectionHeader(
          icon: Icons.grass_outlined,
          title: 'ORTHA Pollen',
          subtitle: 'Pollenflug und Belastung für $place',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Pollendaten aktualisieren',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ),
        const SizedBox(height: 18),
        OrthaCard(
          backgroundColor: _orthaSurface,
          borderRadius: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.eco_outlined, color: _orthaAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Pollenflugvorhersage',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Die standortbezogene Pollenflugvorhersage wird '
                'in einem der nächsten Entwicklungsschritte '
                'angebunden. Geplant sind Belastungsstufen für '
                'wichtige Pollenarten sowie persönliche Hinweise.',
                style: TextStyle(color: _orthaSecondaryText, height: 1.45),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _orthaAccent.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _orthaAccent.withValues(alpha: 0.22),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: _orthaAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Noch keine Pollendaten verfügbar. '
                        'Die Seite ist bereits vollständig in '
                        'die ORTHA-Navigation eingebunden.',
                        style: TextStyle(
                          color: _orthaSecondaryText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}
