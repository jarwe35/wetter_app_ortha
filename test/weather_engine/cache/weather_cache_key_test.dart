import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('WeatherCacheKey', () {
    test('erzeugt stabilen Frame-Schlüssel', () {
      const key = WeatherFrameCacheKey(
        providerId: 'dwd',
        frameId: 'radar-20260726-1000',
      );

      expect(key.value, 'frame:dwd:radar-20260726-1000');
    });

    test('erzeugt stabilen Tile-Schlüssel', () {
      const key = WeatherTileCacheKey(
        providerId: 'dwd',
        frameId: 'radar-1',
        coordinate: WeatherTileCoordinate(zoom: 8, x: 132, y: 84),
      );

      expect(key.value, 'tile:dwd:radar-1:8/132/84');
    });
  });
}
