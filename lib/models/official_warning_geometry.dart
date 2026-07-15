class OfficialWarningGeometry {
  final List<List<List<double>>> polygons;

  const OfficialWarningGeometry({required this.polygons});

  bool get isEmpty => polygons.isEmpty;

  bool contains({required double latitude, required double longitude}) {
    return polygons.any(
      (ring) =>
          _ringContainsPoint(ring, latitude: latitude, longitude: longitude),
    );
  }

  bool _ringContainsPoint(
    List<List<double>> ring, {
    required double latitude,
    required double longitude,
  }) {
    if (ring.length < 3) {
      return false;
    }

    var inside = false;
    var previousIndex = ring.length - 1;

    for (var currentIndex = 0; currentIndex < ring.length; currentIndex++) {
      final current = ring[currentIndex];
      final previous = ring[previousIndex];

      if (current.length < 2 || previous.length < 2) {
        previousIndex = currentIndex;
        continue;
      }

      final currentLatitude = current[0];
      final currentLongitude = current[1];
      final previousLatitude = previous[0];
      final previousLongitude = previous[1];

      if (_pointIsOnSegment(
        latitude: latitude,
        longitude: longitude,
        startLatitude: previousLatitude,
        startLongitude: previousLongitude,
        endLatitude: currentLatitude,
        endLongitude: currentLongitude,
      )) {
        return true;
      }

      final intersects =
          ((currentLatitude > latitude) != (previousLatitude > latitude)) &&
          (longitude <
              (previousLongitude - currentLongitude) *
                      (latitude - currentLatitude) /
                      (previousLatitude - currentLatitude) +
                  currentLongitude);

      if (intersects) {
        inside = !inside;
      }

      previousIndex = currentIndex;
    }

    return inside;
  }

  bool _pointIsOnSegment({
    required double latitude,
    required double longitude,
    required double startLatitude,
    required double startLongitude,
    required double endLatitude,
    required double endLongitude,
  }) {
    const epsilon = 1e-10;

    final crossProduct =
        (latitude - startLatitude) * (endLongitude - startLongitude) -
        (longitude - startLongitude) * (endLatitude - startLatitude);

    if (crossProduct.abs() > epsilon) {
      return false;
    }

    final minimumLongitude = startLongitude < endLongitude
        ? startLongitude
        : endLongitude;
    final maximumLongitude = startLongitude > endLongitude
        ? startLongitude
        : endLongitude;
    final minimumLatitude = startLatitude < endLatitude
        ? startLatitude
        : endLatitude;
    final maximumLatitude = startLatitude > endLatitude
        ? startLatitude
        : endLatitude;

    return longitude >= minimumLongitude - epsilon &&
        longitude <= maximumLongitude + epsilon &&
        latitude >= minimumLatitude - epsilon &&
        latitude <= maximumLatitude + epsilon;
  }
}
