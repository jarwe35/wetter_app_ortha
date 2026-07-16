part of '../../main.dart';

class DailyForecastCard extends StatefulWidget {
  final List<DailyForecast> forecast;
  final UnitSettings unitSettings;

  const DailyForecastCard({
    super.key,
    required this.forecast,
    required this.unitSettings,
  });

  @override
  State<DailyForecastCard> createState() => _DailyForecastCardState();
}

class _DailyForecastCardState extends State<DailyForecastCard> {
  ForecastRange _selectedRange = ForecastRange.sevenDays;

  @override
  Widget build(BuildContext context) {
    final visibleForecast = _selectedRange.applyTo(widget.forecast);

    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: orthaAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tagesvorhersage',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Temperaturspanne und Niederschlagswahrscheinlichkeit',
            style: TextStyle(color: orthaSecondaryText, fontSize: 13),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: SegmentedButton<ForecastRange>(
              segments: ForecastRange.values
                  .map(
                    (range) => ButtonSegment<ForecastRange>(
                      value: range,
                      label: Text(range.label),
                    ),
                  )
                  .toList(growable: false),
              selected: <ForecastRange>{_selectedRange},
              showSelectedIcon: false,
              onSelectionChanged: (selection) {
                setState(() {
                  _selectedRange = selection.first;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          ...visibleForecast.map(
            (day) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: orthaSurfaceElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: orthaBorder.withValues(alpha: 0.85)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final veryCompact = constraints.maxWidth < 330;
                  final compact = constraints.maxWidth < 520;
                  final iconSize = veryCompact ? 40.0 : 46.0;
                  final horizontalGap = veryCompact ? 9.0 : 12.0;

                  final weatherInfo = Row(
                    children: [
                      OrthaWeatherIcon(
                        weatherCode: day.weatherCode,
                        size: iconSize,
                        semanticLabel: weatherText(day.weatherCode),
                      ),
                      SizedBox(width: horizontalGap),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shortDate(day.date),
                              style: const TextStyle(
                                color: orthaPrimaryText,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              weatherText(day.weatherCode),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: orthaSecondaryText,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );

                  final values = Row(
                    mainAxisSize: compact ? MainAxisSize.max : MainAxisSize.min,
                    children: [
                      Expanded(
                        flex: compact ? 1 : 0,
                        child: _ForecastValue(
                          icon: Icons.arrow_downward,
                          label: 'Min',
                          value: formatTemperature(
                            day.temperatureMin,
                            widget.unitSettings,
                            decimals: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: veryCompact ? 8 : 14),
                      Expanded(
                        flex: compact ? 1 : 0,
                        child: _ForecastValue(
                          icon: Icons.arrow_upward,
                          label: 'Max',
                          value: formatTemperature(
                            day.temperatureMax,
                            widget.unitSettings,
                            decimals: 0,
                          ),
                        ),
                      ),
                      SizedBox(width: veryCompact ? 8 : 14),
                      Expanded(
                        flex: compact ? 1 : 0,
                        child: _ForecastValue(
                          icon: Icons.water_drop_outlined,
                          label: 'Regen',
                          value: '${day.precipitationProbability} %',
                        ),
                      ),
                    ],
                  );

                  if (compact) {
                    return Column(
                      children: [
                        weatherInfo,
                        SizedBox(height: veryCompact ? 11 : 14),
                        values,
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(child: weatherInfo),
                      const SizedBox(width: 18),
                      SizedBox(width: 300, child: values),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ForecastValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: orthaSecondaryText),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(color: orthaSecondaryText, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: orthaPrimaryText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
