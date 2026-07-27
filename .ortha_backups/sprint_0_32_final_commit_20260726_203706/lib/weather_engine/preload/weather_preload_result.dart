import 'package:flutter/foundation.dart';

import 'weather_preload_status.dart';

@immutable
class WeatherPreloadResult<T> {
  const WeatherPreloadResult({
    required this.item,
    required this.status,
    this.error,
    this.stackTrace,
  });

  final T item;
  final WeatherPreloadStatus status;
  final Object? error;
  final StackTrace? stackTrace;

  bool get isSuccessful => status == WeatherPreloadStatus.completed;
}
