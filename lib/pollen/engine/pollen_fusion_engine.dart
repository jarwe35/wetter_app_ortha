import '../../models/pollen_forecast.dart';
import '../models/pollen_provider.dart';

/// Zentrale ORTHA-Pipeline für Pollendaten.
///
/// In Phase 1 wird der erste erfolgreich antwortende Provider verwendet.
/// Die Struktur erlaubt später eine echte Zusammenführung mehrerer Quellen.
class PollenFusionEngine {
  const PollenFusionEngine({required this.providers});

  final List<PollenProvider> providers;

  Future<PollenForecast> loadForecast({
    required double latitude,
    required double longitude,
  }) async {
    if (providers.isEmpty) {
      throw const PollenProviderException(
        providerId: 'fusion-engine',
        message: 'Es wurde keine Pollendatenquelle konfiguriert.',
      );
    }

    final errors = <String>[];

    for (final provider in providers) {
      try {
        return await provider.loadForecast(
          latitude: latitude,
          longitude: longitude,
        );
      } on PollenProviderException catch (error) {
        errors.add('${provider.displayName}: ${error.message}');
      } on Exception catch (error) {
        errors.add('${provider.displayName}: $error');
      }
    }

    throw PollenProviderException(
      providerId: 'fusion-engine',
      message:
          'Keine Pollendatenquelle konnte eine Vorhersage liefern. '
          '${errors.join(' | ')}',
    );
  }
}
