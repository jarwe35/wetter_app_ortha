import 'package:flutter/foundation.dart';

import 'weather_bounds.dart';

/// Unterstützte Wetterebenen der ORTHA Weather Map Engine Ω.
enum WeatherLayerType {
  radar,
  satellite,
  clouds,
  precipitation,
  wind,
  temperature,
  pollen,
  warnings,
}

/// Aktueller Verarbeitungszustand eines Wetterframes.
enum WeatherFrameState { metadata, loading, ready, failed }

/// Providerneutrales Basismodell eines Wetterframes.
///
/// Ein Frame repräsentiert einen zeitlich definierten Datenstand einer
/// Wetterebene. Die eigentlichen Tile- oder Bilddaten werden getrennt geladen.
@immutable
class WeatherFrame {
  const WeatherFrame({
    required this.id,
    required this.layerType,
    required this.validTime,
    required this.generatedAt,
    required this.providerId,
    required this.state,
    this.bounds,
    this.sourceReference,
    this.errorMessage,
  }) : assert(id != ''),
       assert(providerId != '');

  final String id;
  final WeatherLayerType layerType;

  /// Zeitpunkt, für den die Wetterdaten gültig sind.
  final DateTime validTime;

  /// Zeitpunkt, zu dem der Provider die Daten erzeugt hat.
  final DateTime generatedAt;

  /// Eindeutige Kennung des Datenproviders.
  final String providerId;

  final WeatherFrameState state;
  final WeatherBounds? bounds;

  /// Providerinterne Referenz, beispielsweise URL oder Produktkennung.
  final String? sourceReference;

  final String? errorMessage;

  bool get isReady => state == WeatherFrameState.ready;

  bool get hasError {
    return state == WeatherFrameState.failed ||
        (errorMessage != null && errorMessage!.isNotEmpty);
  }

  WeatherFrame copyWith({
    String? id,
    WeatherLayerType? layerType,
    DateTime? validTime,
    DateTime? generatedAt,
    String? providerId,
    WeatherFrameState? state,
    WeatherBounds? bounds,
    String? sourceReference,
    String? errorMessage,
    bool clearBounds = false,
    bool clearSourceReference = false,
    bool clearErrorMessage = false,
  }) {
    return WeatherFrame(
      id: id ?? this.id,
      layerType: layerType ?? this.layerType,
      validTime: validTime ?? this.validTime,
      generatedAt: generatedAt ?? this.generatedAt,
      providerId: providerId ?? this.providerId,
      state: state ?? this.state,
      bounds: clearBounds ? null : bounds ?? this.bounds,
      sourceReference: clearSourceReference
          ? null
          : sourceReference ?? this.sourceReference,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is WeatherFrame &&
            id == other.id &&
            layerType == other.layerType &&
            validTime == other.validTime &&
            generatedAt == other.generatedAt &&
            providerId == other.providerId &&
            state == other.state &&
            bounds == other.bounds &&
            sourceReference == other.sourceReference &&
            errorMessage == other.errorMessage;
  }

  @override
  int get hashCode => Object.hash(
    id,
    layerType,
    validTime,
    generatedAt,
    providerId,
    state,
    bounds,
    sourceReference,
    errorMessage,
  );

  @override
  String toString() {
    return 'WeatherFrame('
        'id: $id, '
        'layerType: ${layerType.name}, '
        'validTime: $validTime, '
        'providerId: $providerId, '
        'state: ${state.name}'
        ')';
  }
}
