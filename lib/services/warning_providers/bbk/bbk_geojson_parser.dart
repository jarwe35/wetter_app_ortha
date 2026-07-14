import '../../../models/warning_bridge/bbk_warning_geometry.dart';

class BbkGeoJsonParser {
  const BbkGeoJsonParser();

  BbkWarningGeometry parse(dynamic payload) {
    if (payload is! Map) {
      throw const FormatException('BBK-GeoJSON muss ein JSON-Objekt sein.');
    }

    if (payload['type'] != 'FeatureCollection') {
      throw const FormatException(
        'BBK-GeoJSON muss eine FeatureCollection sein.',
      );
    }

    final features = payload['features'];

    if (features is! List) {
      throw const FormatException(
        'BBK-GeoJSON enthält keine gültige Feature-Liste.',
      );
    }

    String? warningId;
    final polygons = <BbkWarningPolygon>[];

    for (final feature in features) {
      if (feature is! Map) {
        continue;
      }

      final properties = feature['properties'];

      if (warningId == null && properties is Map) {
        final value = properties['warnId'];

        if (value is String && value.trim().isNotEmpty) {
          warningId = value.trim();
        }
      }

      final geometry = feature['geometry'];

      if (geometry is! Map) {
        continue;
      }

      final type = geometry['type'];
      final coordinates = geometry['coordinates'];

      if (type == 'Polygon') {
        final polygon = _parsePolygon(coordinates);

        if (polygon != null) {
          polygons.add(polygon);
        }
      } else if (type == 'MultiPolygon') {
        polygons.addAll(_parseMultiPolygon(coordinates));
      }
    }

    if (warningId == null || warningId.isEmpty) {
      throw const FormatException('BBK-GeoJSON enthält keine Warn-ID.');
    }

    return BbkWarningGeometry(
      warningId: warningId,
      polygons: List<BbkWarningPolygon>.unmodifiable(polygons),
    );
  }

  BbkWarningPolygon? _parsePolygon(dynamic coordinates) {
    if (coordinates is! List || coordinates.isEmpty) {
      return null;
    }

    final outerRing = _parseRing(coordinates.first);

    if (outerRing.length < 3) {
      return null;
    }

    final holes = <List<BbkGeoPoint>>[];

    for (final holeCoordinates in coordinates.skip(1)) {
      final hole = _parseRing(holeCoordinates);

      if (hole.length >= 3) {
        holes.add(List<BbkGeoPoint>.unmodifiable(hole));
      }
    }

    return BbkWarningPolygon(
      outerRing: List<BbkGeoPoint>.unmodifiable(outerRing),
      holes: List<List<BbkGeoPoint>>.unmodifiable(holes),
    );
  }

  List<BbkWarningPolygon> _parseMultiPolygon(dynamic coordinates) {
    if (coordinates is! List) {
      return const [];
    }

    final polygons = <BbkWarningPolygon>[];

    for (final polygonCoordinates in coordinates) {
      final polygon = _parsePolygon(polygonCoordinates);

      if (polygon != null) {
        polygons.add(polygon);
      }
    }

    return polygons;
  }

  List<BbkGeoPoint> _parseRing(dynamic coordinates) {
    if (coordinates is! List) {
      return const [];
    }

    final points = <BbkGeoPoint>[];

    for (final coordinate in coordinates) {
      if (coordinate is! List || coordinate.length < 2) {
        continue;
      }

      final longitude = coordinate[0];
      final latitude = coordinate[1];

      if (longitude is! num || latitude is! num) {
        continue;
      }

      points.add(
        BbkGeoPoint(
          longitude: longitude.toDouble(),
          latitude: latitude.toDouble(),
        ),
      );
    }

    return points;
  }
}
