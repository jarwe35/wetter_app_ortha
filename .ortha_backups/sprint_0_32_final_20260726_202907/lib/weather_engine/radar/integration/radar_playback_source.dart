import 'package:flutter/foundation.dart';

import '../playback/radar_playback_snapshot.dart';

/// Abstrakte Schnittstelle zwischen einer Flutter-Oberfläche und der
/// Radar-Playback-Orchestrierung.
///
/// Dadurch bleibt die Radaroberfläche unabhängig von der konkreten
/// Implementierung der Playback Engine.
abstract interface class RadarPlaybackSource<TOutput> implements Listenable {
  RadarPlaybackSnapshot<TOutput> get snapshot;

  Future<void> initialize();

  Future<void> refresh();

  void dispose();
}
