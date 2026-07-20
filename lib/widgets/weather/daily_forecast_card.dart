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
                  style: TextStyle(
                    color: orthaPrimaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Temperaturen und Niederschlagswahrscheinlichkeit',
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
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final veryCompact = constraints.maxWidth < 350;
              final tileWidth = veryCompact ? 98.0 : 110.0;
              final tileHeight = veryCompact ? 240.0 : 252.0;

              return SizedBox(
                height: tileHeight,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 4),
                  itemCount: visibleForecast.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final day = visibleForecast[index];

                    return SizedBox(
                      width: tileWidth,
                      child: _DailyForecastTile(
                        day: day,
                        unitSettings: widget.unitSettings,
                        isToday: _isToday(day.date),
                        compact: veryCompact,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DailyForecastTile extends StatelessWidget {
  final DailyForecast day;
  final UnitSettings unitSettings;
  final bool isToday;
  final bool compact;

  const _DailyForecastTile({
    required this.day,
    required this.unitSettings,
    required this.isToday,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${_forecastDayLabel(day.date, isToday: isToday)}, '
          '${weatherText(day.weatherCode)}, '
          'Höchsttemperatur '
          '${formatTemperature(day.temperatureMax, unitSettings, decimals: 0)}, '
          'Tiefsttemperatur '
          '${formatTemperature(day.temperatureMin, unitSettings, decimals: 0)}, '
          '${day.precipitationProbability} Prozent Niederschlagswahrscheinlichkeit',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 9 : 11,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFFFFF8E8) : orthaSurfaceElevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isToday
                ? orthaAccent.withValues(alpha: 0.48)
                : orthaBorder.withValues(alpha: 0.88),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.055),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              isToday ? 'Heute' : _shortWeekday(day.date),
              maxLines: 1,
              style: const TextStyle(
                color: orthaPrimaryText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _dayAndMonth(day.date),
              maxLines: 1,
              style: const TextStyle(
                color: orthaSecondaryText,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            OrthaWeatherIcon(
              weatherCode: day.weatherCode,
              size: compact ? 43 : 49,
              semanticLabel: weatherText(day.weatherCode),
            ),
            const Spacer(),
            Text(
              formatTemperature(day.temperatureMax, unitSettings, decimals: 0),
              style: const TextStyle(
                color: Color(0xFFD84B45),
                fontSize: 23,
                height: 1,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              formatTemperature(day.temperatureMin, unitSettings, decimals: 0),
              style: const TextStyle(
                color: Color(0xFF327CC1),
                fontSize: 19,
                height: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.water_drop_outlined,
                  size: 16,
                  color: orthaSecondaryText,
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    '${day.precipitationProbability} %',
                    maxLines: 1,
                    overflow: TextOverflow.fade,
                    softWrap: false,
                    style: const TextStyle(
                      color: orthaSecondaryText,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

bool _isToday(String value) {
  final date = DateTime.tryParse(value);

  if (date == null) {
    return false;
  }

  final now = DateTime.now();

  return date.year == now.year &&
      date.month == now.month &&
      date.day == now.day;
}

String _forecastDayLabel(String value, {required bool isToday}) {
  if (isToday) {
    return 'Heute, ${_dayAndMonth(value)}';
  }

  return '${_longWeekday(value)}, ${_dayAndMonth(value)}';
}

String _shortWeekday(String value) {
  final date = DateTime.tryParse(value);

  if (date == null) {
    return shortDate(value);
  }

  const weekdays = <String>['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];

  return weekdays[date.weekday - 1];
}

String _longWeekday(String value) {
  final date = DateTime.tryParse(value);

  if (date == null) {
    return shortDate(value);
  }

  const weekdays = <String>[
    'Montag',
    'Dienstag',
    'Mittwoch',
    'Donnerstag',
    'Freitag',
    'Samstag',
    'Sonntag',
  ];

  return weekdays[date.weekday - 1];
}

String _dayAndMonth(String value) {
  final date = DateTime.tryParse(value);

  if (date == null) {
    return shortDate(value);
  }

  const months = <String>[
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

  return '${date.day}. ${months[date.month - 1]}';
}
