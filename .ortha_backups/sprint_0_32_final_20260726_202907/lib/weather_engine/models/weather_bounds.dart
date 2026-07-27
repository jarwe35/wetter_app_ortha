import 'package:flutter/foundation.dart';

/// Geografischer Gültigkeitsbereich einer Wetterebene.
///
/// Die Klasse ist vollständig unabhängig von einer Kartenbibliothek oder
/// einem konkreten Wetterdatenanbieter.
@immutable
class WeatherBounds {
  const WeatherBounds({
    required this.south,
    required this.west,
    required this.north,
    required this.east,
  }) : assert(south >= -90 && south <= 90),
       assert(north >= -90 && north <= 90),
       assert(west >= -180 && west <= 180),
       assert(east >= -180 && east <= 180),
       assert(south <= north);

  final double south;
  final double west;
  final double north;
  final double east;

  /// Prüft, ob eine geografische Koordinate innerhalb des Bereichs liegt.
  ///
  /// Auch Bereiche, die den 180. Längengrad überschreiten, werden unterstützt.
  bool contains({required double latitude, required double longitude}) {
    if (latitude < south || latitude > north) {
      return false;
    }

    if (west <= east) {
      return longitude >= west && longitude <= east;
    }

    return longitude >= west || longitude <= east;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeatherBounds &&
            south == other.south &&
            west == other.west &&
            north == other.north &&
            east == other.east;
  }

  @override
  int get hashCode => Object.hash(south, west, north, east);

  @override
  String toString() {
    return 'WeatherBounds('
        'south: $south, '
        'west: $west, '
        'north: $north, '
        'east: $east'
        ')';
  }
}
