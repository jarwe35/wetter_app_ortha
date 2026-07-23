/// Eindeutige Kennung eines DWD-Pollen-Vorhersagegebiets.
class DwdPollenRegionKey {
  const DwdPollenRegionKey({
    required this.regionId,
    required this.partRegionId,
  });

  final int regionId;
  final int partRegionId;

  @override
  bool operator ==(Object other) {
    return other is DwdPollenRegionKey &&
        other.regionId == regionId &&
        other.partRegionId == partRegionId;
  }

  @override
  int get hashCode => Object.hash(regionId, partRegionId);

  @override
  String toString() => '$regionId/$partRegionId';
}

/// Beschreibender Eintrag des DWD-Pollenregionskatalogs.
class DwdPollenRegionDefinition {
  const DwdPollenRegionDefinition({
    required this.key,
    required this.regionName,
    required this.partRegionName,
  });

  final DwdPollenRegionKey key;
  final String regionName;
  final String partRegionName;
}

/// Zentraler Katalog der DWD-Pollen-Vorhersagegebiete.
///
/// Der Katalog enthält ausschließlich Regionskennungen und Bezeichnungen.
/// Eine geografische Koordinaten- oder Polygonzuordnung erfolgt bewusst noch
/// nicht in dieser Klasse.
abstract final class DwdPollenRegionCatalog {
  static const List<DwdPollenRegionDefinition> definitions = [
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 10, partRegionId: 11),
      regionName: 'Schleswig-Holstein und Hamburg',
      partRegionName: 'Inseln und Marschen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 10, partRegionId: 12),
      regionName: 'Schleswig-Holstein und Hamburg',
      partRegionName: 'Geest, Schleswig-Holstein und Hamburg',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 20, partRegionId: 20),
      regionName: 'Mecklenburg-Vorpommern',
      partRegionName: 'Mecklenburg-Vorpommern',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 30, partRegionId: 31),
      regionName: 'Niedersachsen und Bremen',
      partRegionName: 'Westliches Niedersachsen und Bremen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 30, partRegionId: 32),
      regionName: 'Niedersachsen und Bremen',
      partRegionName: 'Östliches Niedersachsen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 40, partRegionId: 41),
      regionName: 'Nordrhein-Westfalen',
      partRegionName: 'Rheinisch-Westfälisches Tiefland',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 40, partRegionId: 42),
      regionName: 'Nordrhein-Westfalen',
      partRegionName: 'Ostwestfalen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 40, partRegionId: 43),
      regionName: 'Nordrhein-Westfalen',
      partRegionName: 'Mittelgebirge Nordrhein-Westfalen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 50, partRegionId: 50),
      regionName: 'Brandenburg und Berlin',
      partRegionName: 'Brandenburg und Berlin',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 60, partRegionId: 61),
      regionName: 'Sachsen-Anhalt',
      partRegionName: 'Tiefland Sachsen-Anhalt',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 60, partRegionId: 62),
      regionName: 'Sachsen-Anhalt',
      partRegionName: 'Harz',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 70, partRegionId: 71),
      regionName: 'Thüringen',
      partRegionName: 'Tiefland Thüringen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 70, partRegionId: 72),
      regionName: 'Thüringen',
      partRegionName: 'Mittelgebirge Thüringen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 80, partRegionId: 81),
      regionName: 'Sachsen',
      partRegionName: 'Tiefland Sachsen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 80, partRegionId: 82),
      regionName: 'Sachsen',
      partRegionName: 'Mittelgebirge Sachsen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 90, partRegionId: 91),
      regionName: 'Hessen',
      partRegionName: 'Nordhessen und hessisches Mittelgebirge',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 90, partRegionId: 92),
      regionName: 'Hessen',
      partRegionName: 'Rhein-Main',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 100, partRegionId: 101),
      regionName: 'Rheinland-Pfalz und Saarland',
      partRegionName: 'Rhein, Pfalz, Nahe und Mosel',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 100, partRegionId: 102),
      regionName: 'Rheinland-Pfalz und Saarland',
      partRegionName: 'Mittelgebirgsbereich Rheinland-Pfalz',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 100, partRegionId: 103),
      regionName: 'Rheinland-Pfalz und Saarland',
      partRegionName: 'Saarland',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 110, partRegionId: 111),
      regionName: 'Baden-Württemberg',
      partRegionName: 'Oberrhein und unteres Neckartal',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 110, partRegionId: 112),
      regionName: 'Baden-Württemberg',
      partRegionName: 'Hohenlohe, mittlerer Neckar und Oberschwaben',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 110, partRegionId: 113),
      regionName: 'Baden-Württemberg',
      partRegionName: 'Mittelgebirge Baden-Württemberg',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 120, partRegionId: 121),
      regionName: 'Bayern',
      partRegionName: 'Allgäu, Oberbayern und Bayerischer Wald',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 120, partRegionId: 122),
      regionName: 'Bayern',
      partRegionName: 'Donauniederungen',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 120, partRegionId: 123),
      regionName: 'Bayern',
      partRegionName:
          'Bayern nördlich der Donau ohne Bayerischen Wald und Mainfranken',
    ),
    DwdPollenRegionDefinition(
      key: DwdPollenRegionKey(regionId: 120, partRegionId: 124),
      regionName: 'Bayern',
      partRegionName: 'Mainfranken',
    ),
  ];

  static DwdPollenRegionDefinition? find({
    required int regionId,
    required int partRegionId,
  }) {
    for (final definition in definitions) {
      if (definition.key.regionId == regionId &&
          definition.key.partRegionId == partRegionId) {
        return definition;
      }
    }

    return null;
  }

  static DwdPollenRegionDefinition? findByKey(DwdPollenRegionKey key) {
    return find(regionId: key.regionId, partRegionId: key.partRegionId);
  }

  static List<DwdPollenRegionDefinition> forRegion(int regionId) {
    return List.unmodifiable(
      definitions.where((definition) => definition.key.regionId == regionId),
    );
  }

  static bool contains(DwdPollenRegionKey key) {
    return findByKey(key) != null;
  }
}
