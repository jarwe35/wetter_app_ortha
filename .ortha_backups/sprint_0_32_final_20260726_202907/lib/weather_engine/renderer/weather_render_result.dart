import 'package:flutter/foundation.dart';

import 'weather_render_status.dart';

/// Ergebnis eines provider- und UI-unabhängigen Renderdurchlaufs.
@immutable
class WeatherRenderResult<T> {
  const WeatherRenderResult({
    required this.status,
    this.output,
    this.error,
    this.stackTrace,
    this.renderDuration = Duration.zero,
    this.metadata = const <String, Object?>{},
  });

  final WeatherRenderStatus status;
  final T? output;
  final Object? error;
  final StackTrace? stackTrace;
  final Duration renderDuration;
  final Map<String, Object?> metadata;

  bool get isSuccessful {
    return status == WeatherRenderStatus.completed && error == null;
  }

  bool get hasFailed {
    return status == WeatherRenderStatus.failed || error != null;
  }

  factory WeatherRenderResult.completed({
    required T output,
    required Duration renderDuration,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return WeatherRenderResult<T>(
      status: WeatherRenderStatus.completed,
      output: output,
      renderDuration: renderDuration,
      metadata: metadata,
    );
  }

  factory WeatherRenderResult.failed({
    required Object error,
    StackTrace? stackTrace,
    Duration renderDuration = Duration.zero,
    Map<String, Object?> metadata = const <String, Object?>{},
  }) {
    return WeatherRenderResult<T>(
      status: WeatherRenderStatus.failed,
      error: error,
      stackTrace: stackTrace,
      renderDuration: renderDuration,
      metadata: metadata,
    );
  }
}
