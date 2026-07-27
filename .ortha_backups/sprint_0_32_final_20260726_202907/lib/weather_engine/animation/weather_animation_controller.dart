import 'dart:async';

import 'package:flutter/foundation.dart';

import 'weather_animation_state.dart';

/// Generischer Controller für zeitbasierte Framefolgen.
///
/// Der Controller ist absichtlich generisch. Dadurch kann seine Logik ohne
/// Abhängigkeit von konkreten Wettermodellen getestet und später sowohl für
/// Radar-, Satelliten- als auch Prognoseframes verwendet werden.
class WeatherAnimationController<T> extends ChangeNotifier {
  WeatherAnimationController({
    List<T>? frames,
    this.frameDuration = const Duration(milliseconds: 500),
    this.loop = true,
  }) : assert(frameDuration > Duration.zero),
       _frames = List<T>.unmodifiable(frames ?? <T>[]);

  List<T> _frames;
  Duration frameDuration;
  bool loop;

  Timer? _timer;
  int _currentIndex = 0;
  WeatherAnimationState _state = WeatherAnimationState.stopped;
  bool _disposed = false;

  List<T> get frames => _frames;

  int get frameCount => _frames.length;

  int get currentIndex => _currentIndex;

  WeatherAnimationState get state => _state;

  bool get isPlaying => _state == WeatherAnimationState.playing;

  bool get hasFrames => _frames.isNotEmpty;

  T? get currentFrame {
    if (_frames.isEmpty) {
      return null;
    }

    return _frames[_currentIndex];
  }

  void replaceFrames(List<T> frames, {bool preserveCurrentFrame = true}) {
    _ensureActive();

    final previousFrame = currentFrame;
    _frames = List<T>.unmodifiable(frames);

    if (_frames.isEmpty) {
      _currentIndex = 0;
      stop();
      return;
    }

    if (preserveCurrentFrame && previousFrame != null) {
      final preservedIndex = _frames.indexOf(previousFrame);

      if (preservedIndex >= 0) {
        _currentIndex = preservedIndex;
      } else {
        _currentIndex = _currentIndex.clamp(0, _frames.length - 1);
      }
    } else {
      _currentIndex = 0;
    }

    notifyListeners();
  }

  void play() {
    _ensureActive();

    if (_frames.length <= 1) {
      return;
    }

    if (_state == WeatherAnimationState.completed && !loop) {
      _currentIndex = 0;
    }

    _state = WeatherAnimationState.playing;
    _restartTimer();
    notifyListeners();
  }

  void pause() {
    _ensureActive();

    if (_state != WeatherAnimationState.playing) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _state = WeatherAnimationState.paused;
    notifyListeners();
  }

  void stop() {
    _ensureActive();

    _timer?.cancel();
    _timer = null;
    _currentIndex = 0;
    _state = WeatherAnimationState.stopped;
    notifyListeners();
  }

  void seekTo(int index) {
    _ensureActive();

    if (_frames.isEmpty) {
      _currentIndex = 0;
      return;
    }

    if (index < 0 || index >= _frames.length) {
      throw RangeError.range(index, 0, _frames.length - 1, 'index');
    }

    if (_currentIndex == index) {
      return;
    }

    _currentIndex = index;
    notifyListeners();
  }

  void next() {
    _ensureActive();
    _advance(forward: true);
  }

  void previous() {
    _ensureActive();
    _advance(forward: false);
  }

  void updateFrameDuration(Duration duration) {
    _ensureActive();

    if (duration <= Duration.zero) {
      throw ArgumentError.value(
        duration,
        'duration',
        'Die Framedauer muss größer als null sein.',
      );
    }

    frameDuration = duration;

    if (isPlaying) {
      _restartTimer();
    }

    notifyListeners();
  }

  void _advance({required bool forward}) {
    if (_frames.isEmpty) {
      return;
    }

    if (_frames.length == 1) {
      _currentIndex = 0;
      notifyListeners();
      return;
    }

    if (forward) {
      if (_currentIndex < _frames.length - 1) {
        _currentIndex++;
      } else if (loop) {
        _currentIndex = 0;
      } else {
        _timer?.cancel();
        _timer = null;
        _state = WeatherAnimationState.completed;
      }
    } else {
      if (_currentIndex > 0) {
        _currentIndex--;
      } else if (loop) {
        _currentIndex = _frames.length - 1;
      }
    }

    notifyListeners();
  }

  void _restartTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(frameDuration, (_) => _advance(forward: true));
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('WeatherAnimationController wurde bereits beendet.');
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _timer?.cancel();
    _timer = null;
    _disposed = true;
    super.dispose();
  }
}
