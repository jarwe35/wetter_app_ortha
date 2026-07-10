import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/services/warning_providers/cap_polygon_matcher.dart';

void main() {
  group('CapPolygonMatcher', () {
    const matcher = CapPolygonMatcher();

    const polygon = '51.50,6.60 51.50,6.90 51.30,6.90 51.30,6.60 51.50,6.60';

    test('erkennt Punkt innerhalb des Warnpolygons', () {
      expect(
        matcher.containsPoint(
          polygon: polygon,
          latitude: 51.4344,
          longitude: 6.7623,
        ),
        isTrue,
      );
    });

    test('erkennt Punkt außerhalb des Warnpolygons', () {
      expect(
        matcher.containsPoint(
          polygon: polygon,
          latitude: 52.5200,
          longitude: 13.4050,
        ),
        isFalse,
      );
    });

    test('erkennt Punkt auf Polygonkante als enthalten', () {
      expect(
        matcher.containsPoint(
          polygon: polygon,
          latitude: 51.50,
          longitude: 6.75,
        ),
        isTrue,
      );
    });

    test('erkennt Polygone mit Leerzeichen und Zeilenumbrüchen', () {
      const multilinePolygon = '''
51.50,6.60
51.50,6.90   51.30,6.90
51.30,6.60
51.50,6.60
''';

      expect(
        matcher.containsPoint(
          polygon: multilinePolygon,
          latitude: 51.4344,
          longitude: 6.7623,
        ),
        isTrue,
      );
    });

    test('ungültiges Polygon liefert false', () {
      expect(
        matcher.containsPoint(
          polygon: 'ungueltige-daten',
          latitude: 51.4344,
          longitude: 6.7623,
        ),
        isFalse,
      );
    });

    test('Polygon mit weniger als drei gültigen Punkten liefert false', () {
      expect(
        matcher.containsPoint(
          polygon: '51.0,6.0 52.0,7.0',
          latitude: 51.5,
          longitude: 6.5,
        ),
        isFalse,
      );
    });
  });
}
