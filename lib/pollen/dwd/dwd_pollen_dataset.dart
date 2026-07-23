/// Unveränderte fachliche Repräsentation der regionalen DWD-Pollendaten.
///
/// Die Umwandlung in das ORTHA-Modell [PollenForecast] erfolgt erst in einer
/// späteren Schicht. Dadurch bleiben Download, Parsing und Regionalauswahl
/// unabhängig von der Benutzeroberfläche und von Konzentrationswerten anderer
/// Datenquellen.
class DwdPollenDataset {
  const DwdPollenDataset({
    required this.name,
    required this.sender,
    required this.lastUpdate,
    required this.nextUpdate,
    required this.legend,
    required this.regions,
  });

  final String name;
  final String sender;
  final DateTime? lastUpdate;
  final DateTime? nextUpdate;
  final Map<String, String> legend;
  final List<DwdPollenRegion> regions;
}

class DwdPollenRegion {
  const DwdPollenRegion({
    required this.regionId,
    required this.partRegionId,
    required this.regionName,
    required this.partRegionName,
    required this.pollen,
  });

  final int regionId;
  final int partRegionId;
  final String regionName;
  final String partRegionName;
  final Map<DwdPollenType, DwdPollenDayValues> pollen;

  String get displayName {
    if (partRegionName.trim().isNotEmpty) {
      return partRegionName.trim();
    }

    return regionName.trim();
  }
}

class DwdPollenDayValues {
  const DwdPollenDayValues({
    required this.today,
    required this.tomorrow,
    required this.dayAfterTomorrow,
  });

  final DwdPollenIndex? today;
  final DwdPollenIndex? tomorrow;
  final DwdPollenIndex? dayAfterTomorrow;
}

enum DwdPollenType { hazel, alder, ash, birch, grass, rye, mugwort, ragweed }

enum DwdPollenIndex {
  none(0),
  noneToLow(0.5),
  low(1),
  lowToModerate(1.5),
  moderate(2),
  moderateToHigh(2.5),
  high(3);

  const DwdPollenIndex(this.numericValue);

  final double numericValue;
}
