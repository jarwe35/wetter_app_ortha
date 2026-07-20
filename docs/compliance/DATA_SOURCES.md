# ORTHA METEO Ω – Datenquellenregister

Stand: 20. Juli 2026

## Statusübersicht

| Quelle | Verwendung | Demonstrator | Marktversion | Attribution | Status |
|---|---|---:|---:|---|---|
| Open-Meteo Weather API | Wetterprognosen und Messwerte | Ja | Vertrag/Tarif erforderlich | Open-Meteo und ggf. Ursprungsdaten | NUR DEMONSTRATOR |
| Open-Meteo Air Quality API | Luftqualität und Pollen | Ja | Vertrag/Tarif erforderlich | Open-Meteo und ggf. Copernicus | NUR DEMONSTRATOR |
| Deutscher Wetterdienst Open Data | Wetterwarnungen und Geodaten | Ja | grundsätzlich möglich | DWD, CC BY 4.0 | BEDINGT FREIGEGEBEN |
| BBK/NINA/MoWaS | Bevölkerungsschutzwarnungen | Ja, nach technischer Prüfung | noch ungeklärt | Absender und BBK-Kontext | PRÜFUNG OFFEN |
| OpenStreetMap-Daten | Karten- und Ortsbezug | Ja | grundsätzlich möglich | © OpenStreetMap-Mitwirkende | BEDINGT FREIGEGEBEN |
| Öffentlicher OSM-Tileserver | Kartenkacheln | begrenzt | nicht als Produktionsinfrastruktur einplanen | sichtbar auf der Karte | ZU ERSETZEN |
| ESRI World Imagery | aktueller Satelliten-Kartenhintergrund | nur vorläufig | nicht freigegeben | abhängig vom konkreten Dienst | PRÜFUNG OFFEN |
| Meteorologische Satellitendaten | geplantes Satellite Center | noch nicht gewählt | noch nicht gewählt | quellenabhängig | PRÜFUNG OFFEN |
| Niederschlagsradar | geplantes Live-Radar | noch nicht gewählt | noch nicht gewählt | quellenabhängig | PRÜFUNG OFFEN |
| Windkarten | geplantes Wind Center | noch nicht gewählt | noch nicht gewählt | quellenabhängig | PRÜFUNG OFFEN |
| Seewetter | geplantes Marine Center | noch nicht gewählt | noch nicht gewählt | quellenabhängig | PRÜFUNG OFFEN |

---

## 1. Open-Meteo Weather API

### Verwendung in ORTHA

- aktuelle Wetterdaten,
- Stunden- und Tagesprognosen,
- Wind, Temperatur, Niederschlag und weitere Wetterparameter,
- gegebenenfalls Geocoding.

### Vorläufige Bewertung

Die frei zugängliche Open-Meteo-API ist nach den veröffentlichten Angaben für
nichtkommerzielle Evaluation und Prototyping vorgesehen. Für kommerzielle
Nutzung ist ein kommerzieller Zugang beziehungsweise eine gesondert zulässige
Betriebsform einzuplanen.

### ORTHA-Entscheidung

- Demonstrator: zulässig im Rahmen der veröffentlichten Bedingungen.
- Marktversion: vor Veröffentlichung auf kommerziellen Tarif oder rechtssichere
  Eigenhosting-Lösung umstellen.
- Attribution muss in der App sichtbar dokumentiert werden.
- Abrufmengen müssen vor Veröffentlichung neu bewertet werden.

### Status

`NUR DEMONSTRATOR`

---

## 2. Open-Meteo Air Quality API

### Verwendung in ORTHA

- Pollenprognose,
- Feinstaub,
- Ozon,
- weitere Luftqualitätsparameter.

### Vorläufige Bewertung

Die kostenlose Nutzung ist für nichtkommerzielle Zwecke vorgesehen.
Für eine kommerzielle Marktversion ist ein geeigneter Vertrag, Tarif oder eine
zulässige Eigenhosting-Lösung erforderlich.

Einzelne Datensätze können zusätzliche Ursprungsattributionen verlangen,
beispielsweise einen Hinweis auf Copernicus.

### ORTHA-Entscheidung

- Pollenübersicht im Demonstrator nutzbar.
- Vor Marktstart kommerzielle Nutzungsform verbindlich festlegen.
- Datenherkunft in der App und in den Lizenzhinweisen anzeigen.

### Status

`NUR DEMONSTRATOR`

---

## 3. Deutscher Wetterdienst – Open Data

### Verwendung in ORTHA

- amtliche Wetterwarnungen,
- Warngebiete,
- CAP- und GeoJSON-Daten,
- gegebenenfalls Radar- und weitere offene Wetterprodukte.

### Vorläufige Bewertung

DWD-Open-Data darf nach den offiziellen Hinweisen unter CC BY 4.0 mit
Quellenvermerk weiterverwendet werden. Dennoch muss jedes konkret verwendete
Produkt einzeln daraufhin geprüft werden, ob zusätzliche Produktbedingungen,
Abrufgrenzen oder technische Einschränkungen bestehen.

### Vorgesehener Quellenvermerk

`Quelle: Deutscher Wetterdienst (DWD), bereitgestellt unter CC BY 4.0.`

Bei bearbeiteten Daten zusätzlich:

`Bearbeitung und Aufbereitung: ORTHA METEO Ω.`

### Status

`BEDINGT FREIGEGEBEN`

Die endgültige Freigabe erfolgt erst, nachdem sämtliche konkret verwendeten
DWD-Produkte im Register einzeln erfasst wurden.

---

## 4. BBK / Warn-App NINA / MoWaS

### Verwendung in ORTHA

- amtliche Bevölkerungsschutzwarnungen,
- regionale Gefahrenmeldungen,
- Absender- und Ereignisinformationen.

### Vorläufige Bewertung

Das BBK beschreibt die bereitgestellten Warninhalte und deren Herkunft.
Eine eindeutige allgemeine Freigabe für die dauerhafte kommerzielle Nutzung
einer nicht offiziell dokumentierten technischen Schnittstelle ist in dieser
Dokumentation derzeit jedoch noch nicht belegt.

### ORTHA-Entscheidung

- keine Behauptung einer vollständigen kommerziellen Freigabe,
- konkrete technische Schnittstelle und Nutzungsbedingungen gesondert prüfen,
- Absender amtlicher Warnungen unverändert erhalten,
- Warntexte nicht sinnentstellend verändern,
- gegebenenfalls schriftliche Klärung mit dem BBK einholen.

### Status

`PRÜFUNG OFFEN`

---

## 5. OpenStreetMap

### Verwendung in ORTHA

- Basiskarte,
- räumliche Orientierung,
- Standortdarstellung.

### Anforderungen

- Attribution muss gut lesbar und in Kartennähe sichtbar sein.
- Mindestens: `© OpenStreetMap-Mitwirkende`
- Die Attribution darf nicht hinter einem Menü verborgen werden.
- Die öffentliche Standard-Tile-Infrastruktur ist kein garantierter,
  unbegrenzt nutzbarer Produktionsdienst.
- Für eine Marktversion ist ein geeigneter Tile-Anbieter oder ein eigener
  Kartenbetrieb zu wählen.

### Status

OpenStreetMap-Daten: `BEDINGT FREIGEGEBEN`

Öffentlicher Standard-Tileserver: `ZU ERSETZEN`

---

## 6. ESRI World Imagery

### Aktuelle Verwendung

Die gegenwärtige Satellitenseite verwendet möglicherweise ESRI World Imagery
als fotografischen Kartenhintergrund.

### Compliance-Risiko

Ein sichtbarer Tile-Endpunkt bedeutet nicht automatisch, dass dessen
unbegrenzte Einbindung, Zwischenspeicherung oder kommerzielle Weitergabe in
einer eigenen App gestattet ist.

Die konkrete URL, der verwendete Dienst, Attribution, Plattformbedingungen,
Caching-Regeln und kommerzielle Nutzung müssen vor einer Marktfreigabe
vollständig geprüft werden.

### ORTHA-Entscheidung

- nicht als echtes meteorologisches Satellitenprodukt bezeichnen,
- nicht als langfristig freigegebene Marktquelle behandeln,
- beim Umbau des Satellite Centers möglichst durch eine eindeutig lizenzierte
  meteorologische Quelle ersetzen,
- bis zur Klärung sichtbare Anbieterattribution beibehalten.

### Status

`PRÜFUNG OFFEN`

---

## 7. Geplantes ORTHA Satellite Center

Vor einer Implementierung werden mindestens folgende Quellenklassen geprüft:

- EUMETSAT,
- Copernicus,
- DWD Open Data,
- weitere offiziell dokumentierte öffentliche Anbieter.

Für jedes Produkt sind separat zu prüfen:

- Datenlizenz,
- kommerzielle Nutzung,
- Aktualisierungsintervall,
- Caching,
- Weiterverarbeitung,
- Attribution,
- API-Limits,
- geografische Abdeckung,
- Kosten.

### Status

`PRÜFUNG OFFEN`

Es wird keine Satellitenquelle eingebaut, bevor eine konkrete
Compliance-Bewertung dokumentiert ist.

---

## 8. Geplantes Live-Radar

Zu prüfen sind insbesondere:

- DWD-Radarprodukte,
- zulässige WMS-/WMS-Time-Dienste,
- mögliche europäische offene Datenangebote,
- kommerzielle Alternativen.

Nicht zulässig sind:

- übernommene Screenshots fremder Wetter-Webseiten,
- nicht dokumentierte private Endpunkte,
- Umgehung von API-Schlüsseln,
- Entfernung vorgeschriebener Anbieterhinweise.

### Status

`PRÜFUNG OFFEN`

---

## 9. Geplantes Wind Center

Mögliche Datenquellen:

- DWD,
- Open-Meteo,
- Copernicus,
- offiziell lizenzierte Modell- oder Kartendienste.

Die Wetterwerte und die grafische Darstellung sind getrennt zu prüfen.
Eine freie Wind-API erlaubt nicht automatisch die Übernahme einer fremden
Windkartenvisualisierung.

### Status

`PRÜFUNG OFFEN`

---

## 10. Geplantes Marine Center

Mögliche Inhalte:

- Wellenhöhe,
- Wellenrichtung,
- Wellenperiode,
- Seewind,
- Wassertemperatur,
- Gezeiten,
- Strömungen,
- amtliche Küstenwarnungen.

Für Open-Meteo Marine gelten dieselben Einschränkungen der kostenlosen
nichtkommerziellen Nutzung wie für die übrigen frei zugänglichen
Open-Meteo-Angebote.

Gezeiten und amtliche Seewarnungen benötigen zusätzliche, konkret zu
prüfende Quellen.

### Status

`PRÜFUNG OFFEN`
