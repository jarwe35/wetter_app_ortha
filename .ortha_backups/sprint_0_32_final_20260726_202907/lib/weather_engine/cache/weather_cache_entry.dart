import 'package:flutter/foundation.dart';

/// Generischer Cacheeintrag mit Zeit- und Größeninformationen.
@immutable
class WeatherCacheEntry<T> {
  const WeatherCacheEntry({
    required this.value,
    required this.createdAt,
    this.expiresAt,
    this.sizeInBytes = 0,
  }) : assert(sizeInBytes >= 0);

  final T value;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final int sizeInBytes;

  bool isExpiredAt(DateTime time) {
    final expiry = expiresAt;

    if (expiry == null) {
      return false;
    }

    return !time.isBefore(expiry);
  }
}
