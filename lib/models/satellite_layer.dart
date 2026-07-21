enum SatelliteLayerType {
  baseMap,
  visibleSatellite,
  infrared,
  waterVapor,
  cloudTopHeight,
  thunderstormSeverity,
  radar,
  officialWarnings,
  orthaRisk,
}

enum SatelliteLayerDataFormat {
  tile,
  image,
  netCdf,
  hdf5,
  geoJson,
  generatedOverlay,
}

enum SatelliteLayerAvailability { available, loading, unavailable, error }

class SatelliteLayerDefinition {
  final String id;
  final SatelliteLayerType type;
  final String name;
  final String description;
  final String sourceName;
  final SatelliteLayerDataFormat dataFormat;
  final bool enabledByDefault;
  final bool requiresLegend;
  final bool requiresTimestamp;

  const SatelliteLayerDefinition({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.sourceName,
    required this.dataFormat,
    this.enabledByDefault = false,
    this.requiresLegend = false,
    this.requiresTimestamp = true,
  });

  SatelliteLayerDefinition copyWith({
    String? id,
    SatelliteLayerType? type,
    String? name,
    String? description,
    String? sourceName,
    SatelliteLayerDataFormat? dataFormat,
    bool? enabledByDefault,
    bool? requiresLegend,
    bool? requiresTimestamp,
  }) {
    return SatelliteLayerDefinition(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      sourceName: sourceName ?? this.sourceName,
      dataFormat: dataFormat ?? this.dataFormat,
      enabledByDefault: enabledByDefault ?? this.enabledByDefault,
      requiresLegend: requiresLegend ?? this.requiresLegend,
      requiresTimestamp: requiresTimestamp ?? this.requiresTimestamp,
    );
  }
}

class SatelliteLayerState {
  final SatelliteLayerDefinition definition;
  final SatelliteLayerAvailability availability;
  final bool isVisible;
  final DateTime? observationTimeUtc;
  final DateTime? lastUpdatedUtc;
  final String? statusMessage;

  const SatelliteLayerState({
    required this.definition,
    this.availability = SatelliteLayerAvailability.unavailable,
    this.isVisible = false,
    this.observationTimeUtc,
    this.lastUpdatedUtc,
    this.statusMessage,
  });

  SatelliteLayerState copyWith({
    SatelliteLayerDefinition? definition,
    SatelliteLayerAvailability? availability,
    bool? isVisible,
    DateTime? observationTimeUtc,
    DateTime? lastUpdatedUtc,
    String? statusMessage,
    bool clearObservationTime = false,
    bool clearLastUpdated = false,
    bool clearStatusMessage = false,
  }) {
    return SatelliteLayerState(
      definition: definition ?? this.definition,
      availability: availability ?? this.availability,
      isVisible: isVisible ?? this.isVisible,
      observationTimeUtc: clearObservationTime
          ? null
          : observationTimeUtc ?? this.observationTimeUtc,
      lastUpdatedUtc: clearLastUpdated
          ? null
          : lastUpdatedUtc ?? this.lastUpdatedUtc,
      statusMessage: clearStatusMessage
          ? null
          : statusMessage ?? this.statusMessage,
    );
  }
}
