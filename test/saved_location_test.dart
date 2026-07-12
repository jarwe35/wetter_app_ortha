import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/saved_location.dart';

void main() {
  group('SavedLocation', () {
    test('serialisiert vollständig nach JSON', () {
      const location = SavedLocation(
        name: 'Duisburg',
        latitude: 51.4344,
        longitude: 6.7623,
        country: 'Deutschland',
        timezone: 'Europe/Berlin',
      );

      expect(location.toJson(), {
        'name': 'Duisburg',
        'latitude': 51.4344,
        'longitude': 6.7623,
        'country': 'Deutschland',
        'timezone': 'Europe/Berlin',
      });
    });

    test('stellt SavedLocation aus JSON wieder her', () {
      final location = SavedLocation.fromJson({
        'name': 'Santander',
        'latitude': 43.4623,
        'longitude': -3.8099,
        'country': 'Spanien',
        'timezone': 'Europe/Madrid',
      });

      expect(location.name, 'Santander');
      expect(location.latitude, 43.4623);
      expect(location.longitude, -3.8099);
      expect(location.country, 'Spanien');
      expect(location.timezone, 'Europe/Madrid');
    });

    test('unterstützt fehlende optionale Felder', () {
      final location = SavedLocation.fromJson({
        'name': 'Oslo',
        'latitude': 59.9139,
        'longitude': 10.7522,
      });

      expect(location.country, isNull);
      expect(location.timezone, isNull);

      expect(location.toJson(), {
        'name': 'Oslo',
        'latitude': 59.9139,
        'longitude': 10.7522,
      });
    });

    test('entfernt Leerzeichen vom Ortsnamen', () {
      final location = SavedLocation.fromJson({
        'name': '  Mailand  ',
        'latitude': 45.4642,
        'longitude': 9.1900,
      });

      expect(location.name, 'Mailand');
    });

    test('copyWith verändert gezielt einzelne Werte', () {
      const original = SavedLocation(
        name: 'Bali',
        latitude: -8.4095,
        longitude: 115.1889,
        country: 'Indonesien',
      );

      final changed = original.copyWith(name: 'Bali Test');

      expect(changed.name, 'Bali Test');
      expect(changed.latitude, original.latitude);
      expect(changed.longitude, original.longitude);
      expect(changed.country, original.country);
    });

    test('erkennt identische Koordinaten', () {
      const first = SavedLocation(
        name: 'Duisburg',
        latitude: 51.4344,
        longitude: 6.7623,
      );

      const second = SavedLocation(
        name: 'Duisburg Zentrum',
        latitude: 51.4344,
        longitude: 6.7623,
      );

      expect(first.hasSameCoordinatesAs(second), isTrue);
    });

    test('unterscheidet verschiedene Koordinaten', () {
      const first = SavedLocation(
        name: 'Duisburg',
        latitude: 51.4344,
        longitude: 6.7623,
      );

      const second = SavedLocation(
        name: 'Oslo',
        latitude: 59.9139,
        longitude: 10.7522,
      );

      expect(first.hasSameCoordinatesAs(second), isFalse);
    });

    test('lehnt leeren Ortsnamen ab', () {
      expect(
        () => SavedLocation.fromJson({
          'name': '   ',
          'latitude': 51.4344,
          'longitude': 6.7623,
        }),
        throwsFormatException,
      );
    });

    test('lehnt fehlende Koordinaten ab', () {
      expect(
        () => SavedLocation.fromJson({'name': 'Duisburg'}),
        throwsFormatException,
      );
    });
  });
}
