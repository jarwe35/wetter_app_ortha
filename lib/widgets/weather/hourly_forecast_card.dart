part of '../../main.dart';

class HourlyForecastCard extends StatelessWidget {
  final List<HourlyForecast> forecast;
  final UnitSettings unitSettings;

  const HourlyForecastCard({
    super.key,
    required this.forecast,
    required this.unitSettings,
  });

  @override
  Widget build(BuildContext context) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '24-Stunden-Prognose',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          LayoutBuilder(
            builder: (context, constraints) {
              final veryCompact = constraints.maxWidth < 330;
              final cardWidth = veryCompact ? 82.0 : 92.0;
              final iconSize = veryCompact ? 32.0 : 36.0;
              final cardPadding = veryCompact ? 8.0 : 10.0;

              return SizedBox(
                height: veryCompact ? 138 : 146,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecast.length,
                  separatorBuilder: (_, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final item = forecast[index];

                    return Container(
                      width: cardWidth,
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: orthaSurfaceElevated,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: orthaBorder.withValues(alpha: 0.85),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            shortTime(item.time),
                            style: const TextStyle(
                              color: orthaSecondaryText,
                              fontSize: 12,
                            ),
                          ),
                          OrthaWeatherIcon(
                            weatherCode: item.weatherCode,
                            size: iconSize,
                            semanticLabel: weatherText(item.weatherCode),
                          ),
                          Text(
                            formatTemperature(
                              item.temperature,
                              unitSettings,
                              decimals: 0,
                            ),
                            style: const TextStyle(
                              color: orthaPrimaryText,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${item.precipitationProbability} % Regen',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: orthaSecondaryText,
                              fontSize: 12,
                            ),
                          ),
                        ],
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
