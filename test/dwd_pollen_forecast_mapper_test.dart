import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/models/pollen_forecast.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_dataset.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_forecast_mapper.dart';

void main() {
  group('DwdPollenForecastMapper', () {
    const mapper = DwdPollenForecastMapper();

    test('erzeugt drei ORTHA-Vorhersagetage', () {
      final forecast = mapper.map(
        region: _region,
        latitude: 51.2,
        longitude: 6.8,
        referenceDate: DateTime(2026, 7, 23, 11),
      );

      expect(forecast.latitude, 51.2);
      expect(forecast.longitude, 6.8);
      expect(forecast.timezone, 'Europe/Berlin');
      expect(forecast.days, hasLength(3));

      expect(forecast.days[0].date, DateTime(2026, 7, 23));
      expect(forecast.days[1].date, DateTime(2026, 7, 24));
      expect(forecast.days[2].date, DateTime(2026, 7, 25));
    });

    test('bildet DWD-Stufen auf geordnete Repräsentationswerte ab', () {
      final forecast = mapper.map(
        region: _region,
        latitude: 51.2,
        longitude: 6.8,
        referenceDate: DateTime(2026, 7, 23),
      );

      final todayGrass = forecast.days[0].values.firstWhere(
        (value) => value.type == PollenType.grass,
      );
      final tomorrowGrass = forecast.days[1].values.firstWhere(
        (value) => value.type == PollenType.grass,
      );
      final dayAfterGrass = forecast.days[2].values.firstWhere(
        (value) => value.type == PollenType.grass,
      );

      expect(todayGrass.concentration, 25);
      expect(tomorrowGrass.concentration, 40);
      expect(dayAfterGrass.concentration, 70);
    });

    test('behandelt fehlende DWD-Werte als null Belastung', () {
      final forecast = mapper.map(
        region: _region,
        latitude: 51.2,
        longitude: 6.8,
        referenceDate: DateTime(2026, 7, 23),
      );

      final alder = forecast.days.first.values.firstWhere(
        (value) => value.type == PollenType.alder,
      );

      expect(alder.concentration, 0);
    });
  });
}

const _region = DwdPollenRegion(
  regionId: 40,
  partRegionId: 41,
  regionName: 'Nordrhein-Westfalen',
  partRegionName: 'Rhein.-Westfäl. Tiefland',
  pollen: {
    DwdPollenType.alder: DwdPollenDayValues(
      today: null,
      tomorrow: null,
      dayAfterTomorrow: null,
    ),
    DwdPollenType.birch: DwdPollenDayValues(
      today: DwdPollenIndex.low,
      tomorrow: DwdPollenIndex.lowToModerate,
      dayAfterTomorrow: DwdPollenIndex.moderate,
    ),
    DwdPollenType.grass: DwdPollenDayValues(
      today: DwdPollenIndex.lowToModerate,
      tomorrow: DwdPollenIndex.moderate,
      dayAfterTomorrow: DwdPollenIndex.moderateToHigh,
    ),
    DwdPollenType.mugwort: DwdPollenDayValues(
      today: DwdPollenIndex.noneToLow,
      tomorrow: DwdPollenIndex.low,
      dayAfterTomorrow: DwdPollenIndex.lowToModerate,
    ),
    DwdPollenType.ragweed: DwdPollenDayValues(
      today: DwdPollenIndex.none,
      tomorrow: DwdPollenIndex.noneToLow,
      dayAfterTomorrow: DwdPollenIndex.low,
    ),
  },
);
