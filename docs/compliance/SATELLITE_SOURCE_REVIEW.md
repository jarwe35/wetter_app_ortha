# ORTHA METEO Ω – Satellitenquellenprüfung

Stand: 20. Juli 2026

## Bestehende Satellitenansicht

### Technische Quelle

Esri World Imagery:

`https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}`

### Tatsächliche Funktion

Die Quelle stellt eine fotografische Kartenbasisebene bereit.

Sie liefert in der gegenwärtigen ORTHA-Implementierung:

- keine meteorologische Wolkenanalyse,
- keine zeitlich aufeinanderfolgenden Satellitenframes,
- keinen Infrarotkanal,
- keinen Wasserdampfkanal,
- keine erkennbare Aufnahmezeit,
- keine Wetteranimation.

### ORTHA-Bewertung

Die bestehende Seite darf nicht als meteorologischer Live-Satellit bezeichnet
werden.

Status:

`ZU ERSETZEN`

---

## Bevorzugte Prüfreihenfolge

### 1. Deutscher Wetterdienst

Zu prüfen:

- offizieller Open-Data-Satellitenbereich,
- verfügbare Wolkenprodukte,
- Aktualisierungsintervall,
- Dateiformat,
- räumliche Abdeckung,
- Eignung für mobile Karten,
- Attribution nach CC BY 4.0.

Vorläufiger Status:

`TECHNISCHE PRÜFUNG`

### 2. EUMETSAT

Zu prüfen:

- EUMETView / OGC-Schnittstellen,
- Meteosat- und MTG-Produkte,
- Registrierung,
- API-Zugang,
- Redistribution,
- kommerzielle Nutzbarkeit,
- Attribution,
- mögliche Gebühren.

Vorläufiger Status:

`LIZENZ- UND TECHNIKPRÜFUNG`

### 3. Copernicus

Copernicus Sentinel-Daten sind grundsätzlich auch für kommerzielle Nutzer
zugänglich. Für ein meteorologisches Echtzeit-Wolkencenter ist jedoch zu
prüfen, ob Aktualisierungsfrequenz, Prozessierung und API-Quoten geeignet sind.

Vorläufiger Status:

`OPTIONALE ERGÄNZUNG`

---

## Freigaberegel

Eine Satellitenquelle wird erst in ORTHA integriert, wenn Folgendes
dokumentiert ist:

- konkrete Produktbezeichnung,
- offizieller Endpunkt,
- Lizenz,
- kommerzielle Nutzbarkeit,
- Quellenhinweis,
- Aktualisierungsintervall,
- technische Verfügbarkeit,
- erwartete laufende Kosten,
- Speicherung und Caching,
- Ausfallverhalten.

