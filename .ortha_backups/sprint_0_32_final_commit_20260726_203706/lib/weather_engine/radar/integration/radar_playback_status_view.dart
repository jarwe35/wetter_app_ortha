import 'package:flutter/material.dart';

import '../playback/radar_playback_snapshot.dart';
import '../playback/radar_playback_status.dart';
import 'radar_playback_view_controller.dart';

typedef RadarPlaybackContentBuilder<TOutput> =
    Widget Function(
      BuildContext context,
      TOutput output,
      RadarPlaybackSnapshot<TOutput> snapshot,
    );

/// Standardisierte Statusdarstellung für Radar-Playback-Snapshots.
///
/// Dieses Widget ist bewusst visuell neutral gehalten. Die bestehende
/// Radaroberfläche kann Farben, Kartenlayout und Bedienelemente weiterhin
/// vollständig selbst definieren.
class RadarPlaybackStatusView<TOutput> extends StatelessWidget {
  const RadarPlaybackStatusView({
    required this.snapshot,
    required this.controller,
    required this.contentBuilder,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    super.key,
  });

  final RadarPlaybackSnapshot<TOutput> snapshot;
  final RadarPlaybackViewController<TOutput> controller;
  final RadarPlaybackContentBuilder<TOutput> contentBuilder;

  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;

  final Widget Function(
    BuildContext context,
    Object error,
    Future<void> Function() retry,
  )?
  errorBuilder;

  @override
  Widget build(BuildContext context) {
    final output = snapshot.currentOutput;

    if (output != null) {
      return contentBuilder(context, output, snapshot);
    }

    switch (snapshot.status) {
      case RadarPlaybackStatus.idle:
      case RadarPlaybackStatus.loadingTimeline:
      case RadarPlaybackStatus.preloading:
      case RadarPlaybackStatus.rendering:
        return loadingBuilder?.call(context) ??
            const Center(child: CircularProgressIndicator());

      case RadarPlaybackStatus.failed:
        final error = snapshot.error;

        if (error != null && errorBuilder != null) {
          return errorBuilder!(context, error, controller.refresh);
        }

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Radardaten konnten nicht geladen werden.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: controller.refresh,
                icon: const Icon(Icons.refresh),
                label: const Text('Erneut laden'),
              ),
            ],
          ),
        );

      case RadarPlaybackStatus.ready:
      case RadarPlaybackStatus.playing:
      case RadarPlaybackStatus.paused:
      case RadarPlaybackStatus.completed:
        return emptyBuilder?.call(context) ??
            const Center(child: Text('Noch kein Radarbild verfügbar.'));

      case RadarPlaybackStatus.disposed:
        return emptyBuilder?.call(context) ?? const SizedBox.shrink();
    }
  }
}
