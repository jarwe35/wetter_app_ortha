import '../../models/weather_frame.dart';
import '../../renderer/weather_render_context.dart';

/// Lädt eine sortierte Liste verfügbarer Radarframes.
typedef RadarTimelineLoader = Future<List<WeatherFrame>> Function();

/// Lädt beziehungsweise decodiert einen Radarframe vorab.
///
/// Die konkrete Implementierung kann dabei Provider, Cache und Netzwerk
/// kombinieren.
typedef RadarFramePreloader = Future<void> Function(WeatherFrame frame);

/// Erstellt den Renderkontext für den aktuell gewählten Frame.
typedef RadarRenderContextBuilder =
    WeatherRenderContext Function(WeatherFrame frame);
