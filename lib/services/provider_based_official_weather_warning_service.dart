import '../models/official_weather_warning.dart';
import 'official_weather_warning_service.dart';
import 'warning_providers/official_warning_provider.dart';

class ProviderBasedOfficialWeatherWarningService
    implements OfficialWeatherWarningService {
  final List<OfficialWarningProvider> providers;

  const ProviderBasedOfficialWeatherWarningService({required this.providers});

  @override
  bool supportsLocation({required double latitude, required double longitude}) {
    return providers.any(
      (provider) =>
          provider.supportsLocation(latitude: latitude, longitude: longitude),
    );
  }

  @override
  Future<List<OfficialWeatherWarning>> fetchWarnings({
    required double latitude,
    required double longitude,
  }) async {
    final supportedProviders = providers.where(
      (provider) =>
          provider.supportsLocation(latitude: latitude, longitude: longitude),
    );

    final warnings = <OfficialWeatherWarning>[];

    for (final provider in supportedProviders) {
      final providerWarnings = await provider.fetchWarnings(
        latitude: latitude,
        longitude: longitude,
      );

      warnings.addAll(providerWarnings);
    }

    warnings.sort((a, b) => b.severity.index.compareTo(a.severity.index));

    return warnings;
  }
}
