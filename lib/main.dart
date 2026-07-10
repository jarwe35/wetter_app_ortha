import 'package:flutter/material.dart';

import 'engine/risk_engine.dart';
import 'pages/locations_page.dart';
import 'services/location_storage_service.dart';
import 'services/weather_service.dart';
import 'settings/unit_settings.dart';
import 'settings/unit_settings_page.dart';
import 'settings/unit_settings_service.dart';

void main() {
  runApp(const OrthaWeatherApp());
}

class OrthaWeatherApp extends StatelessWidget {
  const OrthaWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ORTHA Wetter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEAF4F8),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7FB3C8)),
        useMaterial3: true,
      ),
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({super.key});

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final WeatherService weatherService = WeatherService();
  final LocationStorageService locationStorageService =
      LocationStorageService();
  final RiskEngine riskEngine = const RiskEngine();
  final UnitSettingsService unitSettingsService = UnitSettingsService();

  UnitSettings unitSettings = const UnitSettings();

  final List<String> places = [];

  String selectedPlace = 'Duisburg';
  WeatherData? weatherData;
  RiskResult? riskResult;

  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initializeUnitSettings();
    initializeLocations();
  }

  Future<void> initializeUnitSettings() async {
    final storedSettings = await unitSettingsService.load();

    if (!mounted) return;

    setState(() {
      unitSettings = storedSettings;
    });
  }

  Future<void> openUnitSettings() async {
    final updatedSettings = await Navigator.push<UnitSettings>(
      context,
      MaterialPageRoute(
        builder: (_) => UnitSettingsPage(initialSettings: unitSettings),
      ),
    );

    if (updatedSettings == null || !mounted) return;

    setState(() {
      unitSettings = updatedSettings;
    });

    await unitSettingsService.save(updatedSettings);
  }

  Future<void> initializeLocations() async {
    final storedPlaces = await locationStorageService.loadLocations();
    final storedSelectedPlace = await locationStorageService
        .loadSelectedLocation();

    if (!mounted) return;

    final initialPlace = storedPlaces.contains(storedSelectedPlace)
        ? storedSelectedPlace
        : storedPlaces.first;

    setState(() {
      places
        ..clear()
        ..addAll(storedPlaces);
      selectedPlace = initialPlace;
    });

    await loadWeather(initialPlace);
  }

  Future<void> loadWeather(String place) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await weatherService.fetchWeather(place);
      final risk = riskEngine.evaluate(data);

      if (!mounted) return;

      setState(() {
        weatherData = data;
        riskResult = risk;
        selectedPlace = data.place;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        errorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void addPlace() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ort hinzufügen'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Ort',
              hintText: 'z. B. Düsseldorf, Dinard, Berlin',
            ),
            onSubmitted: (_) {
              addPlaceFromDialog(controller, dialogContext);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Abbrechen'),
            ),
            FilledButton(
              onPressed: () {
                addPlaceFromDialog(controller, dialogContext);
              },
              child: const Text('Hinzufügen'),
            ),
          ],
        );
      },
    );
  }

  Future<void> addPlaceFromDialog(
    TextEditingController controller,
    BuildContext dialogContext,
  ) async {
    final value = controller.text.trim();

    if (value.isEmpty) return;

    if (!places.contains(value)) {
      setState(() {
        places.add(value);
      });
      await locationStorageService.saveLocations(places);
    }

    await locationStorageService.saveSelectedLocation(value);

    if (dialogContext.mounted) {
      Navigator.pop(dialogContext);
    }

    await loadWeather(value);
  }

  Future<void> deletePlace(String place) async {
    if (places.length == 1) return;

    setState(() {
      places.remove(place);

      if (selectedPlace == place) {
        selectedPlace = places.first;
      }
    });

    await locationStorageService.saveLocations(places);
    await locationStorageService.saveSelectedLocation(selectedPlace);
    await loadWeather(selectedPlace);
  }

  @override
  Widget build(BuildContext context) {
    final data = weatherData;
    final risk = riskResult;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'ORTHA Wetter',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF143642),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Einheiten',
                    onPressed: openUnitSettings,
                    icon: const Icon(Icons.straighten_outlined),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Wetter- und Risikoanalyse für Alltag, Arbeit und Reisen',
                style: TextStyle(fontSize: 15, color: Color(0xFF4F6F7A)),
              ),
              const SizedBox(height: 22),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LocationsPage(
                          places: places,
                          selectedPlace: selectedPlace,
                          onSelect: (place) async {
                            setState(() {
                              selectedPlace = place;
                            });

                            await locationStorageService.saveSelectedLocation(
                              place,
                            );
                            await loadWeather(place);
                          },
                          onDelete: (place) {
                            deletePlace(place);
                          },
                          onReorder: (newPlaces) async {
                            setState(() {
                              places
                                ..clear()
                                ..addAll(newPlaces);
                            });

                            await locationStorageService.saveLocations(places);
                          },
                          onRename: (oldPlace, newPlace) async {
                            final cleanedName = newPlace.trim();

                            if (cleanedName.isEmpty ||
                                cleanedName == oldPlace ||
                                places.contains(cleanedName)) {
                              return;
                            }

                            final placeIndex = places.indexOf(oldPlace);

                            if (placeIndex < 0) {
                              return;
                            }

                            setState(() {
                              places[placeIndex] = cleanedName;

                              if (selectedPlace == oldPlace) {
                                selectedPlace = cleanedName;
                              }
                            });

                            await locationStorageService.saveLocations(places);
                            await locationStorageService.saveSelectedLocation(
                              selectedPlace,
                            );

                            if (selectedPlace == cleanedName) {
                              await loadWeather(cleanedName);
                            }
                          },
                        ),
                      ),
                    );

                    if (mounted) {
                      setState(() {});
                    }
                  },
                  icon: const Icon(Icons.location_city_outlined),
                  label: const Text('Meine Orte'),
                ),
              ),
              const SizedBox(height: 12),
              PlaceSelector(
                places: places,
                selectedPlace: selectedPlace,
                onSelect: (place) async {
                  setState(() {
                    selectedPlace = place;
                  });

                  await locationStorageService.saveSelectedLocation(place);
                  await loadWeather(place);
                },
                onDelete: deletePlace,
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    if (isLoading)
                      const CardBox(child: Text('Wetterdaten werden geladen …'))
                    else if (errorMessage != null)
                      CardBox(child: Text(errorMessage!))
                    else if (data != null && risk != null) ...[
                      WeatherCard(data: data, unitSettings: unitSettings),
                      const SizedBox(height: 18),
                      RiskCard(result: risk),
                      const SizedBox(height: 18),
                      WarningLevelBar(result: risk),
                      const SizedBox(height: 18),
                      RiskCategoriesCard(categories: risk.categories),
                      const SizedBox(height: 18),
                      HourlyForecastCard(
                        forecast: data.hourlyForecast,
                        unitSettings: unitSettings,
                      ),
                      const SizedBox(height: 18),
                      DailyForecastCard(
                        forecast: data.dailyForecast,
                        unitSettings: unitSettings,
                      ),
                      const SizedBox(height: 18),
                      WeatherDetailsCard(
                        data: data,
                        unitSettings: unitSettings,
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton.icon(
                  onPressed: addPlace,
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Ort hinzufügen'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceSelector extends StatelessWidget {
  final List<String> places;
  final String selectedPlace;
  final ValueChanged<String> onSelect;
  final ValueChanged<String> onDelete;

  const PlaceSelector({
    super.key,
    required this.places,
    required this.selectedPlace,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: places.length,
        separatorBuilder: (_, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final place = places[index];
          final selected = place == selectedPlace;

          return InputChip(
            label: Text(place),
            selected: selected,
            onPressed: () => onSelect(place),
            onDeleted: places.length > 1 ? () => onDelete(place) : null,
          );
        },
      ),
    );
  }
}

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
          Text(
            data.place,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            formatTemperature(data.temperature, unitSettings, decimals: 1),
            style: const TextStyle(fontSize: 54, fontWeight: FontWeight.bold),
          ),
          Text(
            'Gefühlt ${formatTemperature(data.apparentTemperature, unitSettings, decimals: 1)}'
            ' · Luftfeuchtigkeit ${data.humidity} %',
          ),
        ],
      ),
    );
  }
}

class RiskCard extends StatelessWidget {
  final RiskResult result;

  const RiskCard({super.key, required this.result});

  Color riskColor() {
    switch (result.level) {
      case RiskLevel.green:
        return const Color(0xFF4F8A70);
      case RiskLevel.yellow:
        return const Color(0xFFD1A928);
      case RiskLevel.orange:
        return const Color(0xFFD77B2E);
      case RiskLevel.red:
        return const Color(0xFFB94A48);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = riskColor();

    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ORTHA Risikoanalyse',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  result.title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Risikoscore ${result.score} / 100',
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: result.score / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(8),
            color: color,
            backgroundColor: color.withValues(alpha: 0.16),
          ),
          const SizedBox(height: 16),
          Text(result.message),
          if (result.factors.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Erkannte Risikofaktoren',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...result.factors.map(
              (factor) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• '),
                    Expanded(child: Text(factor)),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

double temperatureForDisplay(double celsius, UnitSettings settings) {
  if (settings.temperatureUnit == TemperatureUnit.fahrenheit) {
    return (celsius * 9 / 5) + 32;
  }
  return celsius;
}

String temperatureUnitText(UnitSettings settings) {
  return settings.temperatureUnit == TemperatureUnit.fahrenheit ? '°F' : '°C';
}

String formatTemperature(
  double celsius,
  UnitSettings settings, {
  int decimals = 1,
}) {
  final value = temperatureForDisplay(celsius, settings);
  return '${value.toStringAsFixed(decimals)} ${temperatureUnitText(settings)}';
}

String formatWindSpeed(
  double kilometersPerHour,
  UnitSettings settings, {
  int decimals = 1,
}) {
  if (settings.windSpeedUnit == WindSpeedUnit.knots) {
    final knots = kilometersPerHour / 1.852;
    return '${knots.toStringAsFixed(decimals)} kn';
  }

  return '${kilometersPerHour.toStringAsFixed(decimals)} km/h';
}

String formatVisibility(double meters, UnitSettings settings) {
  if (settings.visibilityUnit == VisibilityUnit.miles) {
    final miles = meters / 1609.344;
    return '${miles.toStringAsFixed(1)} mi';
  }

  final kilometers = meters / 1000;
  return '${kilometers.toStringAsFixed(1)} km';
}

String formatPrecipitation(double millimeters, UnitSettings settings) {
  if (settings.precipitationUnit == PrecipitationUnit.inches) {
    final inches = millimeters / 25.4;
    return '${inches.toStringAsFixed(2)} in';
  }

  return '${millimeters.toStringAsFixed(1)} mm';
}

String weatherText(int code) {
  if (code == 0) return 'Klar';
  if ([1, 2, 3].contains(code)) return 'Bewölkt';
  if ([45, 48].contains(code)) return 'Nebel';
  if ([51, 53, 55, 56, 57].contains(code)) return 'Niesel';
  if ([61, 63, 65, 66, 67, 80, 81, 82].contains(code)) return 'Regen';
  if ([71, 73, 75, 77, 85, 86].contains(code)) return 'Schnee';
  if ([95, 96, 99].contains(code)) return 'Gewitter';
  return 'Wetter';
}

IconData weatherIcon(int code) {
  if (code == 0) return Icons.wb_sunny_outlined;
  if ([1, 2, 3].contains(code)) return Icons.cloud_outlined;
  if ([45, 48].contains(code)) return Icons.foggy;
  if ([51, 53, 55, 56, 57, 61, 63, 65, 66, 67, 80, 81, 82].contains(code)) {
    return Icons.water_drop_outlined;
  }
  if ([71, 73, 75, 77, 85, 86].contains(code)) return Icons.ac_unit;
  if ([95, 96, 99].contains(code)) return Icons.thunderstorm_outlined;
  return Icons.device_thermostat;
}

String shortTime(String value) {
  final parts = value.split('T');
  if (parts.length != 2) return value;
  return parts[1].substring(0, 5);
}

String shortDate(String value) {
  final parts = value.split('-');
  if (parts.length != 3) return value;
  return '${parts[2]}.${parts[1]}.';
}

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
                    color: const Color(0xFFEAF4F8),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(shortTime(item.time)),
                      Icon(weatherIcon(item.weatherCode)),
                      Text(
                        formatTemperature(
                          item.temperature,
                          unitSettings,
                          decimals: 0,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${item.precipitationProbability} % Regen'),
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

class DailyForecastCard extends StatelessWidget {
  final List<DailyForecast> forecast;
  final UnitSettings unitSettings;

  const DailyForecastCard({
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
            '7-Tage-Vorhersage',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...forecast.map(
            (day) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(width: 54, child: Text(shortDate(day.date))),
                  Icon(weatherIcon(day.weatherCode)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(weatherText(day.weatherCode))),
                  Text(
                    '${formatTemperature(day.temperatureMin, unitSettings, decimals: 0)}'
                    ' / '
                    '${formatTemperature(day.temperatureMax, unitSettings, decimals: 0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Text('${day.precipitationProbability} %'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BulletText extends StatelessWidget {
  final String text;

  const BulletText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• '),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class WeatherDetailsCard extends StatelessWidget {
  final WeatherData data;
  final UnitSettings unitSettings;

  const WeatherDetailsCard({
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
          const Text(
            'Messwerte',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          DetailRow(
            label: 'Niederschlag',
            value: formatPrecipitation(data.precipitation, unitSettings),
          ),
          DetailRow(
            label: 'Wind',
            value: formatWindSpeed(data.windSpeed, unitSettings),
          ),
          DetailRow(
            label: 'Böen',
            value: formatWindSpeed(data.windGusts, unitSettings),
          ),
          DetailRow(
            label: 'Luftdruck',
            value: '${data.pressure.toStringAsFixed(0)} hPa',
          ),
          DetailRow(label: 'Bewölkung', value: '${data.cloudCover} %'),
          DetailRow(
            label: 'Sichtweite',
            value: formatVisibility(data.visibility, unitSettings),
          ),
          DetailRow(label: 'UV-Index', value: data.uvIndex.toStringAsFixed(1)),
        ],
      ),
    );
  }
}

class DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const DetailRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF4F6F7A))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class CardBox extends StatelessWidget {
  final Widget child;

  const CardBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
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

class WarningLevelBar extends StatelessWidget {
  final RiskResult result;

  const WarningLevelBar({super.key, required this.result});

  int get activeLevel {
    switch (result.level) {
      case RiskLevel.green:
        return 0;
      case RiskLevel.yellow:
        return 1;
      case RiskLevel.orange:
        return 2;
      case RiskLevel.red:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    const levels = [
      ('Grün', Color(0xFF4F8A70)),
      ('Gelb', Color(0xFFD1A928)),
      ('Orange', Color(0xFFD77B2E)),
      ('Rot', Color(0xFFB94A48)),
    ];

    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aktuelle Warnstufe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(levels.length, (index) {
              final level = levels[index];
              final isActive = index == activeLevel;

              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                    right: index < levels.length - 1 ? 6 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? level.$2
                        : level.$2.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: level.$2,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    level.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: isActive
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isActive ? Colors.white : level.$2,
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 14),
          Text(
            'Risikoscore ${result.score} von 100 · ${result.title}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class RiskCategoriesCard extends StatelessWidget {
  final List<RiskCategoryResult> categories;

  const RiskCategoriesCard({super.key, required this.categories});

  Color colorForLevel(RiskLevel level) {
    switch (level) {
      case RiskLevel.green:
        return const Color(0xFF4F8A70);
      case RiskLevel.yellow:
        return const Color(0xFFD1A928);
      case RiskLevel.orange:
        return const Color(0xFFD77B2E);
      case RiskLevel.red:
        return const Color(0xFFB94A48);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CardBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Risikokategorien',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          ...categories.map((category) {
            final color = colorForLevel(category.level);

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      title: Text(category.name),
                      content: Text(
                        'Warnstufe: ${riskLevelText(category.level)}\n\n'
                        'Aktuell: ${category.displayValue}\n'
                        'Prognose: ${category.forecastDisplayValue}\n\n'
                        'Begründung: ${category.message}\n\n'
                        'Empfehlung: ${recommendationForCategory(category)}',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text('Schließen'),
                        ),
                      ],
                    );
                  },
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 92,
                      child: Text(
                        category.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: category.score / 100,
                        minHeight: 7,
                        borderRadius: BorderRadius.circular(8),
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.14),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 34,
                      child: Text(
                        '${category.score}',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

String riskLevelText(RiskLevel level) {
  switch (level) {
    case RiskLevel.green:
      return 'Grün · geringe Belastung';
    case RiskLevel.yellow:
      return 'Gelb · erhöhte Aufmerksamkeit';
    case RiskLevel.orange:
      return 'Orange · erhöhte Belastung';
    case RiskLevel.red:
      return 'Rot · hohe Belastung';
  }
}

String recommendationForCategory(RiskCategoryResult category) {
  if (category.level == RiskLevel.green) {
    return 'Keine besonderen wetterbedingten Maßnahmen erforderlich.';
  }

  switch (category.name) {
    case 'Hitze':
      return 'Körperliche Belastung reduzieren, ausreichend trinken, Schatten aufsuchen und besonders belastende Aktivitäten anpassen.';

    case 'UV':
      return 'Direkte Sonne möglichst begrenzen, geeigneten Sonnenschutz verwenden und längere Aufenthalte im Freien anpassen.';

    case 'Wind/Sturm':
      return 'Lose Gegenstände sichern, exponierte Bereiche meiden und Wege sowie Aktivitäten an die Windlage anpassen.';

    case 'Niederschlag':
      return 'Rutschige Wege, mögliche Sichtbehinderungen und lokale Wasseransammlungen berücksichtigen.';

    case 'Sicht':
      return 'Geschwindigkeit und Wege anpassen, zusätzliche Zeit einplanen und im Straßenverkehr besonders aufmerksam sein.';

    case 'Gewitter':
      return 'Aufenthalte im Freien und exponierte Bereiche vermeiden, sichere Gebäude aufsuchen und die weitere Wetterentwicklung beobachten.';

    default:
      return 'Die Wetterentwicklung weiter beobachten und Aktivitäten bei Bedarf anpassen.';
  }
}
