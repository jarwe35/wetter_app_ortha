import '../models/weather_frame.dart';
import 'weather_frame_renderer.dart';
import 'weather_render_context.dart';
import 'weather_render_result.dart';

/// Kontrollierte Ausführung eines WeatherFrameRenderers.
class WeatherRenderPipeline<TOutput> {
  WeatherRenderPipeline({required this._renderer});

  final WeatherFrameRenderer<TOutput> _renderer;

  bool _isDisposed = false;
  int _generation = 0;

  bool get isDisposed => _isDisposed;

  /// Rendert einen Frame und verwirft Ergebnisse älterer Generationen.
  ///
  /// Das schützt die UI vor verspäteten Antworten, wenn Nutzer schnell
  /// zwischen Frames wechseln.
  Future<WeatherRenderResult<TOutput>?> renderLatest({
    required WeatherFrame frame,
    required WeatherRenderContext context,
  }) async {
    _ensureActive();

    final generation = ++_generation;

    final result = await _renderer.render(frame: frame, context: context);

    if (_isDisposed || generation != _generation) {
      return null;
    }

    return result;
  }

  /// Markiert bereits laufende Renderdurchläufe als überholt.
  void invalidate() {
    _ensureActive();
    _generation++;
  }

  Future<void> dispose() async {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _generation++;
    await _renderer.dispose();
  }

  void _ensureActive() {
    if (_isDisposed) {
      throw StateError('WeatherRenderPipeline wurde bereits beendet.');
    }
  }
}
