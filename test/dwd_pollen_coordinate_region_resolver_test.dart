import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_coordinate_region_resolver.dart';
import 'package:wetter_app_ortha/pollen/dwd/dwd_pollen_region_catalog.dart';

void main() {
  group('DwdPollenCoordinateRegionResolver', () {
    test('ordnet Düsseldorf dem Rheinisch-Westfälischen Tiefland zu', () {
      final resolver = DwdPollenCoordinateRegionResolver.nrwDemonstrator();

      final result = resolver.resolve(latitude: 51.2254, longitude: 6.7763);

      expect(result, isNotNull);
      expect(
        result!.regionKey,
        const DwdPollenRegionKey(regionId: 40, partRegionId: 41),
      );
      expect(result.referencePoint.name, 'Düsseldorf');
      expect(result.distanceKm, closeTo(0, 0.01));
    });

    test('ordnet Duisburg dem Rheinisch-Westfälischen Tiefland zu', () {
      final resolver = DwdPollenCoordinateRegionResolver.nrwDemonstrator();

      final result = resolver.resolve(latitude: 51.4344, longitude: 6.7623);

      expect(result, isNotNull);
      expect(result!.regionKey.regionId, 40);
      expect(result.regionKey.partRegionId, 41);
      expect(result.referencePoint.name, 'Duisburg');
    });

    test('ordnet Bielefeld Ostwestfalen zu', () {
      final resolver = DwdPollenCoordinateRegionResolver.nrwDemonstrator();

      final result = resolver.resolve(latitude: 52.0302, longitude: 8.5325);

      expect(result, isNotNull);
      expect(
        result!.regionKey,
        const DwdPollenRegionKey(regionId: 40, partRegionId: 42),
      );
    });

    test('ordnet Winterberg dem NRW-Mittelgebirge zu', () {
      final resolver = DwdPollenCoordinateRegionResolver.nrwDemonstrator();

      final result = resolver.resolve(latitude: 51.1925, longitude: 8.5327);

      expect(result, isNotNull);
      expect(
        result!.regionKey,
        const DwdPollenRegionKey(regionId: 40, partRegionId: 43),
      );
    });

    test('liefert außerhalb geprüfter Bereiche null', () {
      final resolver = DwdPollenCoordinateRegionResolver.nrwDemonstrator();

      final result = resolver.resolve(latitude: 52.5200, longitude: 13.4050);

      expect(result, isNull);
    });

    test('wählt bei mehreren Treffern den nächsten Referenzpunkt', () {
      final resolver = DwdPollenCoordinateRegionResolver(
        referencePoints: const [
          DwdPollenRegionReferencePoint(
            name: 'Düsseldorf',
            latitude: 51.2254,
            longitude: 6.7763,
            regionKey: DwdPollenRegionKey(regionId: 40, partRegionId: 41),
            maximumDistanceKm: 50,
          ),
          DwdPollenRegionReferencePoint(
            name: 'Duisburg',
            latitude: 51.4344,
            longitude: 6.7623,
            regionKey: DwdPollenRegionKey(regionId: 40, partRegionId: 41),
            maximumDistanceKm: 50,
          ),
        ],
      );

      final result = resolver.resolve(latitude: 51.4300, longitude: 6.7600);

      expect(result, isNotNull);
      expect(result!.referencePoint.name, 'Duisburg');
    });

    test('berechnet eine plausible Entfernung', () {
      final distance = DwdPollenCoordinateRegionResolver.distanceInKilometers(
        latitudeA: 51.2254,
        longitudeA: 6.7763,
        latitudeB: 51.4344,
        longitudeB: 6.7623,
      );

      expect(distance, greaterThan(20));
      expect(distance, lessThan(25));
    });

    test('weist ungültige Koordinaten zurück', () {
      final resolver = DwdPollenCoordinateRegionResolver.nrwDemonstrator();

      expect(
        () => resolver.resolve(latitude: 91, longitude: 6.7763),
        throwsArgumentError,
      );

      expect(
        () => resolver.resolve(latitude: 51.2254, longitude: 181),
        throwsArgumentError,
      );
    });

    test('weist unbekannte Regionsschlüssel im Konstruktor zurück', () {
      expect(
        () => DwdPollenCoordinateRegionResolver(
          referencePoints: const [
            DwdPollenRegionReferencePoint(
              name: 'Ungültig',
              latitude: 51,
              longitude: 7,
              regionKey: DwdPollenRegionKey(regionId: 999, partRegionId: 999),
              maximumDistanceKm: 10,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });
  });
}
