import 'package:flutter/foundation.dart';

import '../models/weather_bounds.dart';
import '../models/weather_frame.dart';

/// Providerneutrale Anfrage an eine Wetterdatenquelle.
@immutable
class WeatherProviderRequest {
  const WeatherProviderRequest({
    required this.layerType,
    this.bounds,
    this.referenceTime,
    this.locale = 'de',
    this.maximumFrameCount,
    this.metadata = const <String, Object?>{},
  }) : assert(locale != '');

  final WeatherLayerType layerType;
  final WeatherBounds? bounds;

  /// Optionaler Bezugszeitpunkt für historische oder prognostische Daten.
  final DateTime? referenceTime;

  final String locale;
  final int? maximumFrameCount;

  /// Erweiterbare Zusatzparameter für providerspezifische Anforderungen.
  final Map<String, Object?> metadata;

  WeatherProviderRequest copyWith({
    WeatherLayerType? layerType,
    WeatherBounds? bounds,
    DateTime? referenceTime,
    String? locale,
    int? maximumFrameCount,
    Map<String, Object?>? metadata,
    bool clearBounds = false,
    bool clearReferenceTime = false,
    bool clearMaximumFrameCount = false,
  }) {
    return WeatherProviderRequest(
      layerType: layerType ?? this.layerType,
      bounds: clearBounds ? null : bounds ?? this.bounds,
      referenceTime: clearReferenceTime
          ? null
          : referenceTime ?? this.referenceTime,
      locale: locale ?? this.locale,
      maximumFrameCount: clearMaximumFrameCount
          ? null
          : maximumFrameCount ?? this.maximumFrameCount,
      metadata: metadata ?? this.metadata,
    );
  }
}
