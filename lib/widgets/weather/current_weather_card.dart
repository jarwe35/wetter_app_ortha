part of '../../main.dart';

class WeatherCard extends StatelessWidget {
  final WeatherData data;
  final UnitSettings unitSettings;

  const WeatherCard({
    super.key,
    required this.data,
    required this.unitSettings,
  });

  @override
  Widget build(BuildContext context) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: orthaAccent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.place,
                  style: const TextStyle(
                    color: orthaPrimaryText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                shortTime(data.observationTime),
                style: const TextStyle(color: orthaSecondaryText, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              OrthaWeatherIcon(
                weatherCode: data.weatherCode,
                size: 92,
                semanticLabel: weatherText(data.weatherCode),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTemperature(
                        data.temperature,
                        unitSettings,
                        decimals: 1,
                      ),
                      style: const TextStyle(
                        color: orthaPrimaryText,
                        fontSize: 54,
                        height: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      weatherText(data.weatherCode),
                      style: const TextStyle(
                        color: orthaSecondaryText,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: orthaSurfaceElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: orthaBorder.withValues(alpha: 0.72)),
            ),
            child: Wrap(
              spacing: 18,
              runSpacing: 10,
              children: [
                _WeatherMetaItem(
                  icon: Icons.device_thermostat_outlined,
                  label:
                      'Gefühlt ${formatTemperature(data.apparentTemperature, unitSettings, decimals: 1)}',
                ),
                _WeatherMetaItem(
                  icon: Icons.water_drop_outlined,
                  label: 'Luftfeuchtigkeit ${data.humidity} %',
                ),
                _WeatherMetaItem(
                  icon: Icons.air,
                  label:
                      'Wind ${formatWindSpeed(data.windSpeed, unitSettings)}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherMetaItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _WeatherMetaItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: orthaSecondaryText),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(color: orthaSecondaryText, fontSize: 13),
        ),
      ],
    );
  }
}
