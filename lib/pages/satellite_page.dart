import 'package:flutter/material.dart';

const Color _orthaSurface = Color(0xFFFFFFFF);
const Color _orthaPrimaryText = Color(0xFF17324D);
const Color _orthaSecondaryText = Color(0xFF607D8B);
const Color _orthaAccent = Color(0xFFD5A84A);
const Color _orthaBorder = Color(0xFFD6E2EA);

class SatellitePage extends StatelessWidget {
  final String place;
  final num? cloudCover;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRefresh;

  const SatellitePage({
    super.key,
    required this.place,
    required this.cloudCover,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _SectionHeader(
          icon: Icons.satellite_alt_outlined,
          title: 'ORTHA Satellit',
          subtitle: 'Satelliten- und Wolkenlage für $place',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Satellitendaten aktualisieren',
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
          ),
        ),
        const SizedBox(height: 18),
        _CardBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.cloud_outlined, color: _orthaAccent),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Satellitenansicht',
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
                'Die Satellitenkarte wird in einem der nächsten '
                'Entwicklungsschritte angebunden. Bereits verfügbar '
                'ist die aktuelle Bewölkung für den ausgewählten Ort.',
                style: TextStyle(color: _orthaSecondaryText, height: 1.45),
              ),
              const SizedBox(height: 18),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (errorMessage != null)
                Text(
                  errorMessage!,
                  style: const TextStyle(color: _orthaPrimaryText),
                )
              else if (cloudCover != null)
                Row(
                  children: [
                    const Icon(
                      Icons.filter_drama_outlined,
                      color: _orthaAccent,
                      size: 32,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Aktuelle Bewölkung',
                            style: TextStyle(
                              color: _orthaSecondaryText,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${cloudCover!.round()} %',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: _orthaPrimaryText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              else
                const Text(
                  'Noch keine Wetterdaten verfügbar.',
                  style: TextStyle(color: _orthaSecondaryText),
                ),
            ],
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _orthaSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _orthaBorder),
          ),
          child: Icon(icon, color: _orthaAccent, size: 28),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: _orthaPrimaryText,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: _orthaSecondaryText,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CardBox extends StatelessWidget {
  final Widget child;

  const _CardBox({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _orthaSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _orthaBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}
