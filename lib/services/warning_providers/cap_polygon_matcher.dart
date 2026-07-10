class CapPolygonMatcher {
  const CapPolygonMatcher();

  bool containsPoint({
    required String polygon,
    required double latitude,
    required double longitude,
  }) {
    final points = _parsePolygon(polygon);

    if (points.length < 3) {
      return false;
    }

    var inside = false;
    var j = points.length - 1;

    for (var i = 0; i < points.length; i++) {
      final current = points[i];
      final previous = points[j];

      if (_pointOnSegment(
        latitude: latitude,
        longitude: longitude,
        start: previous,
        end: current,
      )) {
        return true;
      }

      final intersects =
          ((current.latitude > latitude) != (previous.latitude > latitude)) &&
          (longitude <
              (previous.longitude - current.longitude) *
                      (latitude - current.latitude) /
                      (previous.latitude - current.latitude) +
                  current.longitude);

      if (intersects) {
        inside = !inside;
      }

      j = i;
    }

    return inside;
  }

  List<_GeoPoint> _parsePolygon(String polygon) {
    final points = <_GeoPoint>[];

    for (final coordinatePair in polygon.trim().split(RegExp(r'\s+'))) {
      final parts = coordinatePair.split(',');

      if (parts.length != 2) {
        continue;
      }

      final latitude = double.tryParse(parts[0].trim());
      final longitude = double.tryParse(parts[1].trim());

      if (latitude == null || longitude == null) {
        continue;
      }

      points.add(_GeoPoint(latitude: latitude, longitude: longitude));
    }

    return points;
  }

  bool _pointOnSegment({
    required double latitude,
    required double longitude,
    required _GeoPoint start,
    required _GeoPoint end,
  }) {
    const epsilon = 1e-10;

    final crossProduct =
        (latitude - start.latitude) * (end.longitude - start.longitude) -
        (longitude - start.longitude) * (end.latitude - start.latitude);

    if (crossProduct.abs() > epsilon) {
      return false;
    }

    final minLatitude = start.latitude < end.latitude
        ? start.latitude
        : end.latitude;
    final maxLatitude = start.latitude > end.latitude
        ? start.latitude
        : end.latitude;
    final minLongitude = start.longitude < end.longitude
        ? start.longitude
        : end.longitude;
    final maxLongitude = start.longitude > end.longitude
        ? start.longitude
        : end.longitude;

    return latitude >= minLatitude - epsilon &&
        latitude <= maxLatitude + epsilon &&
        longitude >= minLongitude - epsilon &&
        longitude <= maxLongitude + epsilon;
  }
}

class _GeoPoint {
  final double latitude;
  final double longitude;

  const _GeoPoint({required this.latitude, required this.longitude});
}
