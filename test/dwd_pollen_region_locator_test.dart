import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_dataset.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_locator.dart';

void main() {
  group('DwdPollenRegionIdLocator', () {
    test('findet die Region anhand von Region- und Teilregions-ID', () {
      final region = _region(regionId: 40, partRegionId: 41);
      final dataset = _dataset([region]);

      const locator = DwdPollenRegionIdLocator(regionId: 40, partRegionId: 41);

      final result = locator.locate(
        latitude: 51.2,
        longitude: 6.8,
        dataset: dataset,
      );

      expect(result, same(region));
    });

    test('meldet eine nicht vorhandene Region', () {
      final dataset = _dataset([_region(regionId: 40, partRegionId: 41)]);

      const locator = DwdPollenRegionIdLocator(regionId: 90, partRegionId: 91);

      expect(
        () => locator.locate(latitude: 51.2, longitude: 6.8, dataset: dataset),
        throwsA(isA<DwdPollenRegionLocatorException>()),
      );
    });
  });
}

DwdPollenDataset _dataset(List<DwdPollenRegion> regions) {
  return DwdPollenDataset(
    name: 'Test',
    sender: 'DWD',
    lastUpdate: DateTime(2026, 7, 23),
    nextUpdate: DateTime(2026, 7, 24),
    legend: const {},
    regions: regions,
  );
}

DwdPollenRegion _region({required int regionId, required int partRegionId}) {
  return DwdPollenRegion(
    regionId: regionId,
    partRegionId: partRegionId,
    regionName: 'Testregion',
    partRegionName: 'Testteilregion',
    pollen: const {},
  );
}
