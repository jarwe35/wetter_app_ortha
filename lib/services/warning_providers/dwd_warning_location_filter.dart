import '../../models/official_weather_warning.dart';
import 'cap_polygon_matcher.dart';

class DwdWarningLocationFilter {
  final CapPolygonMatcher polygonMatcher;

  const DwdWarningLocationFilter({
    this.polygonMatcher = const CapPolygonMatcher(),
  });

  List<OfficialWeatherWarning> filterForLocation({
    required List<OfficialWeatherWarning> warnings,
    required double latitude,
    required double longitude,
  }) {
    return warnings.where((warning) {
      if (warning.polygons.isEmpty) {
        return false;
      }

      return warning.polygons.any(
        (polygon) => polygonMatcher.containsPoint(
          polygon: polygon,
          latitude: latitude,
          longitude: longitude,
        ),
      );
    }).toList();
  }
}
