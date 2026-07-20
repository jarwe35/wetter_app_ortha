# ORTHA METEO Ω – Drittanbieter und Softwarebibliotheken

## Zweck

Neben Datenquellen müssen auch alle Flutter- und Plattformbibliotheken
hinsichtlich ihrer Lizenz dokumentiert werden.

## Prüfverfahren

Vor einer Marktveröffentlichung:

1. `flutter pub deps` erfassen,
2. Lizenzdateien sämtlicher direkter und transitiver Pakete prüfen,
3. inkompatible oder unklare Lizenzen ersetzen,
4. erforderliche Lizenztexte in die Anwendung aufnehmen,
5. Android-, iOS-, Web- und macOS-Abhängigkeiten getrennt prüfen.

## Automatisch erzeugte Flutter-Lizenzen

Flutter stellt über `LicensePage` beziehungsweise
`showLicensePage(...)` Lizenzinformationen der eingebundenen Pakete bereit.

Diese Anzeige ersetzt nicht die Prüfung:

- externer Datenquellen,
- Kartenkacheln,
- Bild- und Audiodateien,
- Schriftarten,
- Logos,
- API-Nutzungsbedingungen,
- serverseitiger Dienste.

## Noch zu erfassen

- alle direkten Pakete aus `pubspec.yaml`,
- native Android-Abhängigkeiten,
- native Apple-Abhängigkeiten,
- Kartenanbieter,
- Benachrichtigungsdienste,
- Text-to-Speech-Komponenten,
- Audiodateien und Warntöne,
- ORTHA-Schrift- und Bildressourcen.

## Status

`PRÜFUNG OFFEN`
