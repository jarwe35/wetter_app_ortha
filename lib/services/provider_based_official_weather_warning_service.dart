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
    final supportedProviders = providers
        .where(
          (provider) => provider.supportsLocation(
            latitude: latitude,
            longitude: longitude,
          ),
        )
        .toList(growable: false);

    final warnings = <OfficialWeatherWarning>[];

    Object? firstError;
    StackTrace? firstStackTrace;
    var successfulProviderCount = 0;

    for (final provider in supportedProviders) {
      try {
        final providerWarnings = await provider.fetchWarnings(
          latitude: latitude,
          longitude: longitude,
        );

        warnings.addAll(providerWarnings);
        successfulProviderCount++;

        print(
          'Warnquelle ${provider.sourceName}: '
          '${providerWarnings.length} Meldung(en) geladen.',
        );
      } catch (error, stackTrace) {
        firstError ??= error;
        firstStackTrace ??= stackTrace;

        print('Warnquelle ${provider.sourceName} fehlgeschlagen: $error');
      }
    }

    if (supportedProviders.isNotEmpty &&
        successfulProviderCount == 0 &&
        firstError != null &&
        firstStackTrace != null) {
      Error.throwWithStackTrace(firstError, firstStackTrace);
    }

    warnings.sort((first, second) {
      final severityComparison = _severityRank(
        second.severity,
      ).compareTo(_severityRank(first.severity));

      if (severityComparison != 0) {
        return severityComparison;
      }

      return second.validFrom.compareTo(first.validFrom);
    });

    return List<OfficialWeatherWarning>.unmodifiable(warnings);
  }

  int _severityRank(OfficialWarningSeverity severity) {
    switch (severity) {
      case OfficialWarningSeverity.extreme:
        return 4;
      case OfficialWarningSeverity.severe:
        return 3;
      case OfficialWarningSeverity.moderate:
        return 2;
      case OfficialWarningSeverity.minor:
        return 1;
      case OfficialWarningSeverity.unknown:
        return 0;
    }
  }
}
