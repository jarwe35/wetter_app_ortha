import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

class RainViewerRadarException implements Exception {
  final String message;

  const RainViewerRadarException(this.message);

  @override
  String toString() => 'RainViewerRadarException: $message';
}

class RainViewerRadarFrame {
  final DateTime time;
  final String path;

  const RainViewerRadarFrame({required this.time, required this.path});
}

class RainViewerRadarMetadata {
  final String host;
  final DateTime generatedAt;
  final List<RainViewerRadarFrame> frames;

  const RainViewerRadarMetadata({
    required this.host,
    required this.generatedAt,
    required this.frames,
  });

  RainViewerRadarFrame get latestFrame {
    if (frames.isEmpty) {
      throw const RainViewerRadarException(
        'RainViewer hat keine Radarframes geliefert.',
      );
    }

    return frames.last;
  }

  String tileUrlTemplate({
    required RainViewerRadarFrame frame,
    int tileSize = 256,
    int colorScheme = 2,
    bool smooth = true,
    bool showSnow = true,
  }) {
    final normalizedHost = host.endsWith('/')
        ? host.substring(0, host.length - 1)
        : host;

    final normalizedPath = frame.path.startsWith('/')
        ? frame.path
        : '/${frame.path}';

    final smoothValue = smooth ? 1 : 0;
    final snowValue = showSnow ? 1 : 0;

    return '$normalizedHost$normalizedPath/'
        '$tileSize/{z}/{x}/{y}/'
        '$colorScheme/${smoothValue}_$snowValue.png';
  }
}

class RainViewerRadarService {
  static final Uri defaultMetadataUri = Uri.parse(
    'https://api.rainviewer.com/public/weather-maps.json',
  );

  final http.Client httpClient;
  final Uri metadataUri;
  final Duration requestTimeout;
  final Duration cacheDuration;

  RainViewerRadarMetadata? _cachedMetadata;
  DateTime? _cachedAt;
  Future<RainViewerRadarMetadata>? _pendingRequest;

  RainViewerRadarService({
    required this.httpClient,
    Uri? metadataUri,
    this.requestTimeout = const Duration(seconds: 15),
    this.cacheDuration = const Duration(minutes: 5),
  }) : metadataUri = metadataUri ?? defaultMetadataUri;

  Future<RainViewerRadarMetadata> fetchMetadata({bool forceRefresh = false}) {
    final cachedMetadata = _cachedMetadata;
    final cachedAt = _cachedAt;

    if (!forceRefresh &&
        cachedMetadata != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < cacheDuration) {
      return Future<RainViewerRadarMetadata>.value(cachedMetadata);
    }

    final pendingRequest = _pendingRequest;

    if (!forceRefresh && pendingRequest != null) {
      return pendingRequest;
    }

    final request = _fetchMetadataFromNetwork();
    _pendingRequest = request;

    return request.whenComplete(() {
      if (identical(_pendingRequest, request)) {
        _pendingRequest = null;
      }
    });
  }

  Future<RainViewerRadarMetadata> _fetchMetadataFromNetwork() async {
    http.Response response;

    try {
      response = await httpClient.get(metadataUri).timeout(requestTimeout);
    } on TimeoutException {
      throw const RainViewerRadarException(
        'Der Radarserver hat nicht rechtzeitig geantwortet.',
      );
    } catch (error) {
      throw RainViewerRadarException(
        'Netzwerkfehler beim Abruf der Radar-Metadaten: $error',
      );
    }

    if (response.statusCode != 200) {
      throw RainViewerRadarException(
        'Radar-Metadaten konnten nicht geladen werden '
        '(HTTP ${response.statusCode}).',
      );
    }

    if (response.body.trim().isEmpty) {
      throw const RainViewerRadarException(
        'RainViewer hat keine Radar-Metadaten geliefert.',
      );
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(response.body);
    } catch (error) {
      throw RainViewerRadarException(
        'Radar-Metadaten enthalten ungültiges JSON: $error',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const RainViewerRadarException(
        'Radar-Metadaten besitzen ein ungültiges Format.',
      );
    }

    final host = decoded['host'];
    final generated = decoded['generated'];
    final radar = decoded['radar'];

    if (host is! String || host.trim().isEmpty) {
      throw const RainViewerRadarException(
        'In den Radar-Metadaten fehlt der Kachelserver.',
      );
    }

    if (generated is! num) {
      throw const RainViewerRadarException(
        'In den Radar-Metadaten fehlt der Erzeugungszeitpunkt.',
      );
    }

    if (radar is! Map<String, dynamic>) {
      throw const RainViewerRadarException(
        'In den Radar-Metadaten fehlen die Radardaten.',
      );
    }

    final past = radar['past'];

    if (past is! List) {
      throw const RainViewerRadarException(
        'In den Radar-Metadaten fehlen vergangene Radarframes.',
      );
    }

    final frames = <RainViewerRadarFrame>[];

    for (final entry in past) {
      if (entry is! Map<String, dynamic>) {
        continue;
      }

      final time = entry['time'];
      final path = entry['path'];

      if (time is! num || path is! String || path.trim().isEmpty) {
        continue;
      }

      frames.add(
        RainViewerRadarFrame(
          time: DateTime.fromMillisecondsSinceEpoch(
            time.toInt() * 1000,
            isUtc: true,
          ),
          path: path,
        ),
      );
    }

    frames.sort((a, b) => a.time.compareTo(b.time));

    if (frames.isEmpty) {
      throw const RainViewerRadarException(
        'RainViewer hat keine verwendbaren Radarframes geliefert.',
      );
    }

    final metadata = RainViewerRadarMetadata(
      host: host,
      generatedAt: DateTime.fromMillisecondsSinceEpoch(
        generated.toInt() * 1000,
        isUtc: true,
      ),
      frames: List.unmodifiable(frames),
    );

    _cachedMetadata = metadata;
    _cachedAt = DateTime.now();

    return metadata;
  }
}
