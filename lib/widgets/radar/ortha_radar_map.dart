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
    _httpClient.close();
    super.dispose();
  }

  Future<void> _loadRadar() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final metadata = await _radarService.fetchMetadata();
      final latestFrame = metadata.latestFrame;

      if (!mounted) return;

      setState(() {
        _metadata = metadata;
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
                Text(_errorMessage!, textAlign: TextAlign.center),
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
        const SizedBox(height: 14),
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
              onPressed: _loadRadar,
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
