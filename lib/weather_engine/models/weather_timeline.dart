import 'package:flutter/foundation.dart';

import 'weather_frame.dart';

/// Chronologisch sortierte Abfolge von Wetterframes.
@immutable
class WeatherTimeline {
  WeatherTimeline({required List<WeatherFrame> frames, this.initialFrameId})
    : frames = List.unmodifiable(
        [...frames]
          ..sort((left, right) => left.validTime.compareTo(right.validTime)),
      ) {
    final frameIds = this.frames.map((frame) => frame.id).toSet();

    if (frameIds.length != this.frames.length) {
      throw ArgumentError(
        'Frame-IDs innerhalb einer Timeline müssen eindeutig sein.',
      );
    }

    if (initialFrameId != null && !frameIds.contains(initialFrameId)) {
      throw ArgumentError(
        'Der Initialframe "$initialFrameId" ist nicht in der Timeline enthalten.',
      );
    }
  }

  final List<WeatherFrame> frames;
  final String? initialFrameId;

  bool get isEmpty => frames.isEmpty;
  bool get isNotEmpty => frames.isNotEmpty;
  int get length => frames.length;

  /// Initialer Frame der Timeline.
  ///
  /// Ohne explizite Vorgabe wird der neueste Frame verwendet.
  WeatherFrame? get initialFrame {
    if (frames.isEmpty) {
      return null;
    }

    final requestedFrameId = initialFrameId;

    if (requestedFrameId == null) {
      return frames.last;
    }

    return frameById(requestedFrameId);
  }

  WeatherFrame? frameById(String id) {
    for (final frame in frames) {
      if (frame.id == id) {
        return frame;
      }
    }

    return null;
  }

  int indexOfFrame(String id) {
    return frames.indexWhere((frame) => frame.id == id);
  }

  WeatherFrame? previousOf(String id) {
    final index = indexOfFrame(id);

    if (index <= 0) {
      return null;
    }

    return frames[index - 1];
  }

  WeatherFrame? nextOf(String id) {
    final index = indexOfFrame(id);

    if (index < 0 || index >= frames.length - 1) {
      return null;
    }

    return frames[index + 1];
  }

  /// Liefert den zeitlich nächstgelegenen Frame.
  WeatherFrame? closestTo(DateTime time) {
    if (frames.isEmpty) {
      return null;
    }

    WeatherFrame closestFrame = frames.first;
    Duration smallestDifference = closestFrame.validTime.difference(time).abs();

    for (final frame in frames.skip(1)) {
      final difference = frame.validTime.difference(time).abs();

      if (difference < smallestDifference) {
        closestFrame = frame;
        smallestDifference = difference;
      }
    }

    return closestFrame;
  }
}
