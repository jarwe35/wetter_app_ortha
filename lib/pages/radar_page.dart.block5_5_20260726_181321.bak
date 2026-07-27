import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../services/radar/rainviewer_radar_service.dart';
import '../services/weather_service.dart';
import '../widgets/maps/ortha_hourly_forecast_chart.dart';
import '../widgets/maps/ortha_map_header.dart';
import '../widgets/maps/ortha_map_toolbar.dart';
import '../widgets/maps/ortha_radar_legend.dart';
import '../widgets/maps/ortha_radar_timeline.dart';
import 'maps/ortha_fullscreen_map_page.dart';

class RadarPage extends StatefulWidget {
  final String place;
  final double? latitude;
  final double? longitude;
  final List<HourlyForecast> hourlyForecast;
  final Future<void> Function()? onRefresh;

  const RadarPage({
    super.key,
    required this.place,
    required this.latitude,
    required this.longitude,
    this.hourlyForecast = const [],
    this.onRefresh,
  });

  @override
  State<RadarPage> createState() => _RadarPageState();
}

class _RadarPageState extends State<RadarPage> {
  late final http.Client _httpClient;
  late final RainViewerRadarService _radarService;

  final MapController _mapController = MapController();

  RainViewerRadarMetadata? _metadata;
  Timer? _animationTimer;
  Timer? _frameTransitionTimer;
  Timer? _rateLimitTimer;

  int _selectedFrameIndex = 0;
  int _primaryRadarFrameIndex = 0;
  int _secondaryRadarFrameIndex = 0;
  bool _showPrimaryRadarLayer = true;
  bool _isAnimating = false;
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isMapInteractionLocked = true;
  String? _errorMessage;
  String? _lastLoggedRadarTileUrl;
  DateTime? _radarRateLimitedUntil;
  bool _radarRateLimited = false;

  @override
  void initState() {
    super.initState();

    _httpClient = http.Client();
    _radarService = RainViewerRadarService(httpClient: _httpClient);

    _loadRadar();
  }

  @override
  void didUpdateWidget(covariant RadarPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final locationChanged =
        oldWidget.latitude != widget.latitude ||
        oldWidget.longitude != widget.longitude;

    if (!locationChanged) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _mapController.move(_center, _hasCoordinates ? 8.5 : 6);
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _frameTransitionTimer?.cancel();
    _rateLimitTimer?.cancel();
    _mapController.dispose();
    _httpClient.close();
    super.dispose();
  }

  bool get _hasCoordinates =>
      widget.latitude != null && widget.longitude != null;

  LatLng get _center {
    if (!_hasCoordinates) {
      return const LatLng(51.2277, 6.7735);
    }

    return LatLng(widget.latitude!, widget.longitude!);
  }

  RainViewerRadarFrame? get _selectedFrame {
    final metadata = _metadata;

    if (metadata == null || metadata.frames.isEmpty) {
      return null;
    }

    final safeIndex = _selectedFrameIndex.clamp(0, metadata.frames.length - 1);

    return metadata.frames[safeIndex];
  }

  Future<void> _loadRadar({bool forceRefresh = false}) async {
    _stopAnimation();

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final metadata = await _radarService.fetchMetadata(
        forceRefresh: forceRefresh,
      );

      if (!mounted) return;

      setState(() {
        _metadata = metadata;

        final latestIndex = metadata.frames.isEmpty
            ? 0
            : metadata.frames.length - 1;

        _selectedFrameIndex = latestIndex;
        _primaryRadarFrameIndex = latestIndex;
        _secondaryRadarFrameIndex = latestIndex;
        _showPrimaryRadarLayer = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _metadata = null;
        _errorMessage =
            'Die Live-Radardaten konnten derzeit nicht geladen werden.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refresh() async {
    if (_isRefreshing) {
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh?.call();
      await _loadRadar(forceRefresh: true);

      if (!mounted) return;

      _mapController.move(_center, _mapController.camera.zoom);
    } finally {
      if (mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  void _selectFrame(int index) {
    final metadata = _metadata;

    if (metadata == null || metadata.frames.isEmpty) {
      return;
    }

    final safeIndex = index.clamp(0, metadata.frames.length - 1);

    _frameTransitionTimer?.cancel();

    setState(() {
      _selectedFrameIndex = safeIndex;
      _primaryRadarFrameIndex = safeIndex;
      _secondaryRadarFrameIndex = safeIndex;
      _showPrimaryRadarLayer = true;
    });
  }

  void _toggleAnimation() {
    final metadata = _metadata;

    if (_isRadarRateLimited) {
      return;
    }

    if (metadata == null || metadata.frames.length < 2) {
      return;
    }

    if (_isAnimating) {
      _stopAnimation();
      return;
    }

    setState(() {
      _isAnimating = true;

      if (_selectedFrameIndex >= metadata.frames.length - 1) {
        _selectedFrameIndex = 0;
        _primaryRadarFrameIndex = 0;
        _secondaryRadarFrameIndex = 0;
        _showPrimaryRadarLayer = true;
      }
    });

    _scheduleNextRadarFrame();
  }

  void _scheduleNextRadarFrame() {
    _animationTimer?.cancel();
    _frameTransitionTimer?.cancel();

    if (!_isAnimating || !mounted) {
      return;
    }

    _animationTimer = Timer(const Duration(milliseconds: 1900), () {
      if (!mounted || !_isAnimating) {
        return;
      }

      final metadata = _metadata;

      if (metadata == null || metadata.frames.length < 2) {
        _stopAnimation();
        return;
      }

      final nextIndex = (_selectedFrameIndex + 1) % metadata.frames.length;

      setState(() {
        if (_showPrimaryRadarLayer) {
          _secondaryRadarFrameIndex = nextIndex;
        } else {
          _primaryRadarFrameIndex = nextIndex;
        }
      });

      _frameTransitionTimer = Timer(const Duration(milliseconds: 850), () {
        if (!mounted || !_isAnimating) {
          return;
        }

        setState(() {
          _selectedFrameIndex = nextIndex;
          _showPrimaryRadarLayer = !_showPrimaryRadarLayer;
        });

        _scheduleNextRadarFrame();
      });
    });
  }

  bool get _isRadarRateLimited {
    final limitedUntil = _radarRateLimitedUntil;

    return limitedUntil != null && DateTime.now().isBefore(limitedUntil);
  }

  void _handleRadarTileError(Object error) {
    final message = error.toString();

    if (!message.contains('429')) {
      return;
    }

    final nextAllowedAttempt = DateTime.now().add(const Duration(seconds: 60));

    if (_radarRateLimitedUntil != null &&
        _radarRateLimitedUntil!.isAfter(DateTime.now())) {
      return;
    }

    _radarRateLimitedUntil = nextAllowedAttempt;
    _stopAnimation();

    _rateLimitTimer?.cancel();
    _rateLimitTimer = Timer(const Duration(seconds: 60), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _radarRateLimitedUntil = null;
        _radarRateLimited = false;
      });
    });

    if (!mounted) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _radarRateLimited = true;
      });
    });

    debugPrint('');
    debugPrint('===== ORTHA RADAR RATE LIMIT =====');
    debugPrint('RainViewer meldet HTTP 429.');
    debugPrint('Radaranimation für 60 Sekunden angehalten.');
    debugPrint('==================================');
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _frameTransitionTimer?.cancel();
    _animationTimer = null;
    _frameTransitionTimer = null;

    if (_isAnimating && mounted) {
      setState(() {
        _isAnimating = false;
      });
    } else {
      _isAnimating = false;
    }
  }

  void _toggleMapInteractionLock() {
    setState(() {
      _isMapInteractionLocked = !_isMapInteractionLocked;
    });
  }

  void _zoomIn() {
    final camera = _mapController.camera;
    final targetZoom = (camera.zoom + 1).clamp(2.0, 18.0);

    _mapController.move(camera.center, targetZoom);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    final targetZoom = (camera.zoom - 1).clamp(2.0, 18.0);

    _mapController.move(camera.center, targetZoom);
  }

  void _centerOnLocation() {
    _mapController.move(_center, _hasCoordinates ? 8.5 : 6);
  }

  String _formatRadarTime(DateTime timeUtc) {
    final local = timeUtc.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute Uhr';
  }

  void _logRadarTileUrl(String? radarTileUrl) {
    if (radarTileUrl == null || radarTileUrl == _lastLoggedRadarTileUrl) {
      return;
    }

    _lastLoggedRadarTileUrl = radarTileUrl;

    debugPrint('');
    debugPrint('===== ORTHA RADAR TILE URL =====');
    debugPrint(radarTileUrl);
    debugPrint('================================');
  }

  String _relativeRadarTime(DateTime timeUtc) {
    final metadata = _metadata;

    if (metadata == null || metadata.frames.isEmpty) {
      return '';
    }

    final difference = metadata.latestFrame.time.difference(timeUtc).inMinutes;

    if (difference <= 0) {
      return 'Aktuellster Messstand';
    }

    return 'vor $difference Minuten';
  }

  @override
  Widget build(BuildContext context) {
    final metadata = _metadata;
    final selectedFrame = _selectedFrame;

    final radarTileUrl = metadata != null && selectedFrame != null
        ? metadata.tileUrlTemplate(frame: selectedFrame)
        : null;

    final primaryRadarFrame = metadata != null && metadata.frames.isNotEmpty
        ? metadata.frames[_primaryRadarFrameIndex.clamp(
            0,
            metadata.frames.length - 1,
          )]
        : null;

    final secondaryRadarFrame = metadata != null && metadata.frames.isNotEmpty
        ? metadata.frames[_secondaryRadarFrameIndex.clamp(
            0,
            metadata.frames.length - 1,
          )]
        : null;

    final primaryRadarTileUrl = metadata != null && primaryRadarFrame != null
        ? metadata.tileUrlTemplate(frame: primaryRadarFrame)
        : null;

    final secondaryRadarTileUrl =
        metadata != null && secondaryRadarFrame != null
        ? metadata.tileUrlTemplate(frame: secondaryRadarFrame)
        : null;

    _logRadarTileUrl(radarTileUrl);

    final radarRateLimited = _isRadarRateLimited;

    final statusText = _isLoading
        ? 'RainViewer · Wird geladen'
        : radarRateLimited || _radarRateLimited
        ? 'RainViewer · Server ausgelastet'
        : _errorMessage != null
        ? 'RainViewer · Nicht verfügbar'
        : metadata?.isStale == true
        ? 'RainViewer · Letzter verfügbarer Stand'
        : 'RainViewer · Live';

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SizedBox(
          height: 560,
          child: OrthaFullscreenMapPage(
            topBar: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OrthaMapHeader(
                place: widget.place,
                mode: 'Niederschlagsradar',
                statusText: statusText,
                novaStatus: 'Normal',
                coordinatesAvailable: _hasCoordinates,
                onRefresh: _isRefreshing ? null : _refresh,
                isRefreshing: _isRefreshing,
              ),
            ),
            trailingControls: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                OrthaMapToolbar(
                  compact: true,
                  onZoomIn: _zoomIn,
                  onZoomOut: _zoomOut,
                  onCenter: _centerOnLocation,
                ),
                const SizedBox(height: 10),
                Material(
                  color: const Color(0xE6142F44),
                  elevation: 5,
                  shape: const CircleBorder(),
                  child: IconButton(
                    tooltip: _isMapInteractionLocked
                        ? 'Karte entsperren'
                        : 'Karte sperren',
                    onPressed: _toggleMapInteractionLock,
                    icon: Icon(
                      _isMapInteractionLocked
                          ? Icons.lock_outline
                          : Icons.lock_open_outlined,
                      color: _isMapInteractionLocked
                          ? const Color(0xFFF2BE57)
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            timeline:
                metadata != null &&
                    metadata.frames.length > 1 &&
                    selectedFrame != null
                ? OrthaRadarTimeline(
                    value: _selectedFrameIndex,
                    frameCount: metadata.frames.length,
                    currentTimeText: _formatRadarTime(selectedFrame.time),
                    relativeTimeText: _relativeRadarTime(selectedFrame.time),
                    firstTimeText: _formatRadarTime(metadata.frames.first.time),
                    lastTimeText: _formatRadarTime(metadata.frames.last.time),
                    isAnimating: _isAnimating,
                    onToggleAnimation: _toggleAnimation,
                    onChangeStart: _stopAnimation,
                    onChanged: _selectFrame,
                  )
                : null,
            map: Stack(
              fit: StackFit.expand,
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _center,
                    initialZoom: _hasCoordinates ? 8.5 : 6,
                    minZoom: 2,
                    maxZoom: 18,

                    interactionOptions: InteractionOptions(
                      flags: _isMapInteractionLocked
                          ? InteractiveFlag.pinchZoom |
                                InteractiveFlag.doubleTapZoom
                          : InteractiveFlag.all,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'de.ortha.meteo',
                      maxZoom: 18,
                      tileDisplay: const TileDisplay.fadeIn(),
                    ),
                    if (primaryRadarTileUrl != null)
                      AnimatedOpacity(
                        opacity: _showPrimaryRadarLayer ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeInOut,
                        child: TileLayer(
                          key: const ValueKey('ortha-radar-primary'),
                          urlTemplate: primaryRadarTileUrl,
                          userAgentPackageName: 'de.ortha.meteo',
                          minNativeZoom: 0,
                          maxNativeZoom: 7,
                          maxZoom: 18,
                          errorTileCallback: (tile, error, stackTrace) {
                            _handleRadarTileError(error);
                          },
                        ),
                      ),
                    if (secondaryRadarTileUrl != null)
                      AnimatedOpacity(
                        opacity: _showPrimaryRadarLayer ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeInOut,
                        child: TileLayer(
                          key: const ValueKey('ortha-radar-secondary'),
                          urlTemplate: secondaryRadarTileUrl,
                          userAgentPackageName: 'de.ortha.meteo',
                          minNativeZoom: 0,
                          maxNativeZoom: 7,
                          maxZoom: 18,
                          errorTileCallback: (tile, error, stackTrace) {
                            _handleRadarTileError(error);
                          },
                        ),
                      ),
                    if (_hasCoordinates)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _center,
                            width: 32,
                            height: 32,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue.withValues(alpha: 0.20),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.35),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Colors.white,
                                size: 17,
                              ),
                            ),
                          ),
                        ],
                      ),
                    const RichAttributionWidget(
                      attributions: [
                        TextSourceAttribution('OpenStreetMap contributors'),
                        TextSourceAttribution('RainViewer'),
                      ],
                    ),
                  ],
                ),
                if (_isLoading)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x99071018),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text(
                              'Live-Radardaten werden geladen …',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (_errorMessage != null && !_isLoading)
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 120,
                    child: Material(
                      color: Theme.of(context).colorScheme.errorContainer,
                      elevation: 8,
                      borderRadius: BorderRadius.circular(18),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 10, 14),
                        child: Row(
                          children: [
                            Icon(
                              Icons.cloud_off_outlined,
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              tooltip: 'Erneut versuchen',
                              onPressed: _loadRadar,
                              icon: const Icon(Icons.refresh),
                              color: Theme.of(
                                context,
                              ).colorScheme.onErrorContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (metadata?.isStale == true && !_isLoading)
                  Positioned(
                    left: 20,
                    right: 20,
                    top: 120,
                    child: Material(
                      color: Colors.orange.withValues(alpha: 0.92),
                      elevation: 8,
                      borderRadius: BorderRadius.circular(18),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(Icons.history_toggle_off_outlined),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Der Radarserver ist derzeit nicht erreichbar. '
                                'Angezeigt wird der letzte verfügbare Radarstand.',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (widget.hourlyForecast.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: OrthaHourlyForecastChart(forecast: widget.hourlyForecast),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: OrthaRadarLegend(),
        ),
      ],
    );
  }
}
