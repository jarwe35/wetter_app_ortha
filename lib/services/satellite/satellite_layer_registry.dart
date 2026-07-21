import '../../models/satellite_layer.dart';

abstract final class SatelliteLayerRegistry {
  static const SatelliteLayerDefinition esriWorldImagery =
      SatelliteLayerDefinition(
        id: 'esri-world-imagery',
        type: SatelliteLayerType.baseMap,
        name: 'Satelliten-Basiskarte',
        description:
            'Hochauflösende geografische Satelliten- und Luftbildkarte.',
        sourceName: 'Esri World Imagery',
        dataFormat: SatelliteLayerDataFormat.tile,
        enabledByDefault: true,
        requiresTimestamp: false,
      );

  static const SatelliteLayerDefinition dwdCloudTopHeight =
      SatelliteLayerDefinition(
        id: 'dwd-cloud-top-height',
        type: SatelliteLayerType.cloudTopHeight,
        name: 'Wolkenobergrenze',
        description:
            'Darstellung der Höhe der Wolkenobergrenze über dem Boden.',
        sourceName: 'DWD Open Data',
        dataFormat: SatelliteLayerDataFormat.netCdf,
        requiresLegend: true,
      );

  static const SatelliteLayerDefinition dwdThunderstormSeverity =
      SatelliteLayerDefinition(
        id: 'dwd-thunderstorm-severity',
        type: SatelliteLayerType.thunderstormSeverity,
        name: 'Gewitterintensität',
        description:
            'Meteorologische Einschätzung der aktuellen Gewitterintensität.',
        sourceName: 'DWD Open Data',
        dataFormat: SatelliteLayerDataFormat.netCdf,
        requiresLegend: true,
      );

  static const SatelliteLayerDefinition
  eumetsatInfrared = SatelliteLayerDefinition(
    id: 'eumetsat-infrared',
    type: SatelliteLayerType.infrared,
    name: 'Infrarot',
    description:
        'Infrarot-Satellitendarstellung zur Analyse von Wolkentemperaturen.',
    sourceName: 'EUMETSAT',
    dataFormat: SatelliteLayerDataFormat.image,
  );

  static const SatelliteLayerDefinition
  eumetsatWaterVapor = SatelliteLayerDefinition(
    id: 'eumetsat-water-vapor',
    type: SatelliteLayerType.waterVapor,
    name: 'Wasserdampf',
    description:
        'Satellitendarstellung der Wasserdampfverteilung in der Atmosphäre.',
    sourceName: 'EUMETSAT',
    dataFormat: SatelliteLayerDataFormat.image,
  );

  static const SatelliteLayerDefinition copernicusVisible =
      SatelliteLayerDefinition(
        id: 'copernicus-visible',
        type: SatelliteLayerType.visibleSatellite,
        name: 'Sichtbares Satellitenbild',
        description:
            'Optische Erdbeobachtungsdaten für Wolken- und Oberflächenanalyse.',
        sourceName: 'Copernicus',
        dataFormat: SatelliteLayerDataFormat.image,
      );

  static const SatelliteLayerDefinition officialWarnings =
      SatelliteLayerDefinition(
        id: 'official-warnings',
        type: SatelliteLayerType.officialWarnings,
        name: 'Amtliche Warnungen',
        description:
            'Amtliche Wetterwarnungen als geografisches Karten-Overlay.',
        sourceName: 'DWD und BBK/MoWaS',
        dataFormat: SatelliteLayerDataFormat.geoJson,
        requiresLegend: true,
      );

  static const SatelliteLayerDefinition orthaRisk = SatelliteLayerDefinition(
    id: 'ortha-risk',
    type: SatelliteLayerType.orthaRisk,
    name: 'ORTHA Risikoanalyse',
    description:
        'Von ORTHA erzeugte Risikobewertung als intelligentes Overlay.',
    sourceName: 'ORTHA Risk Engine',
    dataFormat: SatelliteLayerDataFormat.generatedOverlay,
    requiresLegend: true,
  );

  static const List<SatelliteLayerDefinition> definitions = [
    esriWorldImagery,
    dwdCloudTopHeight,
    dwdThunderstormSeverity,
    eumetsatInfrared,
    eumetsatWaterVapor,
    copernicusVisible,
    officialWarnings,
    orthaRisk,
  ];

  static SatelliteLayerDefinition? findById(String id) {
    for (final definition in definitions) {
      if (definition.id == id) {
        return definition;
      }
    }

    return null;
  }

  static List<SatelliteLayerDefinition> findByType(SatelliteLayerType type) {
    return definitions
        .where((definition) => definition.type == type)
        .toList(growable: false);
  }

  static List<SatelliteLayerState> createInitialStates() {
    return definitions
        .map(
          (definition) => SatelliteLayerState(
            definition: definition,
            availability: definition.id == esriWorldImagery.id
                ? SatelliteLayerAvailability.available
                : SatelliteLayerAvailability.unavailable,
            isVisible: definition.enabledByDefault,
          ),
        )
        .toList(growable: false);
  }
}
