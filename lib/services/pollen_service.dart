import 'package:http/http.dart' as http;

import '../models/pollen_forecast.dart';
import '../pollen/engine/pollen_fusion_engine.dart';
import '../pollen/models/pollen_provider.dart';
import '../pollen/providers/open_meteo_pollen_provider.dart';

/// Öffentliche, abwärtskompatible Ausnahme für die bestehende Oberfläche.
class PollenServiceException implements Exception {
  const PollenServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Kompatible Fassade für die ORTHA Pollen Engine.
///
/// Bestehende Aufrufer können den Service weiterhin ausschließlich mit einem
/// HTTP-Client erzeugen. Zusätzliche Provider lassen sich kontrolliert vor
/// Open-Meteo einordnen.
///
/// Damit kann beispielsweise der DWD-Provider für Orte verwendet werden, deren
/// DWD-Pollenregion bereits belastbar bestimmt wurde. Open-Meteo bleibt als
/// nachgelagerte Datenquelle erhalten.
class PollenService {
  PollenService({
    http.Client? client,
    PollenFusionEngine? engine,
    List<PollenProvider> preferredProviders = const [],
  }) : _engine =
           engine ??
           PollenFusionEngine(
             providers: List.unmodifiable([
               ...preferredProviders,
               OpenMeteoPollenProvider(client: client),
             ]),
           );

  static const List<PollenType> supportedTypes =
      OpenMeteoPollenProvider.supportedTypes;

  final PollenFusionEngine _engine;

  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) async {
    try {
      return await _engine.loadForecast(
        latitude: latitude,
        longitude: longitude,
      );
    } on PollenProviderException catch (error) {
      throw PollenServiceException(error.message);
    } on Exception catch (error) {
      throw PollenServiceException(
        'Die Pollenflugvorhersage konnte nicht geladen werden: $error',
      );
    }
  }

  /// Abwärtskompatibler Einstiegspunkt für bestehende Parser-Tests.
  static PollenForecast parseForecast(Map<String, dynamic> json) {
    try {
      return OpenMeteoPollenProvider.parseForecast(json);
    } on PollenProviderException catch (error) {
      throw PollenServiceException(error.message);
    }
  }
}
