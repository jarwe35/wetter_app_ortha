import 'package:flutter/material.dart';

import '../models/official_weather_warning.dart';
import '../theme/ortha_colors.dart';
import '../widgets/warnings/official_warning_map.dart';

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
        return const Color(0xFFFFC83D);
      case OfficialWarningSeverity.moderate:
        return const Color(0xFFFF9838);
      case OfficialWarningSeverity.severe:
        return const Color(0xFFFF625C);
      case OfficialWarningSeverity.extreme:
        return const Color(0xFFE4435D);
      case OfficialWarningSeverity.unknown:
        return const Color(0xFF91A2AF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: OrthaColors.surface.withValues(alpha: 0.96),
        foregroundColor: OrthaColors.primaryText,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Zur Übersicht',
          icon: const Icon(Icons.home_outlined),
          onPressed: onHome ?? () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ORTHA METEO Ω',
          style: TextStyle(
            color: OrthaColors.primaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: OrthaColors.border.withValues(alpha: 0.6),
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _WarningCenterHeading(),
              const SizedBox(height: 20),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: OrthaColors.accent),
      );
    }

    if (errorMessage != null) {
      return Align(
        alignment: Alignment.topCenter,
        child: _StatusCard(
          icon: Icons.cloud_off_outlined,
          title: 'Warnlage konnte nicht geladen werden',
          text: errorMessage!,
          accentColor: const Color(0xFFFF625C),
        ),
      );
    }

    if (warnings.isEmpty) {
      return const Align(
        alignment: Alignment.topCenter,
        child: _StatusCard(
          icon: Icons.verified_outlined,
          title: 'Keine amtliche Warnung',
          text: 'Aktuell liegen keine amtlichen Warnungen vor.',
          accentColor: OrthaColors.accent,
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: warnings.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final warning = warnings[index];
        final severityColor = _severityColor(warning.severity);

        return _WarningCard(
          warning: warning,
          severityColor: severityColor,
          latitude: latitude,
          longitude: longitude,
          place: place,
        );
      },
    );
  }
}

class _WarningCenterHeading extends StatelessWidget {
  const _WarningCenterHeading();

  @override
  Widget build(BuildContext context) {
    final page = context.findAncestorWidgetOfExactType<WarningCenterPage>();
    final place = page?.place ?? 'Mein Standort';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: OrthaColors.accent,
              size: 32,
            ),
            SizedBox(width: 11),
            Expanded(
              child: Text(
                'Warnzentrale',
                style: TextStyle(
                  color: OrthaColors.primaryText,
                  fontSize: 25,
                  height: 1.05,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Amtliche Warnungen für $place',
          style: const TextStyle(
            color: OrthaColors.secondaryText,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color accentColor;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.text,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: OrthaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.52),
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: OrthaColors.shadow.withValues(alpha: 0.52),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
              border: Border.all(color: accentColor.withValues(alpha: 0.62)),
            ),
            child: Icon(icon, color: accentColor, size: 27),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: OrthaColors.primaryText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  text,
                  style: const TextStyle(
                    color: OrthaColors.secondaryText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WarningCard extends StatelessWidget {
  final OfficialWeatherWarning warning;
  final Color severityColor;
  final double latitude;
  final double longitude;
  final String place;

  const _WarningCard({
    required this.warning,
    required this.severityColor,
    required this.latitude,
    required this.longitude,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: OrthaColors.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.65),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: severityColor.withValues(alpha: 0.12),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
          BoxShadow(
            color: OrthaColors.shadow.withValues(alpha: 0.42),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(color: severityColor.withValues(alpha: 0.7)),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              size: 30,
              color: severityColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  warning.title,
                  style: const TextStyle(
                    color: OrthaColors.primaryText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  warning.description,
                  style: const TextStyle(
                    color: OrthaColors.secondaryText,
                    fontSize: 14,
                    height: 1.42,
                  ),
                ),
                if (warning.geometry != null && !warning.geometry!.isEmpty) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: OfficialWarningMap(
                      warning: warning,
                      latitude: latitude,
                      longitude: longitude,
                      place: place,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
