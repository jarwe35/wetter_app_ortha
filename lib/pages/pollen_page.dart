import 'package:flutter/material.dart';

import '../models/pollen_forecast.dart';
import '../services/pollen_service.dart';
import '../theme/ortha_colors.dart';
import '../widgets/common/ortha_premium_card.dart';
import '../widgets/ortha_ui/ortha_section_header.dart';

const Color _orthaPrimaryText = OrthaColors.primaryText;
const Color _orthaSecondaryText = OrthaColors.secondaryText;
const Color _orthaAccent = OrthaColors.accent;

class PollenPage extends StatefulWidget {
  final String place;
  final double? latitude;
  final double? longitude;

  const PollenPage({
    super.key,
    required this.place,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<PollenPage> createState() => _PollenPageState();
}

class _PollenPageState extends State<PollenPage> {
  final PollenService _pollenService = PollenService();

  PollenForecast? _forecast;
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPollen();
  }

  @override
  void didUpdateWidget(covariant PollenPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude ||
        oldWidget.place != widget.place) {
      _loadPollen();
    }
  }

  Future<void> _loadPollen() async {
    final latitude = widget.latitude;
    final longitude = widget.longitude;

    if (latitude == null || longitude == null) {
      setState(() {
        _forecast = null;
        _errorMessage =
            'Für ${widget.place} sind noch keine Koordinaten verfügbar. '
            'Bitte den Ort erneut auswählen oder „Mein Standort“ verwenden.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final forecast = await _pollenService.loadForecast(
        latitude: latitude,
        longitude: longitude,
      );

      if (!mounted) return;

      setState(() {
        _forecast = forecast;
        _isLoading = false;
      });
    } on PollenServiceException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.message;
        _isLoading = false;
      });
    } on Exception catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage =
            'Die Pollenflugvorhersage konnte nicht geladen werden: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        OrthaSectionHeader(
          icon: Icons.grass_outlined,
          title: 'ORTHA Pollen',
          subtitle: 'Pollenflug und Belastung für ${widget.place}',
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            tooltip: 'Pollendaten aktualisieren',
            onPressed: _isLoading ? null : _loadPollen,
            icon: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: OrthaColors.accent,
                    ),
                  )
                : const Icon(Icons.refresh, color: OrthaColors.accent),
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading && _forecast == null)
          const OrthaPremiumCard(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 34),
              child: Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 18),
                    Text(
                      'Pollenflugvorhersage wird geladen …',
                      style: TextStyle(color: _orthaSecondaryText),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_errorMessage != null)
          _ErrorCard(message: _errorMessage!, onRetry: _loadPollen)
        else if (_forecast == null || _forecast!.days.isEmpty)
          const _InformationCard(
            icon: Icons.info_outline,
            title: 'Keine Vorhersage verfügbar',
            message:
                'Für diesen Standort liegen derzeit keine Pollendaten vor.',
          )
        else ...[
          _OverviewCard(place: widget.place, forecast: _forecast!),
          const SizedBox(height: 18),
          ..._forecast!.days.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: _DailyForecastCard(day: day),
            ),
          ),
          const _InformationCard(
            icon: Icons.health_and_safety_outlined,
            title: 'Hinweis',
            message:
                'Die Werte sind modellbasierte Vorhersagen in Pollenkörnern '
                'pro Kubikmeter Luft. Individuelle Beschwerden können davon '
                'abweichen. Medizinische Entscheidungen sollten nicht allein '
                'auf diese Anzeige gestützt werden.',
          ),
        ],
        const SizedBox(height: 30),
      ],
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final String place;
  final PollenForecast forecast;

  const _OverviewCard({required this.place, required this.forecast});

  @override
  Widget build(BuildContext context) {
    final today = forecast.days.first;
    final strongest = today.strongestValue;

    return OrthaPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_outlined, color: _orthaAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pollenbelastung heute',
                  style: TextStyle(
                    color: _orthaPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (strongest == null || strongest.concentration <= 0)
            Text(
              'Für $place wird heute keine nennenswerte '
              'Pollenbelastung prognostiziert.',
              style: const TextStyle(color: _orthaSecondaryText, height: 1.45),
            )
          else ...[
            Text(
              'Stärkste Belastung heute',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: _orthaSecondaryText),
            ),
            const SizedBox(height: 5),
            Text(
              strongest.type.label,
              style: const TextStyle(
                color: _orthaPrimaryText,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${strongest.level.label} · '
              '${_formatConcentration(strongest.concentration)} Körner/m³',
              style: const TextStyle(color: _orthaSecondaryText, fontSize: 15),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            '${forecast.days.length}-Tage-Vorhersage · '
            'Lokale Zeitzone: ${forecast.timezone}',
            style: const TextStyle(color: _orthaSecondaryText, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DailyForecastCard extends StatelessWidget {
  final DailyPollenForecast day;

  const _DailyForecastCard({required this.day});

  @override
  Widget build(BuildContext context) {
    return OrthaPremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(day.date),
            style: const TextStyle(
              color: _orthaPrimaryText,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...day.values
              .where((value) => value.type != PollenType.olive)
              .map(
                (value) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PollenRow(value: value),
                ),
              ),
        ],
      ),
    );
  }
}

class _PollenRow extends StatelessWidget {
  final PollenValue value;

  const _PollenRow({required this.value});

  @override
  Widget build(BuildContext context) {
    final progress = (value.concentration / 150).clamp(0.0, 1.0);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Text(
                value.type.label,
                style: const TextStyle(
                  color: _orthaPrimaryText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                value.level.label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _levelColor(value.level),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                '${_formatConcentration(value.concentration)} Körner/m³',
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: _orthaSecondaryText,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: progress,
            backgroundColor: OrthaColors.border.withValues(alpha: 0.42),
            valueColor: AlwaysStoppedAnimation<Color>(_levelColor(value.level)),
          ),
        ),
      ],
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return OrthaPremiumCard(
      child: Column(
        children: [
          const Icon(Icons.cloud_off_outlined, color: _orthaAccent, size: 38),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _orthaSecondaryText, height: 1.45),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, color: OrthaColors.accent),
            label: const Text('Erneut versuchen'),
          ),
        ],
      ),
    );
  }
}

class _InformationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _InformationCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return OrthaPremiumCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _orthaAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: _orthaPrimaryText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  style: const TextStyle(
                    color: _orthaSecondaryText,
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

Color _levelColor(PollenLoadLevel level) {
  switch (level) {
    case PollenLoadLevel.none:
      return const Color(0xFF78909C);
    case PollenLoadLevel.low:
      return const Color(0xFF43A047);
    case PollenLoadLevel.moderate:
      return const Color(0xFFF9A825);
    case PollenLoadLevel.high:
      return const Color(0xFFEF6C00);
    case PollenLoadLevel.veryHigh:
      return const Color(0xFFC62828);
  }
}

String _formatConcentration(double value) {
  if (value >= 100) {
    return value.round().toString();
  }

  if (value >= 10) {
    return value.toStringAsFixed(1);
  }

  return value.toStringAsFixed(2);
}

String _formatDate(DateTime date) {
  const weekdays = [
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];

  const months = [
    'Januar',
    'Februar',
    'März',
    'April',
    'Mai',
    'Juni',
    'Juli',
    'August',
    'September',
    'Oktober',
    'November',
    'Dezember',
  ];

  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final difference = target.difference(today).inDays;

  if (difference == 0) {
    return 'Heute · ${date.day}. ${months[date.month - 1]}';
  }

  if (difference == 1) {
    return 'Morgen · ${date.day}. ${months[date.month - 1]}';
  }

  return '${weekdays[date.weekday - 1]} · '
      '${date.day}. ${months[date.month - 1]}';
}
