import 'package:flutter/material.dart';

import 'unit_settings.dart';

class UnitSettingsPage extends StatefulWidget {
  final UnitSettings initialSettings;

  const UnitSettingsPage({super.key, required this.initialSettings});

  @override
  State<UnitSettingsPage> createState() => _UnitSettingsPageState();
}

class _UnitSettingsPageState extends State<UnitSettingsPage> {
  late UnitSettings settings;

  @override
  void initState() {
    super.initState();
    settings = widget.initialSettings;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einheiten')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<TemperatureUnit>(
            initialValue: settings.temperatureUnit,
            decoration: const InputDecoration(
              labelText: 'Temperatur',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: TemperatureUnit.celsius,
                child: Text('Celsius (°C)'),
              ),
              DropdownMenuItem(
                value: TemperatureUnit.fahrenheit,
                child: Text('Fahrenheit (°F)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                settings = settings.copyWith(temperatureUnit: value);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<WindSpeedUnit>(
            initialValue: settings.windSpeedUnit,
            decoration: const InputDecoration(
              labelText: 'Windgeschwindigkeit',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: WindSpeedUnit.kilometersPerHour,
                child: Text('Kilometer pro Stunde (km/h)'),
              ),
              DropdownMenuItem(
                value: WindSpeedUnit.knots,
                child: Text('Knoten (kn)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                settings = settings.copyWith(windSpeedUnit: value);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<VisibilityUnit>(
            initialValue: settings.visibilityUnit,
            decoration: const InputDecoration(
              labelText: 'Sichtweite',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: VisibilityUnit.kilometers,
                child: Text('Kilometer (km)'),
              ),
              DropdownMenuItem(
                value: VisibilityUnit.miles,
                child: Text('Meilen (mi)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                settings = settings.copyWith(visibilityUnit: value);
              });
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<PrecipitationUnit>(
            initialValue: settings.precipitationUnit,
            decoration: const InputDecoration(
              labelText: 'Niederschlag',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: PrecipitationUnit.millimeters,
                child: Text('Millimeter (mm)'),
              ),
              DropdownMenuItem(
                value: PrecipitationUnit.inches,
                child: Text('Inch (in)'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                settings = settings.copyWith(precipitationUnit: value);
              });
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context, settings);
            },
            icon: const Icon(Icons.save_outlined),
            label: const Text('Einheiten speichern'),
          ),
        ],
      ),
    );
  }
}
