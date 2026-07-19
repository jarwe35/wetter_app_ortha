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

    final location = LatLng(latitude, longitude);

    final locationIsInside = geometry.contains(
      latitude: latitude,
      longitude: longitude,
    );

    final cameraCoordinates = <LatLng>[
      location,
      ...polygons.expand((polygon) => polygon.points),
    ];

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
            key: ValueKey('warning-map-${warning.id}-$latitude-$longitude'),
            options: MapOptions(
              initialCameraFit: CameraFit.coordinates(
                coordinates: cameraCoordinates,
                padding: const EdgeInsets.fromLTRB(28, 76, 28, 28),
                minZoom: 5,
                maxZoom: 13,
              ),
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
            bottom: 10,
            left: 10,
            right: 10,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF102235).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF41627A)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      locationIsInside
                          ? Icons.location_on_outlined
                          : Icons.location_off_outlined,
                      size: 21,
                      color: const Color(0xFFFFC83D),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        locationIsInside
                            ? 'Du befindest dich im Warnbereich.'
                            : 'Du befindest dich außerhalb des Warnbereichs.',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF102235).withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF41627A)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 21,
                      color: Color(0xFFFFC83D),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Angezeigter Bereich',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 23,
                      color: Colors.white,
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
