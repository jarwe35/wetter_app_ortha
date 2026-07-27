import 'package:flutter/foundation.dart';

import '../models/weather_bounds.dart';

/// Karten- und darstellungsbezogene Informationen für einen Renderdurchlauf.
///
/// Der Kontext enthält bewusst keine Abhängigkeit zu einer bestimmten
/// Kartenbibliothek. Dadurch kann die Weather Engine später beispielsweise
/// mit flutter_map, Google Maps oder einem eigenen Canvas-Renderer arbeiten.
@immutable
class WeatherRenderContext {
  const WeatherRenderContext({
    required this.bounds,
    required this.zoom,
    this.pixelRatio = 1,
    this.opacity = 1,
    this.transitionProgress = 1,
    this.metadata = const <String, Object?>{},
  }) : assert(zoom >= 0),
       assert(pixelRatio > 0),
       assert(opacity >= 0 && opacity <= 1),
       assert(transitionProgress >= 0 && transitionProgress <= 1);

  final WeatherBounds bounds;
  final double zoom;
  final double pixelRatio;
  final double opacity;

  /// Fortschritt eines Übergangs zwischen zwei Frames.
  ///
  /// 0 bedeutet: Übergang hat gerade begonnen.
  /// 1 bedeutet: Ziel-Frame ist vollständig sichtbar.
  final double transitionProgress;

  final Map<String, Object?> metadata;

  WeatherRenderContext copyWith({
    WeatherBounds? bounds,
    double? zoom,
    double? pixelRatio,
    double? opacity,
    double? transitionProgress,
    Map<String, Object?>? metadata,
  }) {
    return WeatherRenderContext(
      bounds: bounds ?? this.bounds,
      zoom: zoom ?? this.zoom,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      opacity: opacity ?? this.opacity,
      transitionProgress: transitionProgress ?? this.transitionProgress,
      metadata: metadata ?? this.metadata,
    );
  }
}
