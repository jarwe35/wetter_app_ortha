import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetter_app_ortha/models/saved_location.dart';
import 'package:wetter_app_ortha/services/location_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocationStorageService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = LocationStorageService();
  });

  group('LocationStorageService strukturierte Orte', () {
    test('liefert ohne gespeicherte Daten eine leere Liste', () async {
      final locations = await service.loadSavedLocations();

      expect(locations, isEmpty);
    });

    test('speichert und lädt SavedLocation vollständig', () async {
      const location = SavedLocation(
        name: 'Duisburg',
        latitude: 51.4344,
        longitude: 6.7623,
        country: 'Deutschland',
        timezone: 'Europe/Berlin',
      );

      await service.saveSavedLocations([location]);

      final loaded = await service.loadSavedLocations();

      expect(loaded, hasLength(1));
      expect(loaded.single, location);
    });

    test('behält die Reihenfolge gespeicherter Orte bei', () async {
      const locations = [
        SavedLocation(name: 'Duisburg', latitude: 51.4344, longitude: 6.7623),
        SavedLocation(name: 'Oslo', latitude: 59.9139, longitude: 10.7522),
      ];

      await service.saveSavedLocations(locations);

      final loaded = await service.loadSavedLocations();

      expect(loaded, locations);
    });

    test('entfernt doppelte Ortsnamen unabhängig von Großschreibung', () async {
      const locations = [
        SavedLocation(name: 'Duisburg', latitude: 51.4344, longitude: 6.7623),
        SavedLocation(name: 'DUISBURG', latitude: 52.0, longitude: 7.0),
      ];

      await service.saveSavedLocations(locations);

      final loaded = await service.loadSavedLocations();

      expect(loaded, hasLength(1));
      expect(loaded.single.name, 'Duisburg');
    });

    test('entfernt Orte mit identischen Koordinaten', () async {
      const locations = [
        SavedLocation(name: 'Duisburg', latitude: 51.4344, longitude: 6.7623),
        SavedLocation(
          name: 'Duisburg Zentrum',
          latitude: 51.4344,
          longitude: 6.7623,
        ),
      ];

      await service.saveSavedLocations(locations);

      final loaded = await service.loadSavedLocations();

      expect(loaded, hasLength(1));
      expect(loaded.single.name, 'Duisburg');
    });

    test('überspringt beschädigte strukturierte Datensätze', () async {
      SharedPreferences.setMockInitialValues({
        'ortha_saved_locations_structured_v1': [
          jsonEncode({
            'name': 'Oslo',
            'latitude': 59.9139,
            'longitude': 10.7522,
          }),
          'kein gültiges JSON',
          jsonEncode({'name': 'Ohne Koordinaten'}),
        ],
      });

      final loaded = await service.loadSavedLocations();

      expect(loaded, hasLength(1));
      expect(loaded.single.name, 'Oslo');
    });

    test('speichert und lädt Namen des ausgewählten Ortes', () async {
      expect(await service.loadSelectedSavedLocationName(), isNull);

      await service.saveSelectedSavedLocationName('Santander');

      expect(await service.loadSelectedSavedLocationName(), 'Santander');
    });

    test('ignoriert leeren Namen bei Auswahl', () async {
      await service.saveSelectedSavedLocationName('Duisburg');
      await service.saveSelectedSavedLocationName('   ');

      expect(await service.loadSelectedSavedLocationName(), 'Duisburg');
    });

    test('löscht strukturierte Ortsdaten vollständig', () async {
      const location = SavedLocation(
        name: 'Bali',
        latitude: -8.4095,
        longitude: 115.1889,
      );

      await service.saveSavedLocations([location]);
      await service.saveSelectedSavedLocationName('Bali');

      await service.clearStructuredLocations();

      expect(await service.loadSavedLocations(), isEmpty);
      expect(await service.loadSelectedSavedLocationName(), isNull);
    });

    test('alte Ortsnamen-Speicherung funktioniert weiterhin', () async {
      await service.saveLocations(['Duisburg', 'Oslo']);
      await service.saveSelectedLocation('Oslo');

      expect(await service.loadLocations(), ['Duisburg', 'Oslo']);
      expect(await service.loadSelectedLocation(), 'Oslo');
    });
  });
}
