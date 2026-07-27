import 'package:flutter/foundation.dart';

/// Eindeutige XYZ-Koordinate einer Kartenkachel.
@immutable
class WeatherTileCoordinate {
  const WeatherTileCoordinate({
    required this.zoom,
    required this.x,
    required this.y,
  }) : assert(zoom >= 0),
       assert(x >= 0),
       assert(y >= 0);

  final int zoom;
  final int x;
  final int y;

  String get cacheKey => '$zoom/$x/$y';

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeatherTileCoordinate &&
            zoom == other.zoom &&
            x == other.x &&
            y == other.y;
  }

  @override
  int get hashCode => Object.hash(zoom, x, y);

  @override
  String toString() => 'WeatherTileCoordinate($cacheKey)';
}

/// Providerneutrale Wetterkachel.
///
/// Der Inhalt kann beispielsweise aus PNG-, WebP- oder Binärdaten bestehen.
@immutable
class WeatherTile {
  WeatherTile({
    required this.coordinate,
    required Uint8List bytes,
    required this.contentType,
    required this.loadedAt,
    this.expiresAt,
    this.etag,
  }) : bytes = Uint8List.fromList(bytes);

  final WeatherTileCoordinate coordinate;
  final Uint8List bytes;
  final String contentType;
  final DateTime loadedAt;
  final DateTime? expiresAt;
  final String? etag;

  int get byteLength => bytes.lengthInBytes;

  bool isExpiredAt(DateTime time) {
    final expiry = expiresAt;

    if (expiry == null) {
      return false;
    }

    return !time.isBefore(expiry);
  }
}
