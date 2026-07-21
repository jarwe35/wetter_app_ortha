import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/satellite_layer.dart';
import '../services/satellite/esri_satellite_source.dart';
import '../services/satellite/satellite_controller.dart';
import '../services/satellite/satellite_layer_registry.dart';

class SatellitePage extends StatefulWidget {
  final String place;
  final double? latitude;
  final double? longitude;
  final Future<void> Function()? onRefresh;

  const SatellitePage({
    super.key,
    required this.place,
    required this.latitude,
    required this.longitude,
    this.onRefresh,
  });

  @override
  State<SatellitePage> createState() => _SatellitePageState();
}

class _SatellitePageState extends State<SatellitePage> {
  final MapController _mapController = MapController();
  final SatelliteController _satelliteController = SatelliteController();

  SatelliteLayerState? _baseLayerState;
  String _selectedLayerId = SatelliteLayerRegistry.esriWorldImagery.id;
  bool _isLoadingBaseLayer = true;
  bool _isRefreshing = false;
  String? _baseLayerError;

  @override
  void initState() {
    super.initState();
    _loadBaseLayer();
  }

  Future<void> _loadBaseLayer() async {
    if (mounted) {
      setState(() {
        _isLoadingBaseLayer = true;
        _baseLayerError = null;
      });
    }

    try {
      final states = await _satelliteController.loadLayer(
        layerId: _selectedLayerId,
        latitude: widget.latitude ?? 51.2277,
        longitude: widget.longitude ?? 6.7735,
      );

      if (!mounted) return;

      setState(() {
        _baseLayerState = states.isEmpty ? null : states.first;

        if (states.isEmpty) {
          _baseLayerError =
              'Die Satelliten-Basiskarte ist derzeit nicht verfügbar.';
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _baseLayerState = null;
        _baseLayerError = 'Die Satellitendaten konnten nicht geladen werden.';
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

    setState(() {
      _selectedLayerId = layerId;
    });

    await _loadBaseLayer();
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
                      SatelliteLayerRegistry.esriWorldImagery.id,
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
      await _loadBaseLayer();

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
    final baseLayerAvailable =
        _baseLayerState?.availability == SatelliteLayerAvailability.available;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Satellitenansicht'),
        actions: [
          IconButton(
            tooltip: 'Satelliten-Layer auswählen',
            onPressed: _showLayerSelection,
            icon: const Icon(Icons.layers_outlined),
          ),
          IconButton(
            tooltip: 'Satellitendaten aktualisieren',
            onPressed: _isRefreshing ? null : _refresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.3),
                  )
                : const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
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
                attributions: const [
                  TextSourceAttribution('Esri, Maxar, Earthstar Geographics'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              bottom: false,
              child: Card(
                color: Colors.black.withValues(alpha: 0.70),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.satellite_alt_outlined,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.place,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              hasCoordinates
                                  ? 'Satellitenbild am ausgewählten Standort'
                                  : 'Keine Standortkoordinaten verfügbar',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
                          color: Theme.of(context).colorScheme.onErrorContainer,
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
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Positioned(
            right: 16,
            bottom: 28,
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  FloatingActionButton.small(
                    heroTag: 'satellite_zoom_in',
                    tooltip: 'Vergrößern',
                    onPressed: _zoomIn,
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'satellite_zoom_out',
                    tooltip: 'Verkleinern',
                    onPressed: _zoomOut,
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'satellite_center',
                    tooltip: 'Standort zentrieren',
                    onPressed: _centerOnLocation,
                    child: const Icon(Icons.my_location),
                  ),
                ],
              ),
            ),
          ),
        ],
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
