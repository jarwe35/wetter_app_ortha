import '../models/weather_frame.dart';
import '../models/weather_timeline.dart';
import '../providers/weather_provider.dart';
import '../providers/weather_provider_request.dart';
import 'radar_provider_request.dart';

/// Spezialisierter Providervertrag für Radarprodukte.
abstract interface class RadarProvider implements WeatherProvider {
  Future<WeatherTimeline> loadRadarTimeline(RadarProviderRequest request);

  @override
  bool supports(WeatherProviderRequest request) {
    return request.layerType == WeatherLayerType.radar;
  }

  @override
  Future<WeatherTimeline> loadTimeline(WeatherProviderRequest request) {
    if (!supports(request)) {
      throw UnsupportedError(
        'RadarProvider "$id" unterstützt die Ebene '
        '"${request.layerType.name}" nicht.',
      );
    }

    return loadRadarTimeline(
      RadarProviderRequest(
        bounds: request.bounds,
        referenceTime: request.referenceTime,
        locale: request.locale,
        maximumFrameCount: request.maximumFrameCount,
        includeForecastFrames:
            request.metadata['includeForecastFrames'] as bool? ?? true,
        includeHistoricalFrames:
            request.metadata['includeHistoricalFrames'] as bool? ?? true,
        metadata: request.metadata,
      ),
    );
  }
}
