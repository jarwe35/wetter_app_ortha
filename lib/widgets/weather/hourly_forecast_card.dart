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
          SizedBox(
            height: 146,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: forecast.length,
              separatorBuilder: (_, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final item = forecast[index];

                return Container(
                  width: 92,
                  padding: const EdgeInsets.all(10),
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
                        size: 36,
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
          ),
        ],
      ),
    );
  }
}
