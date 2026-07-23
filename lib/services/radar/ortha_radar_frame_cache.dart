import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

/// Ergebnis einer abgeschlossenen Vorladephase.
class OrthaRadarPreloadResult {
  final int requestedTileCount;
  final int loadedTileCount;
  final int failedTileCount;

  const OrthaRadarPreloadResult({
    required this.requestedTileCount,
    required this.loadedTileCount,
    required this.failedTileCount,
  });

  bool get isComplete =>
      requestedTileCount > 0 &&
      loadedTileCount == requestedTileCount &&
      failedTileCount == 0;

  double get progress {
    if (requestedTileCount == 0) {
      return 0;
    }

    return loadedTileCount / requestedTileCount;
  }
}

/// Speicherbasierter Cache für vorbereitete Radar-Kacheln.
///
/// Die Klasse lädt Radarressourcen kontrolliert vor, damit sie während einer
/// späteren Bildabfolge nicht erneut aus dem Netz angefordert werden müssen.
class OrthaRadarFrameCache {
  final http.Client httpClient;
  final Duration requestTimeout;
  final int maximumConcurrentRequests;

  final Map<Uri, Uint8List> _tileBytes = <Uri, Uint8List>{};
  final Map<Uri, Future<Uint8List?>> _pendingRequests =
      <Uri, Future<Uint8List?>>{};

  bool _isDisposed = false;

  OrthaRadarFrameCache({
    required this.httpClient,
    this.requestTimeout = const Duration(seconds: 12),
    this.maximumConcurrentRequests = 4,
  }) : assert(maximumConcurrentRequests > 0);

  int get cachedTileCount => _tileBytes.length;

  bool contains(Uri uri) => _tileBytes.containsKey(uri);

  Uint8List? read(Uri uri) => _tileBytes[uri];

  Future<Uint8List?> loadTile(Uri uri) {
    _ensureNotDisposed();

    final cached = _tileBytes[uri];

    if (cached != null) {
      return Future<Uint8List?>.value(cached);
    }

    final pending = _pendingRequests[uri];

    if (pending != null) {
      return pending;
    }

    final request = _loadTileFromNetwork(uri);
    _pendingRequests[uri] = request;

    return request.whenComplete(() {
      if (identical(_pendingRequests[uri], request)) {
        _pendingRequests.remove(uri);
      }
    });
  }

  Future<OrthaRadarPreloadResult> preload(
    Iterable<Uri> tileUris, {
    void Function(int loaded, int total)? onProgress,
  }) async {
    _ensureNotDisposed();

    final uniqueUris = tileUris.toSet().toList(growable: false);

    if (uniqueUris.isEmpty) {
      return const OrthaRadarPreloadResult(
        requestedTileCount: 0,
        loadedTileCount: 0,
        failedTileCount: 0,
      );
    }

    var nextIndex = 0;
    var loaded = 0;
    var failed = 0;

    Future<void> worker() async {
      while (true) {
        final currentIndex = nextIndex;

        if (currentIndex >= uniqueUris.length) {
          return;
        }

        nextIndex++;
        final uri = uniqueUris[currentIndex];

        try {
          final bytes = await loadTile(uri);

          if (bytes == null || bytes.isEmpty) {
            failed++;
          } else {
            loaded++;
          }
        } catch (_) {
          failed++;
        }

        onProgress?.call(loaded + failed, uniqueUris.length);
      }
    }

    final workerCount = maximumConcurrentRequests.clamp(1, uniqueUris.length);

    await Future.wait(
      List<Future<void>>.generate(workerCount, (_) => worker()),
    );

    return OrthaRadarPreloadResult(
      requestedTileCount: uniqueUris.length,
      loadedTileCount: loaded,
      failedTileCount: failed,
    );
  }

  void retainOnly(Iterable<Uri> requiredUris) {
    _ensureNotDisposed();

    final required = requiredUris.toSet();
    _tileBytes.removeWhere((uri, _) => !required.contains(uri));
  }

  void clear() {
    _ensureNotDisposed();
    _tileBytes.clear();
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }

    _isDisposed = true;
    _tileBytes.clear();
    _pendingRequests.clear();
  }

  Future<Uint8List?> _loadTileFromNetwork(Uri uri) async {
    final response = await httpClient.get(uri).timeout(requestTimeout);

    if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
      return null;
    }

    final bytes = Uint8List.fromList(response.bodyBytes);
    _tileBytes[uri] = bytes;

    return bytes;
  }

  void _ensureNotDisposed() {
    if (_isDisposed) {
      throw StateError('OrthaRadarFrameCache wurde bereits freigegeben.');
    }
  }
}
