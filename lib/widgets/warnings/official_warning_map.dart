import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../models/official_weather_warning.dart';

class OfficialWarningMap extends StatelessWidget {
  final OfficialWeatherWarning warning;
  final double latitude;
  final double longitude;
  final String place;

  const OfficialWarningMap({
    super.key,
    required this.warning,
    required this.latitude,
    required this.longitude,
    required this.place,
  });

  @override
  Widget build(BuildContext context) {
    final geometry = warning.geometry;

    if (geometry == null || geometry.isEmpty) {
      return const SizedBox.shrink();
    }

    final polygons = geometry.polygons
        .where((ring) => ring.length >= 3)
        .map(
          (ring) => Polygon(
            points: ring
                .map((point) => LatLng(point[0], point[1]))
                .toList(growable: false),
            color: const Color(0xFFB94A48).withValues(alpha: 0.22),
            borderColor: const Color(0xFFB94A48),
            borderStrokeWidth: 2.5,
          ),
        )
        .toList(growable: false);

    if (polygons.isEmpty) {
      return const SizedBox.shrink();
    }

    final mapController = MapController();
    final location = LatLng(latitude, longitude);

    return Container(
      width: double.infinity,
      height: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF27465D).withValues(alpha: 0.85),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: location,
              initialZoom: 11,
              minZoom: 4,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'de.ortha.meteo',
              ),
              PolygonLayer(polygons: polygons),
              MarkerLayer(
                markers: [
                  Marker(
                    point: location,
                    width: 52,
                    height: 52,
                    child: Tooltip(
                      message: place,
                      child: const Icon(
                        Icons.location_on,
                        size: 42,
                        color: Color(0xFFD5A84A),
                      ),
                    ),
                  ),
                ],
              ),
              RichAttributionWidget(
                attributions: const [
                  TextSourceAttribution('OpenStreetMap-Mitwirkende'),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF102235).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF27465D)),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 18,
                      color: Color(0xFFD5A84A),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amtliches Warngebiet',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
