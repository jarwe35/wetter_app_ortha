import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_catalog.dart';

void main() {
  group('DwdPollenRegionCatalog', () {
    test('enthält 27 Vorhersagegebiete', () {
      expect(DwdPollenRegionCatalog.definitions, hasLength(27));
    });

    test('enthält keine doppelten Regionsschlüssel', () {
      final keys = DwdPollenRegionCatalog.definitions
          .map((definition) => definition.key)
          .toSet();

      expect(keys, hasLength(DwdPollenRegionCatalog.definitions.length));
    });

    test('enthält drei Teilregionen für Nordrhein-Westfalen', () {
      final regions = DwdPollenRegionCatalog.forRegion(40);

      expect(regions, hasLength(3));

      expect(
        regions.map((definition) => definition.key.partRegionId),
        containsAll(<int>[41, 42, 43]),
      );
    });

    test('findet das Rheinisch-Westfälische Tiefland', () {
      final definition = DwdPollenRegionCatalog.find(
        regionId: 40,
        partRegionId: 41,
      );

      expect(definition, isNotNull);
      expect(definition!.regionName, 'Nordrhein-Westfalen');
      expect(definition.partRegionName, 'Rheinisch-Westfälisches Tiefland');
    });

    test('liefert null für unbekannte Kennungen', () {
      final definition = DwdPollenRegionCatalog.find(
        regionId: 999,
        partRegionId: 999,
      );

      expect(definition, isNull);
    });

    test('Regionsschlüssel besitzen Wertgleichheit', () {
      const first = DwdPollenRegionKey(regionId: 40, partRegionId: 41);

      const second = DwdPollenRegionKey(regionId: 40, partRegionId: 41);

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first.toString(), '40/41');
    });
  });
}
