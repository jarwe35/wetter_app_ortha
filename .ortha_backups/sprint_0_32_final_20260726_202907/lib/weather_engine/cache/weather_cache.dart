import 'weather_cache_entry.dart';
import 'weather_cache_key.dart';

/// Provider- und renderunabhängiger Cachevertrag.
abstract interface class WeatherCache {
  Future<WeatherCacheEntry<T>?> read<T>(WeatherCacheKey key);

  Future<void> write<T>(WeatherCacheKey key, WeatherCacheEntry<T> entry);

  Future<bool> contains(WeatherCacheKey key);

  Future<void> remove(WeatherCacheKey key);

  Future<void> clear();

  Future<void> removeExpired({DateTime? now});

  int get entryCount;
  int get totalSizeInBytes;
}
