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

- Schritt 0.12.9: Die Stunden- und Tagesprognose verwenden nun `OrthaWeatherIcon`.
- Die bisherigen flachen Material-Wettersymbole wurden dort durch die skalierbare Semi-3D-Darstellung ersetzt.
- Wettercode und zugängliche Zustandsbeschreibung werden weiterhin vollständig übergeben.
- Die zentrale aktuelle Wetterkarte wird in einem getrennten Schritt umgestellt.

- Schritt 0.12.10: `WeatherCard` und `_WeatherMetaItem` nach `lib/widgets/weather/current_weather_card.dart` ausgelagert.
- Reines Struktur-Refactoring ohne beabsichtigte sichtbare oder funktionale Änderung.

- Schritt 0.12.11: Die aktuelle Wetterkarte verwendet nun ebenfalls `OrthaWeatherIcon`.
- Das bisherige flache Material-Wettersymbol wurde durch die skalierbare Semi-3D-Darstellung ersetzt.

- Schritt 0.12.12: Die aktuelle Wetterkarte reagiert adaptiv auf schmale und breite Displaygrößen.
- Auf sehr schmalen Ansichten werden Wettersymbol und Temperatur untereinander dargestellt.
- Das Samsung Galaxy S26 Ultra bleibt Referenzgerät, die Layoutlogik ist jedoch nicht gerätespezifisch.

- Schritt 0.12.13: Wettermetadaten reagieren adaptiv auf die verfügbare Breite.
- Auf schmalen Displays werden gefühlte Temperatur, Luftfeuchtigkeit und Wind übersichtlich untereinander dargestellt.

- Schritt 0.12.14: Die Tagesvorhersage besitzt eine sichtbare Umschaltung zwischen 7 und 14 Tagen.
- Standardmäßig bleibt die 7-Tage-Ansicht ausgewählt.
- Der Datenabruf bleibt bei 14 Tagen; die Auswahl steuert ausschließlich die Darstellung.

- Schritt 0.12.15: Die Tageskarten wurden für sehr schmale, normale und breite Ansichten weiter optimiert.
- Symbolgrößen und Abstände passen sich der verfügbaren Kartenbreite an.
- Die Darstellung bleibt geräteunabhängig und verhindert unnötige Platzprobleme auf kleinen Smartphones.

- Schritt 0.12.16: Die Karten der 24-Stunden-Prognose reagieren adaptiv auf schmale und normale Displaybreiten.
- Kartenbreite, Innenabstand, Symbolgröße und Gesamthöhe werden auf sehr kleinen Smartphones reduziert.
