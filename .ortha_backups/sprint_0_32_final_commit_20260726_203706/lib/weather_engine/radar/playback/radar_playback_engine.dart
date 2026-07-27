import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../animation/weather_animation_controller.dart';
import '../../animation/weather_animation_state.dart';
import '../../models/weather_frame.dart';
import '../../preload/weather_preload_queue.dart';
import '../../renderer/weather_render_pipeline.dart';
import 'radar_playback_callbacks.dart';
import 'radar_playback_snapshot.dart';
import 'radar_playback_status.dart';
import 'radar_preload_planner.dart';

/// Providerneutrale Orchestrierung der Radar-Wiedergabe.
///
/// Die Engine verbindet:
///
/// - Timeline-Laden,
/// - Frameanimation,
/// - vorausschauendes Preloading,
/// - Render-Pipeline,
/// - Schutz vor veralteten asynchronen Ergebnissen.
///
/// Die bestehende Kartenoberfläche wird dadurch noch nicht verändert.
class RadarPlaybackEngine<TOutput> extends ChangeNotifier {
  factory RadarPlaybackEngine({
    required RadarTimelineLoader timelineLoader,
    required RadarFramePreloader framePreloader,
    required RadarRenderContextBuilder renderContextBuilder,
    required WeatherRenderPipeline<TOutput> renderPipeline,
    WeatherAnimationController<WeatherFrame>? animationController,
    RadarPreloadPlanner<WeatherFrame> preloadPlanner =
        const RadarPreloadPlanner<WeatherFrame>(),
  }) {
    return RadarPlaybackEngine<TOutput>._(
      timelineLoader: timelineLoader,
      framePreloader: framePreloader,
      renderContextBuilder: renderContextBuilder,
      renderPipeline: renderPipeline,
      animationController:
          animationController ?? WeatherAnimationController<WeatherFrame>(),
      preloadPlanner: preloadPlanner,
    );
  }

  RadarPlaybackEngine._({
    required this._timelineLoader,
    required this._framePreloader,
    required this._renderContextBuilder,
    required this._renderPipeline,
    required this._animationController,
    required this._preloadPlanner,
  }) {
    _animationController.addListener(_handleAnimationChanged);
  }

  final RadarTimelineLoader _timelineLoader;
  final RadarFramePreloader _framePreloader;
  final RadarRenderContextBuilder _renderContextBuilder;
  final WeatherRenderPipeline<TOutput> _renderPipeline;
  final WeatherAnimationController<WeatherFrame> _animationController;
  final RadarPreloadPlanner<WeatherFrame> _preloadPlanner;

  RadarPlaybackSnapshot<TOutput> _snapshot = RadarPlaybackSnapshot<TOutput>(
    status: RadarPlaybackStatus.idle,
  );

  bool _disposed = false;
  bool _ownsAsyncOperation = false;
  int _operationGeneration = 0;
  int _lastHandledAnimationIndex = -1;

  RadarPlaybackSnapshot<TOutput> get snapshot => _snapshot;

  WeatherAnimationController<WeatherFrame> get animationController =>
      _animationController;

  bool get isDisposed => _disposed;

  Future<void> initialize() async {
    _ensureActive();
    await refreshTimeline();
  }

  Future<void> refreshTimeline() async {
    _ensureActive();

    final generation = ++_operationGeneration;

    _updateSnapshot(
      _snapshot.copyWith(
        status: RadarPlaybackStatus.loadingTimeline,
        clearError: true,
        clearCurrentOutput: true,
        isPreloading: false,
        preloadedFrameCount: 0,
      ),
    );

    try {
      final loadedFrames = await _timelineLoader();

      if (!_isCurrentGeneration(generation)) {
        return;
      }

      final frames = List<WeatherFrame>.unmodifiable(loadedFrames);

      _animationController.replaceFrames(frames, preserveCurrentFrame: true);

      _lastHandledAnimationIndex = _animationController.currentIndex;

      _updateSnapshot(
        _snapshot.copyWith(
          status: RadarPlaybackStatus.ready,
          frames: frames,
          currentIndex: _animationController.currentIndex,
          clearError: true,
          clearCurrentOutput: true,
        ),
      );

      if (frames.isEmpty) {
        return;
      }

      await _renderCurrentFrame(expectedGeneration: generation);

      if (!_isCurrentGeneration(generation)) {
        return;
      }

      unawaited(_preloadAroundCurrentFrame(expectedGeneration: generation));
    } catch (error, stackTrace) {
      if (!_isCurrentGeneration(generation)) {
        return;
      }

      _updateSnapshot(
        _snapshot.copyWith(
          status: RadarPlaybackStatus.failed,
          error: error,
          stackTrace: stackTrace,
          isPreloading: false,
        ),
      );
    }
  }

  void play() {
    _ensureActive();

    if (!_snapshot.hasFrames) {
      return;
    }

    _animationController.play();

    _updateSnapshot(_snapshot.copyWith(status: RadarPlaybackStatus.playing));
  }

  void pause() {
    _ensureActive();

    _animationController.pause();

    _updateSnapshot(_snapshot.copyWith(status: RadarPlaybackStatus.paused));
  }

  void stop() {
    _ensureActive();

    _animationController.stop();

    _updateSnapshot(
      _snapshot.copyWith(
        status: RadarPlaybackStatus.ready,
        currentIndex: _animationController.currentIndex,
      ),
    );
  }

  void seekTo(int index) {
    _ensureActive();
    _animationController.seekTo(index);
  }

  void next() {
    _ensureActive();
    _animationController.next();
  }

  void previous() {
    _ensureActive();
    _animationController.previous();
  }

  Future<void> renderCurrentFrame() async {
    _ensureActive();

    final generation = ++_operationGeneration;

    await _renderCurrentFrame(expectedGeneration: generation);

    if (_isCurrentGeneration(generation)) {
      unawaited(_preloadAroundCurrentFrame(expectedGeneration: generation));
    }
  }

  Future<void> _renderCurrentFrame({required int expectedGeneration}) async {
    final frame = _animationController.currentFrame;

    if (frame == null) {
      return;
    }

    final statusBeforeRender = _snapshot.status;

    _updateSnapshot(
      _snapshot.copyWith(
        status: RadarPlaybackStatus.rendering,
        currentIndex: _animationController.currentIndex,
        clearError: true,
      ),
    );

    try {
      final context = _renderContextBuilder(frame);

      final result = await _renderPipeline.renderLatest(
        frame: frame,
        context: context,
      );

      if (!_isCurrentGeneration(expectedGeneration) || result == null) {
        return;
      }

      if (result.hasFailed) {
        _updateSnapshot(
          _snapshot.copyWith(
            status: RadarPlaybackStatus.failed,
            error: result.error,
            stackTrace: result.stackTrace,
          ),
        );
        return;
      }

      _updateSnapshot(
        _snapshot.copyWith(
          status: _resolvePostRenderStatus(statusBeforeRender),
          currentIndex: _animationController.currentIndex,
          currentOutput: result.output,
          clearError: true,
        ),
      );
    } catch (error, stackTrace) {
      if (!_isCurrentGeneration(expectedGeneration)) {
        return;
      }

      _updateSnapshot(
        _snapshot.copyWith(
          status: RadarPlaybackStatus.failed,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _preloadAroundCurrentFrame({
    required int expectedGeneration,
  }) async {
    if (_ownsAsyncOperation || !_isCurrentGeneration(expectedGeneration)) {
      return;
    }

    final frames = _snapshot.frames;

    if (frames.isEmpty) {
      return;
    }

    final plan = _preloadPlanner.createPlan(
      frames: frames,
      currentIndex: _animationController.currentIndex,
    );

    if (plan.isEmpty) {
      return;
    }

    _ownsAsyncOperation = true;

    final statusBeforePreload = _snapshot.status;

    _updateSnapshot(
      _snapshot.copyWith(
        status: statusBeforePreload == RadarPlaybackStatus.playing
            ? RadarPlaybackStatus.playing
            : RadarPlaybackStatus.preloading,
        isPreloading: true,
        preloadedFrameCount: 0,
      ),
    );

    final queue = WeatherPreloadQueue<WeatherFrame>(operation: _framePreloader);

    queue.addAll(plan);

    try {
      final results = await queue.process();

      if (!_isCurrentGeneration(expectedGeneration)) {
        return;
      }

      final successfulCount = results
          .where((result) => result.isSuccessful)
          .length;

      _updateSnapshot(
        _snapshot.copyWith(
          status: _resolvePostPreloadStatus(statusBeforePreload),
          isPreloading: false,
          preloadedFrameCount: successfulCount,
        ),
      );
    } finally {
      _ownsAsyncOperation = false;
    }
  }

  void _handleAnimationChanged() {
    if (_disposed) {
      return;
    }

    final currentIndex = _animationController.currentIndex;

    final animationState = _animationController.state;

    if (animationState == WeatherAnimationState.completed) {
      _updateSnapshot(
        _snapshot.copyWith(
          status: RadarPlaybackStatus.completed,
          currentIndex: currentIndex,
        ),
      );
    } else if (animationState == WeatherAnimationState.playing) {
      _updateSnapshot(
        _snapshot.copyWith(
          status: RadarPlaybackStatus.playing,
          currentIndex: currentIndex,
        ),
      );
    } else if (animationState == WeatherAnimationState.paused) {
      _updateSnapshot(
        _snapshot.copyWith(
          status: RadarPlaybackStatus.paused,
          currentIndex: currentIndex,
        ),
      );
    }

    if (_lastHandledAnimationIndex == currentIndex) {
      return;
    }

    _lastHandledAnimationIndex = currentIndex;

    final generation = ++_operationGeneration;

    unawaited(
      _renderCurrentFrame(expectedGeneration: generation).then((_) {
        if (_isCurrentGeneration(generation)) {
          return _preloadAroundCurrentFrame(expectedGeneration: generation);
        }
      }),
    );
  }

  RadarPlaybackStatus _resolvePostRenderStatus(
    RadarPlaybackStatus previousStatus,
  ) {
    if (_animationController.state == WeatherAnimationState.playing) {
      return RadarPlaybackStatus.playing;
    }

    if (_animationController.state == WeatherAnimationState.paused) {
      return RadarPlaybackStatus.paused;
    }

    if (_animationController.state == WeatherAnimationState.completed) {
      return RadarPlaybackStatus.completed;
    }

    if (previousStatus == RadarPlaybackStatus.preloading) {
      return RadarPlaybackStatus.preloading;
    }

    return RadarPlaybackStatus.ready;
  }

  RadarPlaybackStatus _resolvePostPreloadStatus(
    RadarPlaybackStatus previousStatus,
  ) {
    if (_animationController.state == WeatherAnimationState.playing) {
      return RadarPlaybackStatus.playing;
    }

    if (_animationController.state == WeatherAnimationState.paused) {
      return RadarPlaybackStatus.paused;
    }

    if (_animationController.state == WeatherAnimationState.completed) {
      return RadarPlaybackStatus.completed;
    }

    if (previousStatus == RadarPlaybackStatus.rendering) {
      return RadarPlaybackStatus.rendering;
    }

    return RadarPlaybackStatus.ready;
  }

  bool _isCurrentGeneration(int generation) {
    return !_disposed && generation == _operationGeneration;
  }

  void _updateSnapshot(RadarPlaybackSnapshot<TOutput> next) {
    if (_disposed) {
      return;
    }

    _snapshot = next;
    notifyListeners();
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('RadarPlaybackEngine wurde bereits beendet.');
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _operationGeneration++;

    _animationController.removeListener(_handleAnimationChanged);
    _animationController.dispose();

    unawaited(_renderPipeline.dispose());

    _snapshot = _snapshot.copyWith(
      status: RadarPlaybackStatus.disposed,
      isPreloading: false,
    );

    super.dispose();
  }
}
