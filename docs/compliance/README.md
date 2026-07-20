# ORTHA Compliance Ω

## Zweck

Diese Dokumentation begleitet ORTHA METEO Ω vom Demonstrator bis zu einer
möglichen öffentlichen und kommerziellen Veröffentlichung.

Für jede externe Datenquelle, API, Kartenebene, Bibliothek und Mediendatei
werden mindestens folgende Punkte dokumentiert:

1. technische Herkunft,
2. Lizenz und Nutzungsbedingungen,
3. kommerzielle Nutzbarkeit,
4. erforderliche Attribution,
5. Datenschutz und Standortverarbeitung,
6. laufende Kosten und Nutzungslimits,
7. Freigabestatus für Demonstrator und Marktversion.

## Verbindliche Entwicklungsregel

Eine externe Quelle darf erst als marktfähiger Bestandteil von ORTHA gelten,
wenn ihr Status in `DATA_SOURCES.md` ausdrücklich auf `FREIGEGEBEN` gesetzt ist.

Ungeprüfte, unklare oder nur prototypisch zulässige Quellen erhalten einen der
folgenden Status:

- `PRÜFUNG OFFEN`
- `NUR DEMONSTRATOR`
- `NICHT FREIGEGEBEN`
- `ZU ERSETZEN`

## Freigabestufen

### FREIGEGEBEN

Lizenz, Attribution, technische Nutzung und kommerzielle Verwendung wurden
ausreichend dokumentiert. Erforderliche Quellenhinweise sind in der Anwendung
implementiert.

### NUR DEMONSTRATOR

Die Quelle darf nach gegenwärtigem Kenntnisstand für Entwicklung,
Evaluation oder eine nicht öffentliche Vorführung verwendet werden. Eine
Marktveröffentlichung ist noch nicht freigegeben.

### PRÜFUNG OFFEN

Die Nutzungsbedingungen wurden noch nicht hinreichend geprüft oder sind für
die konkrete Einbindungsart nicht eindeutig.

### NICHT FREIGEGEBEN

Die Quelle darf nicht in einer veröffentlichten oder kommerziellen Version
verwendet werden.

### ZU ERSETZEN

Die Quelle ist technisch eingebunden, erfüllt aber den angestrebten
ORTHA-Compliance-Standard noch nicht.

## Compliance-Gate für neue Funktionen

Vor der Integration einer neuen externen Quelle müssen folgende Fragen
beantwortet werden:

- Ist die Quelle offiziell und dokumentiert?
- Ist die Einbindung in eine mobile App erlaubt?
- Ist eine kommerzielle Nutzung erlaubt?
- Ist ein API-Schlüssel oder Vertrag erforderlich?
- Welche Attribution muss sichtbar angezeigt werden?
- Dürfen Daten gespeichert oder zwischengespeichert werden?
- Gelten Abruf-, Volumen- oder Weitergabebeschränkungen?
- Werden Standortdaten oder andere personenbezogene Daten übertragen?
- Welche laufenden Kosten können entstehen?
- Existiert eine offene und langfristig tragfähige Alternative?

## Rechtlicher Hinweis

Diese Projektdokumentation ist eine technische und organisatorische
Compliance-Vorprüfung. Sie ersetzt bei einer Veröffentlichung oder
Vermarktung keine abschließende juristische Prüfung.
