import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/main.dart';
import 'package:wetter_app_ortha/settings/unit_settings.dart';

void main() {
  group('Einheitenumrechnung', () {
    test('0 Grad Celsius entsprechen 32 Grad Fahrenheit', () {
      const settings = UnitSettings(
        temperatureUnit: TemperatureUnit.fahrenheit,
      );

      expect(formatTemperature(0, settings, decimals: 1), '32.0 °F');
    });

    test('100 Grad Celsius entsprechen 212 Grad Fahrenheit', () {
      const settings = UnitSettings(
        temperatureUnit: TemperatureUnit.fahrenheit,
      );

      expect(formatTemperature(100, settings, decimals: 0), '212 °F');
    });

    test('18.52 kmh entsprechen 10 Knoten', () {
      const settings = UnitSettings(windSpeedUnit: WindSpeedUnit.knots);

      expect(formatWindSpeed(18.52, settings, decimals: 1), '10.0 kn');
    });

    test('1609.344 Meter entsprechen einer Meile', () {
      const settings = UnitSettings(visibilityUnit: VisibilityUnit.miles);

      expect(formatVisibility(1609.344, settings), '1.0 mi');
    });

    test('25.4 Millimeter entsprechen einem Inch', () {
      const settings = UnitSettings(
        precipitationUnit: PrecipitationUnit.inches,
      );

      expect(formatPrecipitation(25.4, settings), '1.00 in');
    });

    test('metrische Standardeinheiten bleiben unverändert', () {
      const settings = UnitSettings();

      expect(formatTemperature(20, settings), '20.0 °C');
      expect(formatWindSpeed(36, settings), '36.0 km/h');
      expect(formatVisibility(10000, settings), '10.0 km');
      expect(formatPrecipitation(5, settings), '5.0 l/m²');
    });
  });
}
