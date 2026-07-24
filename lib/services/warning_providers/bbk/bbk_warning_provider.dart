import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import '../../../models/official_warning_geometry.dart';
import '../../../models/official_weather_warning.dart';
import '../../../models/warning_bridge/bbk_warning_geometry.dart';
import '../official_warning_provider.dart';
import 'bbk_geojson_parser.dart';
import 'bbk_map_data_parser.dart';
import 'bbk_warning_client.dart';
import 'bbk_warning_converter.dart';
import 'bbk_warning_lifecycle.dart';
import 'bbk_warning_parser.dart';

class BbkWarningProvider implements OfficialWarningProvider {
  final BbkWarningClient client;
  final BbkMapDataParser mapDataParser;
  final BbkWarningParser warningParser;
  final BbkGeoJsonParser geoJsonParser;
  final BbkWarningConverter converter;
  final BbkWarningLifecycle lifecycle;
  final DateTime Function() nowProvider;

  /// Technisches Gültigkeitsfenster bis zum nächsten BBK-Abruf.
  ///
  /// Es ist keine amtliche Ablaufzeit. Wenn das BBK kein `expires` liefert,
  /// bleibt eine in MapData vorhandene Warnung damit kurzfristig darstellbar.
  final Duration fallbackValidityDuration;

  BbkWarningProvider({
    required this.client,
    this.mapDataParser = const BbkMapDataParser(),
    this.warningParser = const BbkWarningParser(),
    this.geoJsonParser = const BbkGeoJsonParser(),
    this.converter = const BbkWarningConverter(),
    this.lifecycle = const BbkWarningLifecycle(),
    DateTime Function()? nowProvider,
    this.fallbackValidityDuration = const Duration(minutes: 30),
  }) : nowProvider = nowProvider ?? DateTime.now;

  @override
  String get providerId => 'bbk';

  @override
  String get sourceName => 'BBK / warnung.bund.de';

  @override
  bool supportsLocation({required double latitude, required double longitude}) {
    return latitude >= 47.0 &&
        latitude <= 55.5 &&
        longitude >= 5.5 &&
        longitude <= 15.5;
  }

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    if (!supportsLocation(latitude: latitude, longitude: longitude)) {
      return const [];
    }

    if (kDebugMode) {
      debugPrint(
        '[BBK] Abruf gestartet: '
        'latitude=$latitude, longitude=$longitude',
      );
    }

    final rawMapData = await client.fetchMapData();
    final parsedMapWarnings = mapDataParser.parse(rawMapData);
    final mapWarnings = lifecycle.selectCurrentMapWarnings(parsedMapWarnings);
    final now = nowProvider();

    if (kDebugMode) {
      debugPrint(
        '[BBK] MapData: ${parsedMapWarnings.length} Meldung(en) geparst, '
        '${mapWarnings.length} aktuell.',
      );
    }

    final relevantWarnings = <OfficialWeatherWarning>[];

    for (final mapWarning in mapWarnings) {
      if (kDebugMode) {
        debugPrint(
          '[BBK] Prüfe Meldung: '
          'id=${mapWarning.id}, start=${mapWarning.startDate}',
        );
      }
      try {
        final rawGeometry = await client.fetchWarningGeometry(mapWarning.id);

        final geometry = geoJsonParser.parse(rawGeometry);

        if (geometry.warningId != mapWarning.id) {
          if (kDebugMode) {
            debugPrint(
              '[BBK] Verworfen: Geometrie-ID stimmt nicht überein. '
              'mapId=${mapWarning.id}, geometryId=${geometry.warningId}',
            );
          }
          continue;
        }

        final containsLocation = geometry.contains(
          latitude: latitude,
          longitude: longitude,
        );

        final distanceToWarningAreaKm = _minimumDistanceToGeometryKm(
          latitude: latitude,
          longitude: longitude,
          geometry: geometry,
        );

        const warningProximityRadiusKm = 5.0;

        final isLocationRelevant =
            containsLocation ||
            distanceToWarningAreaKm <= warningProximityRadiusKm;

        if (kDebugMode) {
          debugPrint(
            '[BBK] Geometrieprüfung: '
            'id=${mapWarning.id}, '
            'polygone=${geometry.polygons.length}, '
            'contains=$containsLocation, '
            'entfernung=${distanceToWarningAreaKm.toStringAsFixed(2)} km, '
            'relevant=$isLocationRelevant',
          );

          for (
            var polygonIndex = 0;
            polygonIndex < geometry.polygons.length;
            polygonIndex++
          ) {
            final ring = geometry.polygons[polygonIndex].outerRing;

            if (ring.isEmpty) {
              debugPrint('[BBK] Polygon $polygonIndex enthält keine Punkte.');
              continue;
            }

            var minimumLatitude = ring.first.latitude;
            var maximumLatitude = ring.first.latitude;
            var minimumLongitude = ring.first.longitude;
            var maximumLongitude = ring.first.longitude;

            for (final point in ring.skip(1)) {
              if (point.latitude < minimumLatitude) {
                minimumLatitude = point.latitude;
              }

              if (point.latitude > maximumLatitude) {
                maximumLatitude = point.latitude;
              }

              if (point.longitude < minimumLongitude) {
                minimumLongitude = point.longitude;
              }

              if (point.longitude > maximumLongitude) {
                maximumLongitude = point.longitude;
              }
            }

            final insideBoundingBox =
                latitude >= minimumLatitude &&
                latitude <= maximumLatitude &&
                longitude >= minimumLongitude &&
                longitude <= maximumLongitude;

            debugPrint(
              '[BBK] Polygon $polygonIndex: '
              'punkte=${ring.length}, '
              'lat=$minimumLatitude..$maximumLatitude, '
              'lon=$minimumLongitude..$maximumLongitude, '
              'standortInBoundingBox=$insideBoundingBox',
            );

            debugPrint(
              '[BBK] Polygon $polygonIndex erster Punkt: '
              'lat=${ring.first.latitude}, '
              'lon=${ring.first.longitude}',
            );
          }
        }

        if (!isLocationRelevant) {
          if (kDebugMode) {
            debugPrint(
              '[BBK] Verworfen: Standort liegt weder im Warngebiet '
              'noch innerhalb des Sicherheitsradius. '
              'id=${mapWarning.id}, '
              'entfernung=${distanceToWarningAreaKm.toStringAsFixed(2)} km',
            );
          }
          continue;
        }

        if (!containsLocation && kDebugMode) {
          debugPrint(
            '[BBK] Übernahme über Sicherheitsradius: '
            'id=${mapWarning.id}, '
            'entfernung=${distanceToWarningAreaKm.toStringAsFixed(2)} km',
          );
        }

        final rawDetail = await client.fetchWarningDetail(mapWarning.id);

        if (rawDetail is! Map<String, dynamic>) {
          if (kDebugMode) {
            debugPrint(
              '[BBK] Verworfen: Detailantwort besitzt '
              'kein gültiges JSON-Objekt. id=${mapWarning.id}',
            );
          }
          continue;
        }

        final warning = warningParser.parse(rawDetail);
        final identifierMatches = warning.identifier == mapWarning.id;
        final isActive = lifecycle.isDetailActive(warning, moment: now);

        if (kDebugMode) {
          debugPrint(
            '[BBK] Detail geladen: '
            'id=${warning.identifier}, '
            'titel="${warning.headline}", '
            'severity=${warning.severity}, '
            'sender="${warning.sender}", '
            'identifierMatches=$identifierMatches, '
            'active=$isActive',
          );
        }

        if (!identifierMatches || !isActive) {
          if (kDebugMode) {
            debugPrint(
              '[BBK] Verworfen: Detailmeldung ist ungültig '
              'oder nicht aktiv. id=${mapWarning.id}',
            );
          }
          continue;
        }

        final converted = converter.convert(
          warning,
          fallbackValidFrom: mapWarning.startDate,
          fallbackValidUntil: now.add(fallbackValidityDuration),
          geometry: OfficialWarningGeometry(
            polygons: geometry.polygons
                .map(
                  (polygon) => polygon.outerRing
                      .map((point) => [point.latitude, point.longitude])
                      .toList(growable: false),
                )
                .toList(growable: false),
          ),
        );

        if (kDebugMode) {
          debugPrint('==============================');
          debugPrint('[BBK] ZEITDIAGNOSE');
          debugPrint(
            'providerNow=${now.toIso8601String()} '
            'utc=${now.toUtc().toIso8601String()}',
          );
          debugPrint(
            'systemNow=${DateTime.now().toIso8601String()} '
            'utc=${DateTime.now().toUtc().toIso8601String()}',
          );
          debugPrint('warning.sent=${warning.sent?.toIso8601String()}');
          debugPrint(
            'warning.effective=${warning.effective?.toIso8601String()}',
          );
          debugPrint('warning.expires=${warning.expires?.toIso8601String()}');
          debugPrint(
            'converted.validFrom='
            '${converted.validFrom.toIso8601String()}',
          );
          debugPrint(
            'converted.validUntil='
            '${converted.validUntil.toIso8601String()}',
          );
          debugPrint('converted.isActive=${converted.isActive}');
          debugPrint('==============================');
        }

        relevantWarnings.add(converted);

        if (kDebugMode) {
          debugPrint(
            '[BBK] Übernommen: '
            'id=${converted.id}, '
            'titel="${converted.title}", '
            'quelle="${converted.source}", '
            'severity=${converted.severity}, '
            'aktiv=${converted.isActive}',
          );
        }
      } on BbkWarningClientException catch (error) {
        if (kDebugMode) {
          debugPrint('[BBK] Clientfehler bei id=${mapWarning.id}: $error');
        }

        // Eine einzelne defekte oder vorübergehend nicht erreichbare Meldung
        // darf die übrigen amtlichen Warnmeldungen nicht blockieren.
        continue;
      } on FormatException catch (error) {
        if (kDebugMode) {
          debugPrint('[BBK] Formatfehler bei id=${mapWarning.id}: $error');
        }

        // Beschädigte Einzelmeldungen oder Geometrien werden übersprungen.
        continue;
      }
    }

    if (kDebugMode) {
      debugPrint(
        '[BBK] Abruf abgeschlossen: '
        '${relevantWarnings.length} relevante Meldung(en) '
        'für latitude=$latitude, longitude=$longitude.',
      );
    }

    return List<OfficialWeatherWarning>.unmodifiable(relevantWarnings);
  }

  double _minimumDistanceToGeometryKm({
    required double latitude,
    required double longitude,
    required BbkWarningGeometry geometry,
  }) {
    var minimumDistanceKm = double.infinity;

    for (final polygon in geometry.polygons) {
      final ring = polygon.outerRing;

      for (final point in ring) {
        final distanceKm = _haversineDistanceKm(
          latitude1: latitude,
          longitude1: longitude,
          latitude2: point.latitude,
          longitude2: point.longitude,
        );

        if (distanceKm < minimumDistanceKm) {
          minimumDistanceKm = distanceKm;
        }
      }
    }

    return minimumDistanceKm;
  }

  double _haversineDistanceKm({
    required double latitude1,
    required double longitude1,
    required double latitude2,
    required double longitude2,
  }) {
    const earthRadiusKm = 6371.0;

    final latitudeDelta = _degreesToRadians(latitude2 - latitude1);
    final longitudeDelta = _degreesToRadians(longitude2 - longitude1);

    final firstLatitudeRadians = _degreesToRadians(latitude1);
    final secondLatitudeRadians = _degreesToRadians(latitude2);

    final haversine =
        math.sin(latitudeDelta / 2) * math.sin(latitudeDelta / 2) +
        math.cos(firstLatitudeRadians) *
            math.cos(secondLatitudeRadians) *
            math.sin(longitudeDelta / 2) *
            math.sin(longitudeDelta / 2);

    final angularDistance =
        2 * math.atan2(math.sqrt(haversine), math.sqrt(1 - haversine));

    return earthRadiusKm * angularDistance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }
}
