import '../models/weather_frame.dart';
import 'weather_render_context.dart';
import 'weather_render_result.dart';

/// Abstrakter Renderer für einen Wetterframe.
///
/// [TOutput] beschreibt das spätere Ausgabeformat, beispielsweise:
///
/// - ein Flutter-Widget,
/// - ein ui.Image,
/// - eine Liste vorbereiteter Kartenkacheln,
/// - ein plattformspezifisches Overlay.
abstract interface class WeatherFrameRenderer<TOutput> {
  String get id;

  Future<WeatherRenderResult<TOutput>> render({
    required WeatherFrame frame,
    required WeatherRenderContext context,
  });

  Future<void> dispose();
}
