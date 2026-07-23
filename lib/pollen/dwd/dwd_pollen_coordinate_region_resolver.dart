import 'dart:math' as math;

import 'dwd_pollen_region_catalog.dart';

/// Geografischer Referenzpunkt für ein geprüftes DWD-Pollengebiet.
///
/// Ein Referenzpunkt beansprucht ausdrücklich nicht, das gesamte DWD-Gebiet
/// geometrisch abzubilden. Er ermöglicht nur innerhalb des konfigurierten
/// Radius eine kontrollierte und reproduzierbare Zuordnung.
class DwdPollenRegionReferencePoint {
  const DwdPollenRegionReferencePoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.regionKey,
    required this.maximumDistanceKm,
  }) : assert(maximumDistanceKm > 0);

  final String name;
  final double latitude;
  final double longitude;
  final DwdPollenRegionKey regionKey;
  final double maximumDistanceKm;
}

/// Erfolgreiches Ergebnis einer kontrollierten Koordinatenauflösung.
class DwdPollenCoordinateResolution {
  const DwdPollenCoordinateResolution({
    required this.regionKey,
    required this.referencePoint,
    required this.distanceKm,
  });

  final DwdPollenRegionKey regionKey;
  final DwdPollenRegionReferencePoint referencePoint;
  final double distanceKm;
}

/// Löst Koordinaten ausschließlich innerhalb geprüfter Referenzbereiche auf.
///
/// Wird kein zulässiger Referenzbereich erreicht, liefert [resolve] bewusst
/// `null`. Dadurch kann die übergeordnete Pollenpipeline einen anderen
/// Provider verwenden, anstatt eine unsichere DWD-Region zu erraten.
class DwdPollenCoordinateRegionResolver {
  DwdPollenCoordinateRegionResolver({
    required List<DwdPollenRegionReferencePoint> referencePoints,
  }) : referencePoints = List.unmodifiable(referencePoints) {
    if (referencePoints.isEmpty) {
      throw ArgumentError.value(
        referencePoints,
        'referencePoints',
        'Mindestens ein Referenzpunkt ist erforderlich.',
      );
    }

    for (final point in referencePoints) {
      if (!DwdPollenRegionCatalog.contains(point.regionKey)) {
        throw ArgumentError.value(
          point.regionKey,
          'referencePoints',
          'Der Referenzpunkt ${point.name} verwendet eine unbekannte '
              'DWD-Pollenregionskennung.',
        );
      }

      _validateCoordinates(
        latitude: point.latitude,
        longitude: point.longitude,
      );
    }
  }

  final List<DwdPollenRegionReferencePoint> referencePoints;

  /// Kontrollierte Referenzpunkte für die Demonstrationsregionen in NRW.
  ///
  /// Die Radien sind bewusst eng gewählt. Eine vollständige bundesweite
  /// Geometrieauflösung wird in einer späteren Phase separat ergänzt.
  factory DwdPollenCoordinateRegionResolver.nrwDemonstrator() {
    return DwdPollenCoordinateRegionResolver(
      referencePoints: const [
        DwdPollenRegionReferencePoint(
          name: 'Düsseldorf',
          latitude: 51.2254,
          longitude: 6.7763,
          regionKey: DwdPollenRegionKey(regionId: 40, partRegionId: 41),
          maximumDistanceKm: 30,
        ),
        DwdPollenRegionReferencePoint(
          name: 'Duisburg',
          latitude: 51.4344,
          longitude: 6.7623,
          regionKey: DwdPollenRegionKey(regionId: 40, partRegionId: 41),
          maximumDistanceKm: 25,
        ),
        DwdPollenRegionReferencePoint(
          name: 'Bielefeld',
          latitude: 52.0302,
          longitude: 8.5325,
          regionKey: DwdPollenRegionKey(regionId: 40, partRegionId: 42),
          maximumDistanceKm: 25,
        ),
        DwdPollenRegionReferencePoint(
          name: 'Winterberg',
          latitude: 51.1925,
          longitude: 8.5327,
          regionKey: DwdPollenRegionKey(regionId: 40, partRegionId: 43),
          maximumDistanceKm: 20,
        ),
      ],
    );
  }

  DwdPollenCoordinateResolution? resolve({
    required double latitude,
    required double longitude,
  }) {
    _validateCoordinates(latitude: latitude, longitude: longitude);

    DwdPollenCoordinateResolution? nearest;

    for (final point in referencePoints) {
      final distanceKm = distanceInKilometers(
        latitudeA: latitude,
        longitudeA: longitude,
        latitudeB: point.latitude,
        longitudeB: point.longitude,
      );

      if (distanceKm > point.maximumDistanceKm) {
        continue;
      }

      final candidate = DwdPollenCoordinateResolution(
        regionKey: point.regionKey,
        referencePoint: point,
        distanceKm: distanceKm,
      );

      if (nearest == null || candidate.distanceKm < nearest.distanceKm) {
        nearest = candidate;
      }
    }

    return nearest;
  }

  static double distanceInKilometers({
    required double latitudeA,
    required double longitudeA,
    required double latitudeB,
    required double longitudeB,
  }) {
    _validateCoordinates(latitude: latitudeA, longitude: longitudeA);
    _validateCoordinates(latitude: latitudeB, longitude: longitudeB);

    const earthRadiusKm = 6371.0088;

    final latitudeARadians = _degreesToRadians(latitudeA);
    final latitudeBRadians = _degreesToRadians(latitudeB);
    final latitudeDelta = _degreesToRadians(latitudeB - latitudeA);
    final longitudeDelta = _degreesToRadians(longitudeB - longitudeA);

    final haversineLatitude = math.sin(latitudeDelta / 2);
    final haversineLongitude = math.sin(longitudeDelta / 2);

    final haversine =
        haversineLatitude * haversineLatitude +
        math.cos(latitudeARadians) *
            math.cos(latitudeBRadians) *
            haversineLongitude *
            haversineLongitude;

    final angularDistance =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

    return earthRadiusKm * angularDistance;
  }

  static double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  static void _validateCoordinates({
    required double latitude,
    required double longitude,
  }) {
    if (!latitude.isFinite || latitude < -90 || latitude > 90) {
      throw ArgumentError.value(
        latitude,
        'latitude',
        'Der Breitengrad muss zwischen -90 und 90 liegen.',
      );
    }

    if (!longitude.isFinite || longitude < -180 || longitude > 180) {
      throw ArgumentError.value(
        longitude,
        'longitude',
        'Der Längengrad muss zwischen -180 und 180 liegen.',
      );
    }
  }
}
