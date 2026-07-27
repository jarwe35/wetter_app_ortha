import 'package:flutter/foundation.dart';

import '../models/weather_bounds.dart';
import '../models/weather_frame.dart';
import '../providers/weather_provider_request.dart';

/// Spezialisierte Anfrage an einen Radarprovider.
@immutable
class RadarProviderRequest {
  const RadarProviderRequest({
    this.bounds,
    this.referenceTime,
    this.locale = 'de',
    this.maximumFrameCount,
    this.includeForecastFrames = true,
    this.includeHistoricalFrames = true,
    this.metadata = const <String, Object?>{},
  }) : assert(locale != '');

  final WeatherBounds? bounds;
  final DateTime? referenceTime;
  final String locale;
  final int? maximumFrameCount;
  final bool includeForecastFrames;
  final bool includeHistoricalFrames;
  final Map<String, Object?> metadata;

  WeatherProviderRequest toWeatherProviderRequest() {
    return WeatherProviderRequest(
      layerType: WeatherLayerType.radar,
      bounds: bounds,
      referenceTime: referenceTime,
      locale: locale,
      maximumFrameCount: maximumFrameCount,
      metadata: <String, Object?>{
        ...metadata,
        'includeForecastFrames': includeForecastFrames,
        'includeHistoricalFrames': includeHistoricalFrames,
      },
    );
  }
}
