import 'dwd_pollen_coordinate_region_resolver.dart';
import 'dwd_pollen_dataset.dart';
import 'dwd_pollen_region_locator.dart';

/// Verbindet die kontrollierte Koordinatenauflösung mit dem aktuellen
/// DWD-Pollendatensatz.
class DwdPollenCoordinateRegionLocator implements DwdPollenRegionLocator {
  const DwdPollenCoordinateRegionLocator({required this.resolver});

  final DwdPollenCoordinateRegionResolver resolver;

  @override
  DwdPollenRegion locate({
    required double latitude,
    required double longitude,
    required DwdPollenDataset dataset,
  }) {
    final resolution = resolver.resolve(
      latitude: latitude,
      longitude: longitude,
    );

    if (resolution == null) {
      throw DwdPollenRegionLocatorException(
        'Für die Koordinaten '
        '${latitude.toStringAsFixed(4)}, '
        '${longitude.toStringAsFixed(4)} '
        'ist keine kontrolliert geprüfte DWD-Pollenregion hinterlegt.',
      );
    }

    for (final region in dataset.regions) {
      if (region.regionId == resolution.regionKey.regionId &&
          region.partRegionId == resolution.regionKey.partRegionId) {
        return region;
      }
    }

    throw DwdPollenRegionLocatorException(
      'Die ermittelte DWD-Pollenregion '
      '${resolution.regionKey} ist im aktuellen Datensatz nicht enthalten.',
    );
  }
}
