import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/weather_engine/weather_engine.dart';

void main() {
  group('MemoryWeatherCache', () {
    test('speichert und liest einen Eintrag', () async {
      final cache = MemoryWeatherCache();

      const key = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-1');

      final createdAt = DateTime.utc(2026, 7, 26, 10);

      await cache.write<String>(
        key,
        WeatherCacheEntry<String>(
          value: 'radar-data',
          createdAt: createdAt,
          sizeInBytes: 10,
        ),
      );

      final result = await cache.read<String>(key);

      expect(result?.value, 'radar-data');
      expect(result?.createdAt, createdAt);
      expect(cache.entryCount, 1);
      expect(cache.totalSizeInBytes, 10);
    });

    test('liefert null bei falschem erwarteten Typ', () async {
      final cache = MemoryWeatherCache();

      const key = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-1');

      await cache.write<String>(
        key,
        WeatherCacheEntry<String>(
          value: 'radar-data',
          createdAt: DateTime.utc(2026, 7, 26, 10),
        ),
      );

      final result = await cache.read<int>(key);

      expect(result, isNull);
    });

    test('entfernt abgelaufenen Eintrag beim Lesen', () async {
      final cache = MemoryWeatherCache();

      const key = WeatherFrameCacheKey(
        providerId: 'test',
        frameId: 'expired-frame',
      );

      await cache.write<String>(
        key,
        WeatherCacheEntry<String>(
          value: 'expired',
          createdAt: DateTime.utc(2026, 7, 26, 9),
          expiresAt: DateTime.utc(2026, 7, 26, 9, 30),
        ),
      );

      final result = await cache.read<String>(key);

      expect(result, isNull);
      expect(cache.entryCount, 0);
    });

    test('entfernt ältesten Eintrag bei Überschreitung der Anzahl', () async {
      final cache = MemoryWeatherCache(maximumEntryCount: 2);

      const key1 = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-1');

      const key2 = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-2');

      const key3 = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-3');

      await cache.write<String>(
        key1,
        WeatherCacheEntry<String>(
          value: 'one',
          createdAt: DateTime.utc(2026, 7, 26, 10),
        ),
      );

      await cache.write<String>(
        key2,
        WeatherCacheEntry<String>(
          value: 'two',
          createdAt: DateTime.utc(2026, 7, 26, 10, 1),
        ),
      );

      await cache.write<String>(
        key3,
        WeatherCacheEntry<String>(
          value: 'three',
          createdAt: DateTime.utc(2026, 7, 26, 10, 2),
        ),
      );

      expect(await cache.contains(key1), isFalse);
      expect(await cache.contains(key2), isTrue);
      expect(await cache.contains(key3), isTrue);
      expect(cache.entryCount, 2);
    });

    test('entfernt ältesten Eintrag bei Überschreitung der Größe', () async {
      final cache = MemoryWeatherCache(maximumSizeInBytes: 10);

      const key1 = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-1');

      const key2 = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-2');

      await cache.write<String>(
        key1,
        WeatherCacheEntry<String>(
          value: 'one',
          createdAt: DateTime.utc(2026, 7, 26, 10),
          sizeInBytes: 6,
        ),
      );

      await cache.write<String>(
        key2,
        WeatherCacheEntry<String>(
          value: 'two',
          createdAt: DateTime.utc(2026, 7, 26, 10, 1),
          sizeInBytes: 6,
        ),
      );

      expect(await cache.contains(key1), isFalse);
      expect(await cache.contains(key2), isTrue);
      expect(cache.totalSizeInBytes, 6);
    });

    test('clear leert den Cache vollständig', () async {
      final cache = MemoryWeatherCache();

      const key = WeatherFrameCacheKey(providerId: 'test', frameId: 'frame-1');

      await cache.write<String>(
        key,
        WeatherCacheEntry<String>(
          value: 'value',
          createdAt: DateTime.utc(2026, 7, 26, 10),
        ),
      );

      await cache.clear();

      expect(cache.entryCount, 0);
      expect(cache.totalSizeInBytes, 0);
    });
  });
}
