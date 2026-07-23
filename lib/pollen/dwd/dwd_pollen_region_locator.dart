import 'dwd_pollen_dataset.dart';

/// Fehler der geografischen DWD-Regionsauswahl.
class DwdPollenRegionLocatorException implements Exception {
  const DwdPollenRegionLocatorException(this.message);

  final String message;

  @override
  String toString() => 'DwdPollenRegionLocatorException: $message';
}

/// Austauschbarer Vertrag für die Zuordnung von Koordinaten zu einer
/// DWD-Pollenvorhersageregion.
///
/// Die Schnittstelle ist bewusst unabhängig von einer konkreten
/// Geometriequelle. Eine spätere Polygon-, Geocoding- oder
/// Verwaltungsgebietslogik kann dadurch ohne Umbau des Providers
/// eingesetzt werden.
abstract interface class DwdPollenRegionLocator {
  DwdPollenRegion locate({
    required double latitude,
    required double longitude,
    required DwdPollenDataset dataset,
  });
}

/// Deterministische Regionsauswahl anhand der offiziellen DWD-IDs.
///
/// Diese Implementierung eignet sich für Tests, bekannte Standorte und
/// später als Ziel einer vorgelagerten Geocoding- oder Polygonermittlung.
class DwdPollenRegionIdLocator implements DwdPollenRegionLocator {
  const DwdPollenRegionIdLocator({
    required this.regionId,
    required this.partRegionId,
  });

  final int regionId;
  final int partRegionId;

  @override
  DwdPollenRegion locate({
    required double latitude,
    required double longitude,
    required DwdPollenDataset dataset,
  }) {
    for (final region in dataset.regions) {
      if (region.regionId == regionId && region.partRegionId == partRegionId) {
        return region;
      }
    }

    throw DwdPollenRegionLocatorException(
      'Die DWD-Pollenregion '
      '$regionId/$partRegionId ist im Datensatz nicht enthalten.',
    );
  }
}
