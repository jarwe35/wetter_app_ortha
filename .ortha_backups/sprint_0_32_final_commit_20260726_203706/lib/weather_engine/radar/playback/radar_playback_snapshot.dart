import 'package:flutter/foundation.dart';

import '../../models/weather_frame.dart';
import 'radar_playback_status.dart';

/// Unveränderlicher Zustandsabzug der Radar-Wiedergabe.
@immutable
class RadarPlaybackSnapshot<TOutput> {
  const RadarPlaybackSnapshot({
    required this.status,
    this.frames = const <WeatherFrame>[],
    this.currentIndex = 0,
    this.currentOutput,
    this.error,
    this.stackTrace,
    this.isPreloading = false,
    this.preloadedFrameCount = 0,
  });

  final RadarPlaybackStatus status;
  final List<WeatherFrame> frames;
  final int currentIndex;
  final TOutput? currentOutput;
  final Object? error;
  final StackTrace? stackTrace;
  final bool isPreloading;
  final int preloadedFrameCount;

  bool get hasFrames => frames.isNotEmpty;

  bool get hasError => error != null;

  WeatherFrame? get currentFrame {
    if (frames.isEmpty) {
      return null;
    }

    final safeIndex = currentIndex.clamp(0, frames.length - 1);

    return frames[safeIndex];
  }

  RadarPlaybackSnapshot<TOutput> copyWith({
    RadarPlaybackStatus? status,
    List<WeatherFrame>? frames,
    int? currentIndex,
    TOutput? currentOutput,
    bool clearCurrentOutput = false,
    Object? error,
    StackTrace? stackTrace,
    bool clearError = false,
    bool? isPreloading,
    int? preloadedFrameCount,
  }) {
    return RadarPlaybackSnapshot<TOutput>(
      status: status ?? this.status,
      frames: frames ?? this.frames,
      currentIndex: currentIndex ?? this.currentIndex,
      currentOutput: clearCurrentOutput
          ? null
          : currentOutput ?? this.currentOutput,
      error: clearError ? null : error ?? this.error,
      stackTrace: clearError ? null : stackTrace ?? this.stackTrace,
      isPreloading: isPreloading ?? this.isPreloading,
      preloadedFrameCount: preloadedFrameCount ?? this.preloadedFrameCount,
    );
  }
}
