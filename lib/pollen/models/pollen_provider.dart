import '../../models/pollen_forecast.dart';

/// Einheitlicher Vertrag für alle Pollendatenquellen.
///
/// Weitere Quellen können später ergänzt werden, ohne dass die Oberfläche
/// oder der bestehende PollenService grundlegend verändert werden müssen.
abstract interface class PollenProvider {
  /// Technische Kennung der Datenquelle.
  String get id;

  /// Anzeigename der Datenquelle.
  String get displayName;

  /// Lädt eine Pollenvorhersage für die angegebenen Koordinaten.
  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  });
}

/// Einheitliche Ausnahme für Fehler innerhalb der Pollen-Pipeline.
class PollenProviderException implements Exception {
  const PollenProviderException({
    required this.providerId,
    required this.message,
    this.cause,
  });

  final String providerId;
  final String message;
  final Object? cause;

  @override
  String toString() {
    return 'PollenProviderException('
        'provider: $providerId, '
        'message: $message'
        ')';
  }
}
