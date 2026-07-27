import 'dart:async';
import 'dart:collection';

import 'weather_preload_result.dart';
import 'weather_preload_status.dart';

typedef WeatherPreloadOperation<T> = Future<void> Function(T item);

/// Sequenzielle Preload-Queue für Wetterframes oder Wetterkacheln.
///
/// Eine sequenzielle Verarbeitung verhindert, dass zu viele Netzwerk-,
/// Decoding- oder GPU-Aufgaben gleichzeitig gestartet werden.
class WeatherPreloadQueue<T> {
  WeatherPreloadQueue({required this._operation});

  final WeatherPreloadOperation<T> _operation;
  final Queue<T> _pending = Queue<T>();
  final Set<T> _knownItems = <T>{};

  bool _isProcessing = false;
  bool _isCancelled = false;

  bool get isProcessing => _isProcessing;

  int get pendingCount => _pending.length;

  bool get isCancelled => _isCancelled;

  void add(T item) {
    if (_isCancelled || _knownItems.contains(item)) {
      return;
    }

    _knownItems.add(item);
    _pending.add(item);
  }

  void addAll(Iterable<T> items) {
    for (final item in items) {
      add(item);
    }
  }

  Future<List<WeatherPreloadResult<T>>> process() async {
    if (_isProcessing) {
      throw StateError('Die WeatherPreloadQueue wird bereits verarbeitet.');
    }

    _isProcessing = true;
    final results = <WeatherPreloadResult<T>>[];

    try {
      while (_pending.isNotEmpty) {
        final item = _pending.removeFirst();

        if (_isCancelled) {
          results.add(
            WeatherPreloadResult<T>(
              item: item,
              status: WeatherPreloadStatus.cancelled,
            ),
          );
          continue;
        }

        try {
          await _operation(item);

          results.add(
            WeatherPreloadResult<T>(
              item: item,
              status: WeatherPreloadStatus.completed,
            ),
          );
        } catch (error, stackTrace) {
          results.add(
            WeatherPreloadResult<T>(
              item: item,
              status: WeatherPreloadStatus.failed,
              error: error,
              stackTrace: stackTrace,
            ),
          );
        }
      }
    } finally {
      _isProcessing = false;
      _knownItems.clear();
    }

    return List<WeatherPreloadResult<T>>.unmodifiable(results);
  }

  void cancel() {
    _isCancelled = true;
  }

  void reset() {
    if (_isProcessing) {
      throw StateError(
        'Eine laufende WeatherPreloadQueue kann nicht zurückgesetzt werden.',
      );
    }

    _pending.clear();
    _knownItems.clear();
    _isCancelled = false;
  }
}
