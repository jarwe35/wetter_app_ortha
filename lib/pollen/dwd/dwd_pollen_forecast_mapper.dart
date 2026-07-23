import '../../models/pollen_forecast.dart';
import 'dwd_pollen_dataset.dart';

/// Überführt den regionalen DWD-Gefahrenindex in das bestehende
/// ORTHA-Pollenmodell.
///
/// Der DWD liefert Belastungsindizes und keine gemessenen Konzentrationen.
/// Die Konzentrationswerte sind deshalb normierte ORTHA-Repräsentationswerte,
/// mit denen die vorhandene Oberfläche und Belastungslogik unverändert
/// weiterarbeiten kann.
class DwdPollenForecastMapper {
  const DwdPollenForecastMapper();

  PollenForecast map({
    required DwdPollenRegion region,
    required double latitude,
    required double longitude,
    required DateTime referenceDate,
  }) {
    final normalizedDate = DateTime(
      referenceDate.year,
      referenceDate.month,
      referenceDate.day,
    );

    return PollenForecast(
      latitude: latitude,
      longitude: longitude,
      timezone: 'Europe/Berlin',
      days: [
        _mapDay(
          date: normalizedDate,
          region: region,
          selectIndex: (values) => values.today,
        ),
        _mapDay(
          date: normalizedDate.add(const Duration(days: 1)),
          region: region,
          selectIndex: (values) => values.tomorrow,
        ),
        _mapDay(
          date: normalizedDate.add(const Duration(days: 2)),
          region: region,
          selectIndex: (values) => values.dayAfterTomorrow,
        ),
      ],
    );
  }

  DailyPollenForecast _mapDay({
    required DateTime date,
    required DwdPollenRegion region,
    required DwdPollenIndex? Function(DwdPollenDayValues values) selectIndex,
  }) {
    final values = <PollenValue>[];

    for (final entry in _supportedTypes.entries) {
      final dayValues = region.pollen[entry.key];
      final index = dayValues == null ? null : selectIndex(dayValues);

      values.add(
        PollenValue(
          type: entry.value,
          concentration: _normalizedConcentration(index),
        ),
      );
    }

    return DailyPollenForecast(date: date, values: List.unmodifiable(values));
  }

  /// Repräsentationswerte für den DWD-Gefahrenindex.
  ///
  /// Sie sind ausdrücklich keine Messwerte in Pollen/m³. Die Abstufung
  /// erhält die fachliche Reihenfolge des DWD-Index und ermöglicht die
  /// Nutzung der bestehenden ORTHA-Darstellung.
  static double _normalizedConcentration(DwdPollenIndex? index) {
    return switch (index) {
      null || DwdPollenIndex.none => 0,
      DwdPollenIndex.noneToLow => 5,
      DwdPollenIndex.low => 10,
      DwdPollenIndex.lowToModerate => 25,
      DwdPollenIndex.moderate => 40,
      DwdPollenIndex.moderateToHigh => 70,
      DwdPollenIndex.high => 100,
    };
  }

  /// Das bestehende ORTHA-Modell unterstützt derzeit sechs Arten.
  ///
  /// Hasel, Esche und Roggen bleiben vollständig im DWD-Datensatz erhalten,
  /// werden aber erst nach einer Erweiterung von [PollenType] in die
  /// Oberfläche übernommen. „Olive“ ist im DWD-Datensatz nicht vorhanden.
  static const Map<DwdPollenType, PollenType> _supportedTypes = {
    DwdPollenType.alder: PollenType.alder,
    DwdPollenType.birch: PollenType.birch,
    DwdPollenType.grass: PollenType.grass,
    DwdPollenType.mugwort: PollenType.mugwort,
    DwdPollenType.ragweed: PollenType.ragweed,
  };
}
