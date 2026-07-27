import 'weather_cache.dart';
import 'weather_cache_entry.dart';
import 'weather_cache_key.dart';

/// Flüchtiger In-Memory-Cache für Wetterdaten.
///
/// Später kann dieser Vertrag zusätzlich durch Datei-, Datenbank- oder
/// plattformspezifische Caches implementiert werden.
class MemoryWeatherCache implements WeatherCache {
  MemoryWeatherCache({
    this.maximumEntryCount = 512,
    this.maximumSizeInBytes = 64 * 1024 * 1024,
  }) : assert(maximumEntryCount > 0),
       assert(maximumSizeInBytes > 0);

  final int maximumEntryCount;
  final int maximumSizeInBytes;

  final Map<String, WeatherCacheEntry<Object?>> _entries =
      <String, WeatherCacheEntry<Object?>>{};

  @override
  int get entryCount => _entries.length;

  @override
  int get totalSizeInBytes {
    return _entries.values.fold<int>(
      0,
      (sum, entry) => sum + entry.sizeInBytes,
    );
  }

  @override
  Future<WeatherCacheEntry<T>?> read<T>(WeatherCacheKey key) async {
    final entry = _entries[key.value];

    if (entry == null) {
      return null;
    }

    if (entry.isExpiredAt(DateTime.now().toUtc())) {
      _entries.remove(key.value);
      return null;
    }

    final value = entry.value;

    if (value is! T) {
      return null;
    }

    return WeatherCacheEntry<T>(
      value: value,
      createdAt: entry.createdAt,
      expiresAt: entry.expiresAt,
      sizeInBytes: entry.sizeInBytes,
    );
  }

  @override
  Future<void> write<T>(WeatherCacheKey key, WeatherCacheEntry<T> entry) async {
    _entries.remove(key.value);

    _entries[key.value] = WeatherCacheEntry<Object?>(
      value: entry.value,
      createdAt: entry.createdAt,
      expiresAt: entry.expiresAt,
      sizeInBytes: entry.sizeInBytes,
    );

    _enforceLimits();
  }

  @override
  Future<bool> contains(WeatherCacheKey key) async {
    final entry = _entries[key.value];

    if (entry == null) {
      return false;
    }

    if (entry.isExpiredAt(DateTime.now().toUtc())) {
      _entries.remove(key.value);
      return false;
    }

    return true;
  }

  @override
  Future<void> remove(WeatherCacheKey key) async {
    _entries.remove(key.value);
  }

  @override
  Future<void> clear() async {
    _entries.clear();
  }

  @override
  Future<void> removeExpired({DateTime? now}) async {
    final effectiveNow = (now ?? DateTime.now()).toUtc();

    _entries.removeWhere((_, entry) => entry.isExpiredAt(effectiveNow));
  }

  void _enforceLimits() {
    while (_entries.length > maximumEntryCount ||
        totalSizeInBytes > maximumSizeInBytes) {
      if (_entries.isEmpty) {
        return;
      }

      final oldestKey = _entries.entries.reduce((left, right) {
        if (left.value.createdAt.isBefore(right.value.createdAt)) {
          return left;
        }

        return right;
      }).key;

      _entries.remove(oldestKey);
    }
  }
}
