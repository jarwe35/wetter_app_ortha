import 'package:flutter/material.dart';

import '../models/official_weather_warning.dart';

class WarningCenterPage extends StatelessWidget {
  final List<OfficialWeatherWarning> warnings;
  final bool isLoading;
  final String? errorMessage;
  final String place;

  const WarningCenterPage({
    super.key,
    required this.warnings,
    required this.isLoading,
    required this.errorMessage,
    required this.place,
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
      appBar: AppBar(title: const Text('Warnzentrale')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amtliche Warnungen für $place',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (errorMessage != null)
              Text(errorMessage!)
            else if (warnings.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Aktuell liegen keine amtlichen Warnungen vor.'),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: warnings.length,
                  itemBuilder: (context, index) {
                    final warning = warnings[index];
                    final color = _severityColor(warning.severity);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          Icons.warning_amber_rounded,
                          color: color,
                          size: 34,
                        ),
                        title: Text(
                          warning.title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          warning.description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
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
}
