import 'package:flutter/foundation.dart';

import '../playback/radar_playback_engine.dart';
import '../playback/radar_playback_snapshot.dart';

import 'radar_playback_source.dart';

/// Stabile Verbindung zwischen der Radaroberfläche und der
/// [RadarPlaybackEngine].
///
/// Die Oberfläche muss dadurch nicht direkt die interne Orchestrierung der
/// Playback Engine kennen. Sie kann ausschließlich auf den aktuellen Snapshot
/// reagieren und Initialisierungs- beziehungsweise Aktualisierungsbefehle
/// auslösen.
///
/// In Block 5.1 wird die bestehende Radaroberfläche noch nicht verändert.
class RadarPlaybackBinding<TOutput> extends ChangeNotifier
    implements RadarPlaybackSource<TOutput> {
  RadarPlaybackBinding({required this._engine, this.disposeEngine = false}) {
    _engine.addListener(_handleEngineChanged);
  }

  final RadarPlaybackEngine<TOutput> _engine;

  /// Legt fest, ob die Binding-Instanz beim eigenen Dispose auch die
  /// zugehörige Playback Engine freigibt.
  ///
  /// Standardmäßig bleibt die Engine im Besitz des aufrufenden Controllers.
  final bool disposeEngine;

  bool _disposed = false;

  RadarPlaybackEngine<TOutput> get engine => _engine;

  @override
  RadarPlaybackSnapshot<TOutput> get snapshot => _engine.snapshot;

  bool get isDisposed => _disposed;

  /// Lädt die Radar-Timeline und stellt den ersten verfügbaren Frame bereit.
  @override
  Future<void> initialize() {
    _ensureActive();
    return _engine.initialize();
  }

  /// Lädt die Timeline neu, ohne dass die Oberfläche die Provider- oder
  /// Render-Pipeline direkt kennen muss.
  @override
  Future<void> refresh() {
    _ensureActive();
    return _engine.refreshTimeline();
  }

  void _handleEngineChanged() {
    if (_disposed) {
      return;
    }

    notifyListeners();
  }

  void _ensureActive() {
    if (_disposed) {
      throw StateError('RadarPlaybackBinding wurde bereits freigegeben.');
    }
  }

  @override
  void dispose() {
    if (_disposed) {
      return;
    }

    _disposed = true;
    _engine.removeListener(_handleEngineChanged);

    if (disposeEngine) {
      _engine.dispose();
    }

    super.dispose();
  }
}
