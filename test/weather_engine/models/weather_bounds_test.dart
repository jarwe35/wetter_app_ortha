import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('WeatherBounds', () {
    test('erkennt Koordinate innerhalb des Bereichs', () {
      const bounds = WeatherBounds(south: 50, west: 5, north: 55, east: 10);

      expect(bounds.contains(latitude: 51.23, longitude: 6.77), isTrue);
    });

    test('weist Koordinate außerhalb des Bereichs zurück', () {
      const bounds = WeatherBounds(south: 50, west: 5, north: 55, east: 10);

      expect(bounds.contains(latitude: 48, longitude: 11), isFalse);
    });

    test('unterstützt Bereich über dem 180. Längengrad', () {
      const bounds = WeatherBounds(
        south: -10,
        west: 170,
        north: 10,
        east: -170,
      );

      expect(bounds.contains(latitude: 0, longitude: 175), isTrue);

      expect(bounds.contains(latitude: 0, longitude: -175), isTrue);
    });
  });
}
