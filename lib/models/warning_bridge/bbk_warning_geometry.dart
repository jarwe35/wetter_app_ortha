class BbkGeoPoint {
  final double longitude;
  final double latitude;

  const BbkGeoPoint({required this.longitude, required this.latitude});
}

class BbkWarningPolygon {
  final List<BbkGeoPoint> outerRing;
  final List<List<BbkGeoPoint>> holes;

  const BbkWarningPolygon({required this.outerRing, this.holes = const []});
}

class BbkWarningGeometry {
  final String warningId;
  final List<BbkWarningPolygon> polygons;

  const BbkWarningGeometry({required this.warningId, required this.polygons});

  bool contains({required double latitude, required double longitude}) {
    final point = BbkGeoPoint(longitude: longitude, latitude: latitude);

    return polygons.any((polygon) => _polygonContainsPoint(polygon, point));
  }

  bool _polygonContainsPoint(BbkWarningPolygon polygon, BbkGeoPoint point) {
    if (!_ringContainsPoint(polygon.outerRing, point)) {
      return false;
    }

    for (final hole in polygon.holes) {
      if (_ringContainsPoint(hole, point)) {
        return false;
      }
    }

    return true;
  }

  bool _ringContainsPoint(List<BbkGeoPoint> ring, BbkGeoPoint point) {
    if (ring.length < 3) {
      return false;
    }

    var inside = false;
    var previousIndex = ring.length - 1;

    for (var currentIndex = 0; currentIndex < ring.length; currentIndex++) {
      final current = ring[currentIndex];
      final previous = ring[previousIndex];

      if (_pointIsOnSegment(point, previous, current)) {
        return true;
      }

      final intersects =
          ((current.latitude > point.latitude) !=
              (previous.latitude > point.latitude)) &&
          (point.longitude <
              (previous.longitude - current.longitude) *
                      (point.latitude - current.latitude) /
                      (previous.latitude - current.latitude) +
                  current.longitude);

      if (intersects) {
        inside = !inside;
      }

      previousIndex = currentIndex;
    }

    return inside;
  }

  bool _pointIsOnSegment(
    BbkGeoPoint point,
    BbkGeoPoint start,
    BbkGeoPoint end,
  ) {
    const epsilon = 1e-10;

    final crossProduct =
        (point.latitude - start.latitude) * (end.longitude - start.longitude) -
        (point.longitude - start.longitude) * (end.latitude - start.latitude);

    if (crossProduct.abs() > epsilon) {
      return false;
    }

    final minimumLongitude = start.longitude < end.longitude
        ? start.longitude
        : end.longitude;
    final maximumLongitude = start.longitude > end.longitude
        ? start.longitude
        : end.longitude;
    final minimumLatitude = start.latitude < end.latitude
        ? start.latitude
        : end.latitude;
    final maximumLatitude = start.latitude > end.latitude
        ? start.latitude
        : end.latitude;

    return point.longitude >= minimumLongitude - epsilon &&
        point.longitude <= maximumLongitude + epsilon &&
        point.latitude >= minimumLatitude - epsilon &&
        point.latitude <= maximumLatitude + epsilon;
  }
}
