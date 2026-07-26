import 'package:flutter/material.dart';

import '../models/official_weather_warning.dart';
import '../widgets/warnings/official_warning_map.dart';

const Color orthaBackground = Color(0xFFF4F8FB);
const Color orthaSurface = Color(0xFFFFFFFF);
const Color orthaPrimaryText = Color(0xFF17324D);
const Color orthaSecondaryText = Color(0xFF607D8B);
const Color orthaAccent = Color(0xFFD5A84A);
const Color orthaBorder = Color(0xFFD6E2EA);

class WarningCenterPage extends StatelessWidget {
  final VoidCallback? onHome;
  final List<OfficialWeatherWarning> warnings;
  final bool isLoading;
  final String? errorMessage;
  final String place;
  final double latitude;
  final double longitude;

  const WarningCenterPage({
    super.key,
    this.onHome,
    required this.warnings,
    required this.isLoading,
    required this.errorMessage,
    required this.place,
    required this.latitude,
    required this.longitude,
  });

  Color _severityColor(OfficialWarningSeverity severity) {
    switch (severity) {
      case OfficialWarningSeverity.minor:
        return const Color(0xFFD1A928);
      case OfficialWarningSeverity.moderate:
        return const Color(0xFFD77B2E);
      case OfficialWarningSeverity.severe:
        return const Color(0xFFB94A48);
      case OfficialWarningSeverity.extreme:
        return const Color(0xFF7E2634);
      case OfficialWarningSeverity.unknown:
        return const Color(0xFF607D86);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: orthaBackground,
      appBar: AppBar(
        backgroundColor: orthaSurface,
        foregroundColor: orthaPrimaryText,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Zur Übersicht',
          icon: const Icon(Icons.home_outlined),
          onPressed: onHome ?? () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ORTHA METEO Ω',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚠ Warnzentrale',
              style: TextStyle(
                color: orthaPrimaryText,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Amtliche Warnungen für $place',
              style: const TextStyle(color: orthaSecondaryText, fontSize: 14),
            ),
            const SizedBox(height: 18),
            if (isLoading)
              const Center(child: CircularProgressIndicator(color: orthaAccent))
            else if (errorMessage != null)
              Text(errorMessage!)
            else if (warnings.isEmpty)
              _statusCard(
                Icons.verified_outlined,
                'Aktuell liegen keine amtlichen Warnungen vor.',
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: warnings.length,
                  itemBuilder: (context, index) {
                    final warning = warnings[index];
                    final color = _severityColor(warning.severity);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: orthaSurface,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: color.withValues(alpha: 0.65),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.15),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 42,
                            color: color,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  warning.title,
                                  style: const TextStyle(
                                    color: orthaPrimaryText,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  warning.description,
                                  style: const TextStyle(
                                    color: orthaSecondaryText,
                                    height: 1.35,
                                  ),
                                ),
                                if (warning.geometry != null &&
                                    !warning.geometry!.isEmpty) ...[
                                  const SizedBox(height: 14),
                                  OfficialWarningMap(
                                    warning: warning,
                                    latitude: latitude,
                                    longitude: longitude,
                                    place: place,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard(IconData icon, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: orthaSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: orthaBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: orthaAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(color: orthaPrimaryText)),
          ),
        ],
      ),
    );
  }
}
