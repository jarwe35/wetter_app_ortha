/// Gesamtzustand der Radar-Frame-Orchestrierung.
enum RadarPlaybackStatus {
  idle,
  loadingTimeline,
  ready,
  preloading,
  rendering,
  playing,
  paused,
  completed,
  failed,
  disposed,
}
