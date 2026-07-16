# ORTHA METEO Ω – Sprint 0.12

## Ausgangsversion

- Release Candidate: `v0.11.0-rc1`
- Ausgangscommit: `0b68499`
- Entwicklungsbranch: `develop-v0.12.0`
- Flutter: `3.44.5`
- Dart: `3.12.2`

## Verifizierter Ausgangsstand

- DWD-Warnungen integriert
- BBK/MoWaS-Warnungen integriert
- GeoJSON-Warngebiete integriert
- Standortbezogene Warngebietserkennung integriert
- Amtliche Warntexte aufbereitet
- 236 Tests erfolgreich
- 2 Tests bewusst übersprungen
- Keine Analysefehler
- Sauberes Arbeitsverzeichnis

## Sprintziele

1. Smartphone-Layout für das Samsung Galaxy S26 Ultra optimieren.
2. 7-Tage-Vorschau vollständig überarbeiten.
3. 14-Tage-Vorschau vollständig überarbeiten.
4. Wetterdarstellung visuell und funktional professionalisieren.
5. Bestehende Warn-, Standort- und Wetterfunktionen vollständig erhalten.
6. Änderungen durch Formatierung, Analyse und vollständige Tests absichern.

## Arbeitsprinzip

Jeder Entwicklungsschritt wird einzeln geprüft, versioniert und zu GitHub übertragen.

## Umgesetzte Schritte

- Schritt 0.12.4: Open-Meteo-Datenabruf auf 14 Tage erweitert.
- Der API-Parameter `forecast_days` wird durch einen Test abgesichert.
- Die sichtbare Umschaltung zwischen 7 und 14 Tagen folgt separat.

- Schritt 0.12.5: Eigenständiges Modell für die Auswahl zwischen 7- und 14-Tage-Vorhersage eingeführt.
- Die Begrenzung der Prognosedaten ist generisch, unveränderbar und durch Tests abgesichert.
- Die sichtbare Umschaltung in der Tagesvorhersage folgt im nächsten UI-Schritt.

- Schritt 0.12.6: `DailyForecastCard` und `_ForecastValue` aus `main.dart` nach `lib/widgets/weather/daily_forecast_card.dart` ausgelagert.
- Die Auslagerung ist ein reines Struktur-Refactoring ohne beabsichtigte sichtbare oder funktionale Änderung.
- Die bestehende Tagesvorhersage bleibt vollständig erhalten.

- Schritt 0.12.7: `HourlyForecastCard` aus `main.dart` nach `lib/widgets/weather/hourly_forecast_card.dart` ausgelagert.
- Die Auslagerung ist ein reines Struktur-Refactoring ohne beabsichtigte sichtbare oder funktionale Änderung.
- Die bestehende Stundenprognose bleibt vollständig erhalten.

- Schritt 0.12.8: Grundgerüst der `OrthaWeatherIcon`-Engine eingeführt.
- WMO-Wettercodes werden zentral in normalisierte Wetterzustände übersetzt.
- Die neue Icon-Komponente unterstützt Skalierung, Tag/Nacht und eine erste Semi-3D-Grunddarstellung.
- Bestehende Ansichten verwenden die neue Komponente noch nicht.
