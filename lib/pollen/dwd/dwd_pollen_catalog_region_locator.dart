import 'dwd_pollen_dataset.dart';
import 'dwd_pollen_region_catalog.dart';
import 'dwd_pollen_region_locator.dart';

/// Wählt anhand einer zuvor bestimmten offiziellen Regionskennung den
/// passenden Eintrag aus dem aktuellen DWD-Datensatz.
///
/// Diese Klasse führt bewusst noch keine GPS- oder Polygonberechnung durch.
/// Sie stellt sicher, dass nur katalogisierte DWD-Regionskennungen verwendet
/// werden können.
class DwdPollenCatalogRegionLocator implements DwdPollenRegionLocator {
  const DwdPollenCatalogRegionLocator({required this.key});

  final DwdPollenRegionKey key;

  @override
  DwdPollenRegion locate({
    required double latitude,
    required double longitude,
    required DwdPollenDataset dataset,
  }) {
    final definition = DwdPollenRegionCatalog.findByKey(key);

    if (definition == null) {
      throw DwdPollenRegionLocatorException(
        'Die DWD-Pollenregionskennung $key ist nicht im '
        'Regionskatalog enthalten.',
      );
    }

    for (final region in dataset.regions) {
      if (region.regionId == key.regionId &&
          region.partRegionId == key.partRegionId) {
        return region;
      }
    }

    throw DwdPollenRegionLocatorException(
      'Die DWD-Pollenregion $key '
      '(${definition.partRegionName}) ist im aktuellen Datensatz '
      'nicht enthalten.',
    );
  }
}
