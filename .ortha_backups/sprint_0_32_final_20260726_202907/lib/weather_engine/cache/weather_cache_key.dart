import 'package:flutter/foundation.dart';

import '../models/weather_tile.dart';

/// Allgemeiner Schlüssel eines Weather-Engine-Cacheeintrags.
sealed class WeatherCacheKey {
  const WeatherCacheKey();

  String get value;
}

/// Cache-Schlüssel für einen vollständigen Wetterframe.
@immutable
class WeatherFrameCacheKey extends WeatherCacheKey {
  const WeatherFrameCacheKey({required this.providerId, required this.frameId})
    : assert(providerId != ''),
      assert(frameId != '');

  final String providerId;
  final String frameId;

  @override
  String get value => 'frame:$providerId:$frameId';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeatherFrameCacheKey &&
            providerId == other.providerId &&
            frameId == other.frameId;
  }

  @override
  int get hashCode => Object.hash(providerId, frameId);

  @override
  String toString() => value;
}

/// Cache-Schlüssel für eine einzelne Wetterkachel.
@immutable
class WeatherTileCacheKey extends WeatherCacheKey {
  const WeatherTileCacheKey({
    required this.providerId,
    required this.frameId,
    required this.coordinate,
  }) : assert(providerId != ''),
       assert(frameId != '');

  final String providerId;
  final String frameId;
  final WeatherTileCoordinate coordinate;

  @override
  String get value {
    return 'tile:$providerId:$frameId:${coordinate.cacheKey}';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeatherTileCacheKey &&
            providerId == other.providerId &&
            frameId == other.frameId &&
            coordinate == other.coordinate;
  }

  @override
  int get hashCode => Object.hash(providerId, frameId, coordinate);

  @override
  String toString() => value;
}
