import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/satellite_layer.dart';
import '../models/official_weather_warning.dart';
import '../services/radar/rainviewer_radar_service.dart';
import '../services/satellite/esri_satellite_source.dart';
import '../services/satellite/rainviewer_satellite_source.dart';
import '../services/satellite/satellite_controller.dart';
import '../services/satellite/satellite_layer_registry.dart';
import '../widgets/maps/ortha_map_header.dart';
import '../widgets/maps/ortha_map_layout.dart';
import '../widgets/maps/ortha_map_toolbar.dart';
import '../widgets/warnings/official_warning_polygon_overlay.dart';

class SatellitePage extends StatefulWidget {
  final String place;
  final double? latitude;
  final double? longitude;
  final List<OfficialWeatherWarning> warnings;
  final Future<void> Function()? onRefresh;

  const SatellitePage({
    super.key,
    required this.place,
    required this.latitude,
    required this.longitude,
    this.warnings = const [],
    this.onRefresh,
  });

  @override
  State<SatellitePage> createState() => _SatellitePageState();
}

class _SatellitePageState extends State<SatellitePage> {
  final MapController _mapController = MapController();
  final SatelliteController _satelliteController = SatelliteController();
  final RainViewerSatelliteSource _rainViewerSource =
      RainViewerSatelliteSource();

  SatelliteLayerState? _baseLayerState;
  SatelliteLayerState? _selectedLayerState;
  RainViewerRadarMetadata? _rainViewerMetadata;
  Timer? _radarAnimationTimer;
  int _selectedRadarFrameIndex = 0;
  bool _isRadarAnimating = false;
  String _selectedLayerId = SatelliteLayerRegistry.esriWorldImagery.id;
  bool _isLoadingBaseLayer = true;
  bool _isRefreshing = false;
  String? _baseLayerError;

  @override
  void initState() {
    super.initState();
    _loadBaseLayer();
  }

  @override
  void dispose() {
    _radarAnimationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _loadBaseLayer({bool forceRadarRefresh = false}) async {
    if (mounted) {
      setState(() {
        _isLoadingBaseLayer = true;
        _baseLayerError = null;
      });
    }

    try {
      final baseStates = await _satelliteController.loadLayer(
        layerId: SatelliteLayerRegistry.esriWorldImagery.id,
        latitude: widget.latitude ?? 51.2277,
        longitude: widget.longitude ?? 6.7735,
      );

      SatelliteLayerState? selectedLayerState;
      RainViewerRadarMetadata? rainViewerMetadata;

      if (_selectedLayerId == SatelliteLayerRegistry.rainViewerRadar.id) {
        final radarStates = await _satelliteController.loadLayer(
          layerId: SatelliteLayerRegistry.rainViewerRadar.id,
          latitude: widget.latitude ?? 51.2277,
          longitude: widget.longitude ?? 6.7735,
        );

        selectedLayerState = radarStates.isEmpty ? null : radarStates.first;

        if (selectedLayerState?.availability ==
            SatelliteLayerAvailability.available) {
          rainViewerMetadata = await _rainViewerSource.loadMetadata(
            forceRefresh: forceRadarRefresh,
          );
        }
      } else {
        selectedLayerState = baseStates.isEmpty ? null : baseStates.first;
      }

      if (!mounted) return;

      setState(() {
        _baseLayerState = baseStates.isEmpty ? null : baseStates.first;
        _selectedLayerState = selectedLayerState;
        _rainViewerMetadata = rainViewerMetadata;
        _selectedRadarFrameIndex = rainViewerMetadata == null
            ? 0
            : rainViewerMetadata.frames.length - 1;

        if (baseStates.isEmpty) {
          _baseLayerError =
              'Die Satelliten-Basiskarte ist derzeit nicht verfügbar.';
        } else if (_selectedLayerId ==
                SatelliteLayerRegistry.rainViewerRadar.id &&
            selectedLayerState?.availability ==
                SatelliteLayerAvailability.error) {
          _baseLayerError =
              selectedLayerState?.statusMessage ??
              'Das Niederschlagsradar ist derzeit nicht verfügbar.';
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _rainViewerMetadata = null;
        _selectedLayerState = null;
        _baseLayerError = 'Die Kartendaten konnten nicht geladen werden.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBaseLayer = false;
        });
      }
    }
  }

  Future<void> _selectLayer(String layerId) async {
    if (layerId == _selectedLayerId) return;

    _stopRadarAnimation();

    setState(() {
      _selectedLayerId = layerId;
      _selectedLayerState = null;
      _rainViewerMetadata = null;
      _baseLayerError = null;
    });

    await _loadBaseLayer();
  }

  RainViewerRadarFrame? get _selectedRadarFrame {
    final metadata = _rainViewerMetadata;

    if (metadata == null || metadata.frames.isEmpty) {
      return null;
    }

    final safeIndex = _selectedRadarFrameIndex.clamp(
      0,
      metadata.frames.length - 1,
    );

    return metadata.frames[safeIndex];
  }

  void _selectRadarFrame(int index) {
    final metadata = _rainViewerMetadata;

    if (metadata == null || metadata.frames.isEmpty) {
      return;
    }

    final safeIndex = index.clamp(0, metadata.frames.length - 1);

    setState(() {
      _selectedRadarFrameIndex = safeIndex;
    });
  }

  void _stopRadarAnimation() {
    _radarAnimationTimer?.cancel();
    _radarAnimationTimer = null;

    if (_isRadarAnimating && mounted) {
      setState(() {
        _isRadarAnimating = false;
      });
    } else {
      _isRadarAnimating = false;
    }
  }

  void _toggleRadarAnimation() {
    final metadata = _rainViewerMetadata;

    if (metadata == null || metadata.frames.length < 2) {
      return;
    }

    if (_isRadarAnimating) {
      _stopRadarAnimation();
      return;
    }

    setState(() {
      _isRadarAnimating = true;

      if (_selectedRadarFrameIndex >= metadata.frames.length - 1) {
        _selectedRadarFrameIndex = 0;
      }
    });

    _radarAnimationTimer?.cancel();
    _radarAnimationTimer = Timer.periodic(const Duration(milliseconds: 850), (
      _,
    ) {
      if (!mounted) {
        _radarAnimationTimer?.cancel();
        return;
      }

      final currentMetadata = _rainViewerMetadata;

      if (currentMetadata == null || currentMetadata.frames.length < 2) {
        _stopRadarAnimation();
        return;
      }

      setState(() {
        if (_selectedRadarFrameIndex >= currentMetadata.frames.length - 1) {
          _selectedRadarFrameIndex = 0;
        } else {
          _selectedRadarFrameIndex++;
        }
      });
    });
  }

  String _formatRadarTime(DateTime timeUtc) {
    final local = timeUtc.toLocal();
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');

    return '$hour:$minute Uhr';
  }

  String _radarRelativeTime(DateTime timeUtc) {
    final metadata = _rainViewerMetadata;

    if (metadata == null || metadata.frames.isEmpty) {
      return '';
    }

    final latest = metadata.latestFrame.time;
    final difference = latest.difference(timeUtc).inMinutes;

    if (difference <= 0) {
      return 'Aktuellster Messstand';
    }

    return 'vor $difference Minuten';
  }

  Future<void> _showLayerSelection() async {
    final selectedLayerId = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  'Satelliten-Layer',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              for (final definition in SatelliteLayerRegistry.definitions)
                _SatelliteLayerSelectionTile(
                  definition: definition,
                  selected: definition.id == _selectedLayerId,
                  available:
                      definition.id ==
                          SatelliteLayerRegistry.esriWorldImagery.id ||
                      definition.id ==
                          SatelliteLayerRegistry.rainViewerRadar.id ||
                      (definition.id ==
                              SatelliteLayerRegistry.officialWarnings.id &&
                          widget.warnings.any(
                            (warning) =>
                                warning.geometry != null &&
                                !warning.geometry!.isEmpty,
                          )),
                  onSelected: () {
                    Navigator.of(context).pop(definition.id);
                  },
                ),
            ],
          ),
        );
      },
    );

    if (selectedLayerId == null || !mounted) return;

    await _selectLayer(selectedLayerId);
  }

  LatLng get _center {
    final latitude = widget.latitude;
    final longitude = widget.longitude;

    if (latitude == null || longitude == null) {
      return const LatLng(51.2277, 6.7735);
    }

    return LatLng(latitude, longitude);
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    try {
      await widget.onRefresh?.call();
      await _loadBaseLayer(forceRadarRefresh: true);

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

  void _zoomIn() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom + 1);
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, camera.zoom - 1);
  }

  void _centerOnLocation() {
    _mapController.move(_center, 10);
  }

  @override
  Widget build(BuildContext context) {
    final hasCoordinates = widget.latitude != null && widget.longitude != null;
    final selectedLayer =
        SatelliteLayerRegistry.findById(_selectedLayerId) ??
        SatelliteLayerRegistry.esriWorldImagery;
    final baseLayerAvailable =
        _baseLayerState?.availability == SatelliteLayerAvailability.available;
    final rainViewerSelected =
        _selectedLayerId == SatelliteLayerRegistry.rainViewerRadar.id;
    final rainViewerAvailable =
        _selectedLayerState?.availability ==
            SatelliteLayerAvailability.available &&
        _rainViewerMetadata != null;
    final selectedRadarFrame = _selectedRadarFrame;
    final rainViewerTileUrl = rainViewerAvailable && selectedRadarFrame != null
        ? _rainViewerMetadata!.tileUrlTemplate(frame: selectedRadarFrame)
        : null;
    final warningOverlaySelected =
        _selectedLayerId == SatelliteLayerRegistry.officialWarnings.id;
    final warningGeometryCount = widget.warnings
        .where(
          (warning) => warning.geometry != null && !warning.geometry!.isEmpty,
        )
        .length;
    final layerStatusText = warningOverlaySelected
        ? warningGeometryCount == 0
              ? 'Keine Warngebiete verfügbar'
              : '$warningGeometryCount Warngebiet(e) aktiv'
        : _isLoadingBaseLayer
        ? 'Wird geladen'
        : _baseLayerError != null
        ? 'Fehler'
        : rainViewerSelected
        ? _selectedLayerState?.statusMessage ?? 'Nicht verfügbar'
        : _baseLayerState?.statusMessage ?? 'Nicht verfügbar';

    return Scaffold(
      body: OrthaMapLayout(
        padding: EdgeInsets.zero,
        borderRadius: 0,
        minimumMapHeight: 0,
        maximumContentWidth: double.infinity,
        header: OrthaMapHeader(
          place: widget.place,
          mode: selectedLayer.name,
          statusText: '${selectedLayer.sourceName} · $layerStatusText',
          novaStatus: 'Normal',
          coordinatesAvailable: hasCoordinates,
          onLayers: _showLayerSelection,
          onRefresh: _isRefreshing ? null : _refresh,
          isRefreshing: _isRefreshing,
        ),
        sectionSpacing: 12,
        footer:
            rainViewerSelected &&
                rainViewerAvailable &&
                _rainViewerMetadata!.frames.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Material(
                  color: Colors.black.withValues(alpha: 0.82),
                  elevation: 6,
                  borderRadius: BorderRadius.circular(18),
                  clipBehavior: Clip.antiAlias,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 10, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            SizedBox(
                              width: 42,
                              height: 42,
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                tooltip: _isRadarAnimating
                                    ? 'Radaranimation anhalten'
                                    : 'Radarverlauf abspielen',
                                onPressed: _toggleRadarAnimation,
                                icon: Icon(
                                  _isRadarAnimating
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    selectedRadarFrame == null
                                        ? 'Radarzeitpunkt'
                                        : _formatRadarTime(
                                            selectedRadarFrame.time,
                                          ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (selectedRadarFrame != null)
                                    Text(
                                      _radarRelativeTime(
                                        selectedRadarFrame.time,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.72,
                                        ),
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '2 Std.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.72),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 28,
                          child: Slider(
                            value: _selectedRadarFrameIndex
                                .clamp(
                                  0,
                                  _rainViewerMetadata!.frames.length - 1,
                                )
                                .toDouble(),
                            min: 0,
                            max: (_rainViewerMetadata!.frames.length - 1)
                                .toDouble(),
                            divisions: _rainViewerMetadata!.frames.length - 1,
                            label: selectedRadarFrame == null
                                ? null
                                : _formatRadarTime(selectedRadarFrame.time),
                            onChangeStart: (_) {
                              _stopRadarAnimation();
                            },
                            onChanged: (value) {
                              _selectRadarFrame(value.round());
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            children: [
                              Text(
                                _formatRadarTime(
                                  _rainViewerMetadata!.frames.first.time,
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.62),
                                  fontSize: 9,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatRadarTime(
                                  _rainViewerMetadata!.frames.last.time,
                                ),
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.62),
                                  fontSize: 9,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
        mapControls: OrthaMapToolbar(
          compact: true,
          onLayers: _showLayerSelection,
          onZoomIn: _zoomIn,
          onZoomOut: _zoomOut,
          onCenter: _centerOnLocation,
        ),
        map: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _center,
                initialZoom: hasCoordinates ? 10 : 6,
                minZoom: 2,
                maxZoom: 18,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                if (baseLayerAvailable)
                  TileLayer(
                    urlTemplate: EsriSatelliteSource.worldImageryUrlTemplate,
                    userAgentPackageName: 'com.example.wetter_app_ortha',
                    maxZoom: 18,
                    tileDisplay: const TileDisplay.fadeIn(),
                  ),
                if (rainViewerTileUrl != null)
                  TileLayer(
                    urlTemplate: rainViewerTileUrl,
                    userAgentPackageName: 'com.example.wetter_app_ortha',
                    minNativeZoom: 0,
                    maxNativeZoom: 7,
                    maxZoom: 18,
                    tileDisplay: const TileDisplay.fadeIn(),
                  ),
                if (warningOverlaySelected)
                  OfficialWarningPolygonOverlay(warnings: widget.warnings),
                if (hasCoordinates)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _center,
                        width: 58,
                        height: 58,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.20),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.35),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                RichAttributionWidget(
                  attributions: [
                    const TextSourceAttribution(
                      'Esri, Maxar, Earthstar Geographics',
                    ),
                    if (rainViewerSelected)
                      const TextSourceAttribution('RainViewer'),
                  ],
                ),
              ],
            ),
            if (_isLoadingBaseLayer)
              const Positioned.fill(
                child: IgnorePointer(
                  child: ColoredBox(
                    color: Color(0x33000000),
                    child: Center(
                      child: Card(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 18,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                ),
                              ),
                              SizedBox(width: 14),
                              Text('Satellitenbild wird geladen …'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (!_isLoadingBaseLayer && _baseLayerError != null)
              Positioned(
                left: 16,
                right: 16,
                bottom: 28,
                child: SafeArea(
                  top: false,
                  child: Card(
                    color: Theme.of(context).colorScheme.errorContainer,
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
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
                              _baseLayerError!,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Erneut versuchen',
                            onPressed: _loadBaseLayer,
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
              ),
          ],
        ),
      ),
    );
  }
}

class _SatelliteLayerSelectionTile extends StatelessWidget {
  final SatelliteLayerDefinition definition;
  final bool selected;
  final bool available;
  final VoidCallback onSelected;

  const _SatelliteLayerSelectionTile({
    required this.definition,
    required this.selected,
    required this.available,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      enabled: available,
      selected: selected,
      leading: Icon(
        _iconForType(definition.type),
        color: available
            ? selected
                  ? colorScheme.primary
                  : null
            : colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
      ),
      title: Text(definition.name),
      subtitle: Text(
        available
            ? definition.sourceName
            : '${definition.sourceName} · noch nicht verfügbar',
      ),
      trailing: selected
          ? Icon(Icons.check_circle, color: colorScheme.primary)
          : available
          ? const Icon(Icons.radio_button_unchecked)
          : const Icon(Icons.lock_outline),
      onTap: available ? onSelected : null,
    );
  }

  static IconData _iconForType(SatelliteLayerType type) {
    return switch (type) {
      SatelliteLayerType.baseMap => Icons.public,
      SatelliteLayerType.visibleSatellite => Icons.satellite_alt_outlined,
      SatelliteLayerType.infrared => Icons.thermostat_outlined,
      SatelliteLayerType.waterVapor => Icons.water_drop_outlined,
      SatelliteLayerType.cloudTopHeight => Icons.cloud_outlined,
      SatelliteLayerType.thunderstormSeverity => Icons.thunderstorm_outlined,
      SatelliteLayerType.radar => Icons.radar_outlined,
      SatelliteLayerType.officialWarnings => Icons.warning_amber_outlined,
      SatelliteLayerType.orthaRisk => Icons.shield_outlined,
    };
  }
}
