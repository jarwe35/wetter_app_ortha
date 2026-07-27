import 'package:flutter/widgets.dart';

import '../playback/radar_playback_snapshot.dart';
import 'radar_playback_view_controller.dart';

typedef RadarPlaybackViewBuilder<TOutput> =
    Widget Function(
      BuildContext context,
      RadarPlaybackSnapshot<TOutput> snapshot,
      RadarPlaybackViewController<TOutput> controller,
    );

/// Lebenszyklusfähige Flutter-Anbindung der Radar-Playback-Engine.
///
/// Das Widget:
///
/// - startet die Initialisierung genau einmal,
/// - beobachtet den [RadarPlaybackViewController],
/// - übergibt jeden neuen Snapshot an den Builder,
/// - übernimmt optional das Dispose des Controllers.
///
/// Das bestehende Kartendesign bleibt vollständig beim aufrufenden Widget.
class RadarPlaybackView<TOutput> extends StatefulWidget {
  const RadarPlaybackView({
    required this.controller,
    required this.builder,
    this.initializeOnMount = true,
    this.disposeController = false,
    this.initializationErrorBuilder,
    super.key,
  });

  final RadarPlaybackViewController<TOutput> controller;
  final RadarPlaybackViewBuilder<TOutput> builder;

  /// Startet die Radarquelle nach dem ersten Aufbau des Widgets.
  final bool initializeOnMount;

  /// Gibt an, ob das Widget beim Entfernen auch den Controller freigibt.
  final bool disposeController;

  /// Optionaler Builder für Fehler, die bereits beim Aufruf von
  /// [RadarPlaybackViewController.initialize] entstehen.
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  )?
  initializationErrorBuilder;

  @override
  State<RadarPlaybackView<TOutput>> createState() =>
      _RadarPlaybackViewState<TOutput>();
}

class _RadarPlaybackViewState<TOutput>
    extends State<RadarPlaybackView<TOutput>> {
  Object? _initializationError;
  StackTrace? _initializationStackTrace;

  @override
  void initState() {
    super.initState();

    if (widget.initializeOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
    }
  }

  @override
  void didUpdateWidget(covariant RadarPlaybackView<TOutput> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (identical(oldWidget.controller, widget.controller)) {
      return;
    }

    if (oldWidget.disposeController) {
      oldWidget.controller.dispose();
    }

    _initializationError = null;
    _initializationStackTrace = null;

    if (widget.initializeOnMount) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _initialize());
    }
  }

  Future<void> _initialize() async {
    if (!mounted) {
      return;
    }

    try {
      await widget.controller.initialize();
    } catch (error, stackTrace) {
      if (!mounted) {
        return;
      }

      setState(() {
        _initializationError = error;
        _initializationStackTrace = stackTrace;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final error = _initializationError;
    final stackTrace = _initializationStackTrace;

    if (error != null &&
        stackTrace != null &&
        widget.initializationErrorBuilder != null) {
      return widget.initializationErrorBuilder!(context, error, stackTrace);
    }

    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return widget.builder(
          context,
          widget.controller.snapshot,
          widget.controller,
        );
      },
    );
  }

  @override
  void dispose() {
    if (widget.disposeController) {
      widget.controller.dispose();
    }

    super.dispose();
  }
}
