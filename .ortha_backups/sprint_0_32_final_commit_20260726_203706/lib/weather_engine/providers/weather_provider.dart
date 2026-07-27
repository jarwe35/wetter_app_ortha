import '../models/weather_timeline.dart';
import 'weather_provider_request.dart';

/// Allgemeiner Vertrag für Wetterdatenanbieter.
///
/// Provider liefern ausschließlich providerneutrale Modelle an die Engine.
/// Kartenbibliotheken, UI-Widgets und Renderingdetails sind hier ausdrücklich
/// nicht erlaubt.
abstract interface class WeatherProvider {
  /// Dauerhaft eindeutige Kennung des Providers.
  String get id;

  /// Menschlich lesbare Bezeichnung.
  String get displayName;

  /// Lädt eine Timeline für die angefragte Wetterebene.
  Future<WeatherTimeline> loadTimeline(WeatherProviderRequest request);

  /// Gibt an, ob der Provider die angefragte Ebene unterstützt.
  bool supports(WeatherProviderRequest request);
}
