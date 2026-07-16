import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/forecast_range.dart';

void main() {
  group('ForecastRange', () {
    test('definiert sieben Tage korrekt', () {
      expect(ForecastRange.sevenDays.dayCount, 7);
      expect(ForecastRange.sevenDays.label, '7 Tage');
      expect(
        ForecastRange.sevenDays.semanticLabel,
        'Vorhersage für sieben Tage',
      );
    });

    test('definiert vierzehn Tage korrekt', () {
      expect(ForecastRange.fourteenDays.dayCount, 14);
      expect(ForecastRange.fourteenDays.label, '14 Tage');
      expect(
        ForecastRange.fourteenDays.semanticLabel,
        'Vorhersage für vierzehn Tage',
      );
    });

    test('begrenzt eine längere Liste auf sieben Einträge', () {
      final values = List<int>.generate(14, (index) => index + 1);

      final result = ForecastRange.sevenDays.applyTo(values);

      expect(result, hasLength(7));
      expect(result, orderedEquals(<int>[1, 2, 3, 4, 5, 6, 7]));
    });

    test('begrenzt eine längere Liste auf vierzehn Einträge', () {
      final values = List<int>.generate(20, (index) => index + 1);

      final result = ForecastRange.fourteenDays.applyTo(values);

      expect(result, hasLength(14));
      expect(result.first, 1);
      expect(result.last, 14);
    });

    test('behält kürzere Listen vollständig bei', () {
      final values = <String>['Montag', 'Dienstag', 'Mittwoch'];

      final result = ForecastRange.fourteenDays.applyTo(values);

      expect(result, orderedEquals(values));
    });

    test('verändert die ursprüngliche Liste nicht', () {
      final values = List<int>.generate(14, (index) => index);

      ForecastRange.sevenDays.applyTo(values);

      expect(values, hasLength(14));
    });

    test('liefert eine nicht veränderbare Ergebnisliste', () {
      final result = ForecastRange.sevenDays.applyTo(
        List<int>.generate(14, (index) => index),
      );

      expect(() => result.add(15), throwsUnsupportedError);
    });
  });
}
