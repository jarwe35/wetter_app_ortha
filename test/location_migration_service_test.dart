import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wetter_app_ortha/models/saved_location.dart';
import 'package:wetter_app_ortha/services/location_migration_service.dart';
import 'package:wetter_app_ortha/services/location_service.dart';
import 'package:wetter_app_ortha/services/location_storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LocationStorageService storageService;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storageService = LocationStorageService();
  });

  group('LocationMigrationService', () {
    test('migriert mehrere alte Ortsnamen vollständig', () async {
      await storageService.saveLocations(['Duisburg', 'Oslo']);

      final client = MockClient((request) async {
        final name = request.url.queryParameters['name'];

        if (name == 'Duisburg') {
          return Response('''
{
  "results": [
    {
      "name": "Duisburg",
      "latitude": 51.4344,
      "longitude": 6.7623,
      "country": "Deutschland",
      "timezone": "Europe/Berlin"
    }
  ]
}
''', 200);
        }

        return Response('''
{
  "results": [
    {
      "name": "Oslo",
      "latitude": 59.9139,
      "longitude": 10.7522,
      "country": "Norwegen",
      "timezone": "Europe/Oslo"
    }
  ]
}
''', 200);
      });

      final migrationService = LocationMigrationService(
        storageService: storageService,
        locationService: LocationService(httpClient: client),
      );

      final result = await migrationService.migrateLegacyLocations();

      expect(result.isComplete, isTrue);
      expect(result.unresolvedLocationNames, isEmpty);
      expect(result.locations, hasLength(2));
      expect(result.locations.map((location) => location.name), [
        'Duisburg',
        'Oslo',
      ]);

      final storedLocations = await storageService.loadSavedLocations();
      expect(storedLocations, result.locations);
    });

    test('übernimmt den bisher ausgewählten Ort', () async {
      await storageService.saveLocations(['Duisburg', 'Oslo']);
      await storageService.saveSelectedLocation('Oslo');

      final client = MockClient((request) async {
        final name = request.url.queryParameters['name'];

        if (name == 'Duisburg') {
          return Response('''
{
  "results": [
    {
      "name": "Duisburg",
      "latitude": 51.4344,
      "longitude": 6.7623
    }
  ]
}
''', 200);
        }

        return Response('''
{
  "results": [
    {
      "name": "Oslo",
      "latitude": 59.9139,
      "longitude": 10.7522
    }
  ]
}
''', 200);
      });

      final migrationService = LocationMigrationService(
        storageService: storageService,
        locationService: LocationService(httpClient: client),
      );

      await migrationService.migrateLegacyLocations();

      expect(await storageService.loadSelectedSavedLocationName(), 'Oslo');
    });

    test('behält bereits strukturierte Orte bei', () async {
      const existingLocation = SavedLocation(
        name: 'Santander',
        latitude: 43.4623,
        longitude: -3.8099,
        country: 'Spanien',
        timezone: 'Europe/Madrid',
      );

      await storageService.saveSavedLocations([existingLocation]);
      await storageService.saveLocations(['Duisburg']);

      final client = MockClient((request) async {
        return Response('''
{
  "results": [
    {
      "name": "Duisburg",
      "latitude": 51.4344,
      "longitude": 6.7623
    }
  ]
}
''', 200);
      });

      final migrationService = LocationMigrationService(
        storageService: storageService,
        locationService: LocationService(httpClient: client),
      );

      final result = await migrationService.migrateLegacyLocations();

      expect(result.locations, hasLength(2));
      expect(result.locations.first, existingLocation);
      expect(result.locations.last.name, 'Duisburg');
    });

    test(
      'migriert erfolgreiche Orte trotz Ausfall eines anderen Ortes',
      () async {
        await storageService.saveLocations(['Duisburg', 'Bali']);

        final client = MockClient((request) async {
          final name = request.url.queryParameters['name'];

          if (name == 'Duisburg') {
            return Response('''
{
  "results": [
    {
      "name": "Duisburg",
      "latitude": 51.4344,
      "longitude": 6.7623
    }
  ]
}
''', 200);
          }

          return Response('Serverfehler', 503);
        });

        final migrationService = LocationMigrationService(
          storageService: storageService,
          locationService: LocationService(httpClient: client),
        );

        final result = await migrationService.migrateLegacyLocations();

        expect(result.isComplete, isFalse);
        expect(result.locations, hasLength(1));
        expect(result.locations.single.name, 'Duisburg');
        expect(result.unresolvedLocationNames, ['Bali']);

        final storedLocations = await storageService.loadSavedLocations();
        expect(storedLocations, hasLength(1));
        expect(storedLocations.single.name, 'Duisburg');
      },
    );

    test(
      'holt zuvor fehlgeschlagenen Ort beim nächsten Versuch nach',
      () async {
        await storageService.saveLocations(['Duisburg', 'Bali']);

        var baliShouldFail = true;

        final client = MockClient((request) async {
          final name = request.url.queryParameters['name'];

          if (name == 'Duisburg') {
            return Response('''
{
  "results": [
    {
      "name": "Duisburg",
      "latitude": 51.4344,
      "longitude": 6.7623
    }
  ]
}
''', 200);
          }

          if (baliShouldFail) {
            return Response('Serverfehler', 503);
          }

          return Response('''
{
  "results": [
    {
      "name": "Bali",
      "latitude": -8.4095,
      "longitude": 115.1889,
      "country": "Indonesien",
      "timezone": "Asia/Makassar"
    }
  ]
}
''', 200);
        });

        final migrationService = LocationMigrationService(
          storageService: storageService,
          locationService: LocationService(httpClient: client),
        );

        final firstResult = await migrationService.migrateLegacyLocations();

        expect(firstResult.locations, hasLength(1));
        expect(firstResult.unresolvedLocationNames, ['Bali']);

        baliShouldFail = false;

        final secondResult = await migrationService.migrateLegacyLocations();

        expect(secondResult.isComplete, isTrue);
        expect(secondResult.locations, hasLength(2));
        expect(secondResult.locations.map((location) => location.name), [
          'Duisburg',
          'Bali',
        ]);
      },
    );

    test(
      'ordnet Legacy-Namen bei gleichen Koordinaten einem strukturierten Ort zu',
      () async {
        const existingLocation = SavedLocation(
          name: 'Denpasar',
          latitude: -8.4095,
          longitude: 115.1889,
          country: 'Indonesien',
          timezone: 'Asia/Makassar',
        );

        await storageService.saveSavedLocations([existingLocation]);
        await storageService.saveLocations(['Bali']);

        final client = MockClient((request) async {
          expect(request.url.queryParameters['name'], 'Bali');

          return Response('''
{
  "results": [
    {
      "name": "Bali",
      "latitude": -8.4095,
      "longitude": 115.1889,
      "country": "Indonesien",
      "timezone": "Asia/Makassar"
    }
  ]
}
''', 200);
        });

        final migrationService = LocationMigrationService(
          storageService: storageService,
          locationService: LocationService(httpClient: client),
        );

        final result = await migrationService.migrateLegacyLocations();

        expect(result.isComplete, isTrue);

        final migratedLegacyLocation = result.locations
            .cast<SavedLocation?>()
            .firstWhere(
              (location) => location?.name.toLowerCase() == 'bali',
              orElse: () => null,
            );

        expect(migratedLegacyLocation, isNotNull);
      },
    );

    test('erzeugt keine Dublette für bereits migrierten Ort', () async {
      const existingLocation = SavedLocation(
        name: 'Duisburg',
        latitude: 51.4344,
        longitude: 6.7623,
      );

      await storageService.saveSavedLocations([existingLocation]);
      await storageService.saveLocations(['Duisburg', 'DUISBURG']);

      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount += 1;

        return Response('''
{
  "results": [
    {
      "name": "Duisburg",
      "latitude": 51.4344,
      "longitude": 6.7623
    }
  ]
}
''', 200);
      });

      final migrationService = LocationMigrationService(
        storageService: storageService,
        locationService: LocationService(httpClient: client),
      );

      final result = await migrationService.migrateLegacyLocations();

      expect(result.locations, [existingLocation]);
      expect(requestCount, 0);
    });
  });
}
