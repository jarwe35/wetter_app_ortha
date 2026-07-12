import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

import '../../services/radar/rainviewer_radar_service.dart';

class OrthaRadarMap extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String place;

  const OrthaRadarMap({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.place,
  });

  @override
  State<OrthaRadarMap> createState() => _OrthaRadarMapState();
}

class _OrthaRadarMapState extends State<OrthaRadarMap> {
  late final http.Client _httpClient;
  late final RainViewerRadarService _radarService;

  RainViewerRadarMetadata? _metadata;
  RainViewerRadarFrame? _selectedFrame;

  int _selectedFrameIndex = 0;
  int _rangeStartIndex = 0;
  int _rangeEndIndex = 0;

  Timer? _animationTimer;
  bool _isPlaying = false;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _httpClient = http.Client();
    _radarService = RainViewerRadarService(httpClient: _httpClient);

    _loadRadar();
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _httpClient.close();
    super.dispose();
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
      final latestFrame = metadata.latestFrame;
      final lastIndex = metadata.frames.length - 1;

      if (!mounted) return;

      setState(() {
        _metadata = metadata;
        _rangeStartIndex = 0;
        _rangeEndIndex = lastIndex;
        _selectedFrameIndex = lastIndex;
        _selectedFrame = latestFrame;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleAnimation() {
    if (_isPlaying) {
      _stopAnimation();
    } else {
      _startAnimation();
    }
  }

  void _startAnimation() {
    final metadata = _metadata;

    if (metadata == null || _rangeEndIndex <= _rangeStartIndex) {
      return;
    }

    _animationTimer?.cancel();

    var initialIndex = _selectedFrameIndex;

    if (initialIndex < _rangeStartIndex || initialIndex >= _rangeEndIndex) {
      initialIndex = _rangeStartIndex;
    }

    setState(() {
      _selectedFrameIndex = initialIndex;
      _selectedFrame = metadata.frames[initialIndex];
      _isPlaying = true;
    });

    _animationTimer = Timer.periodic(const Duration(milliseconds: 900), (_) {
      if (!mounted) {
        _animationTimer?.cancel();
        return;
      }

      final nextIndex = _selectedFrameIndex >= _rangeEndIndex
          ? _rangeStartIndex
          : _selectedFrameIndex + 1;

      setState(() {
        _selectedFrameIndex = nextIndex;
        _selectedFrame = metadata.frames[nextIndex];
      });
    });
  }

  void _stopAnimation() {
    _animationTimer?.cancel();
    _animationTimer = null;

    if (mounted && _isPlaying) {
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 380,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Live-Radardaten werden geladen …'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 380,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_outlined, size: 48),
                const SizedBox(height: 16),
                const Text(
                  'Live-Radardaten konnten nicht geladen werden.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Bitte prüfe die Internetverbindung oder versuche es '
                  'in einigen Augenblicken erneut.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _loadRadar,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Erneut versuchen'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final metadata = _metadata;
    final selectedFrame = _selectedFrame;

    if (metadata == null || selectedFrame == null) {
      return const SizedBox(
        height: 380,
        child: Center(child: Text('Keine Radardaten verfügbar.')),
      );
    }

    final radarTileUrl = metadata.tileUrlTemplate(frame: selectedFrame);

    final center = LatLng(widget.latitude, widget.longitude);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 420,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: center,
                initialZoom: 7.5,
                minZoom: 3,
                maxZoom: 12,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'de.ortha.meteo',
                ),
                TileLayer(
                  key: ValueKey(radarTileUrl),
                  urlTemplate: radarTileUrl,
                  userAgentPackageName: 'de.ortha.meteo',
                  maxNativeZoom: 7,
                  maxZoom: 12,
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: center,
                      width: 52,
                      height: 52,
                      child: const Icon(
                        Icons.location_on,
                        size: 42,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('OpenStreetMap contributors'),
                    TextSourceAttribution('RainViewer'),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (metadata.frames.length > 1) ...[
          Row(
            children: [
              const Icon(Icons.history_outlined, size: 20),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Radar-Zeitverlauf',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              FilledButton.icon(
                onPressed: _rangeEndIndex > _rangeStartIndex
                    ? _toggleAnimation
                    : null,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                label: Text(_isPlaying ? 'Pause' : 'Start'),
              ),
              const SizedBox(width: 10),
              Text('${_selectedFrameIndex + 1}/${metadata.frames.length}'),
            ],
          ),
          const SizedBox(height: 8),
          RangeSlider(
            values: RangeValues(
              _rangeStartIndex.toDouble(),
              _rangeEndIndex.toDouble(),
            ),
            min: 0,
            max: (metadata.frames.length - 1).toDouble(),
            divisions: metadata.frames.length - 1,
            labels: RangeLabels(
              _formatFrameTime(metadata.frames[_rangeStartIndex].time),
              _formatFrameTime(metadata.frames[_rangeEndIndex].time),
            ),
            onChanged: (values) {
              final startIndex = values.start.round();
              final endIndex = values.end.round();

              _stopAnimation();

              setState(() {
                _rangeStartIndex = startIndex;
                _rangeEndIndex = endIndex;
                _selectedFrameIndex = startIndex;
                _selectedFrame = metadata.frames[startIndex];
              });
            },
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Start: ${_formatFrameTime(metadata.frames[_rangeStartIndex].time)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
              Expanded(
                child: Text(
                  'Ende: ${_formatFrameTime(metadata.frames[_rangeEndIndex].time)}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
        if (metadata.isStale) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.55)),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.history_toggle_off_outlined),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Radarserver derzeit nicht erreichbar. '
                    'Es wird der letzte verfügbare Radarstand angezeigt.',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Icon(Icons.radar_outlined, size: 18),
            Text(
              'Live-Radar für ${widget.place}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Radarstand: ${_formatFrameTime(selectedFrame.time)}'),
            OutlinedButton.icon(
              onPressed: () => _loadRadar(forceRefresh: true),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Radar aktualisieren'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatFrameTime(DateTime time) {
    final localTime = time.toLocal();

    final day = localTime.day.toString().padLeft(2, '0');
    final month = localTime.month.toString().padLeft(2, '0');
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');

    return '$day.$month. · $hour:$minute Uhr';
  }
}
