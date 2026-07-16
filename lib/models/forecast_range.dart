/// Unterstützte Zeiträume der Tagesvorhersage.
enum ForecastRange {
  sevenDays(
    dayCount: 7,
    label: '7 Tage',
    semanticLabel: 'Vorhersage für sieben Tage',
  ),
  fourteenDays(
    dayCount: 14,
    label: '14 Tage',
    semanticLabel: 'Vorhersage für vierzehn Tage',
  );

  const ForecastRange({
    required this.dayCount,
    required this.label,
    required this.semanticLabel,
  });

  /// Maximale Zahl der anzuzeigenden Prognosetage.
  final int dayCount;

  /// Kurze Beschriftung für die Benutzeroberfläche.
  final String label;

  /// Ausführliche Beschriftung für Bedienungshilfen.
  final String semanticLabel;

  /// Liefert höchstens so viele Einträge, wie der Zeitraum vorsieht.
  ///
  /// Die ursprüngliche Liste wird nicht verändert.
  List<T> applyTo<T>(Iterable<T> values) {
    return List<T>.unmodifiable(values.take(dayCount));
  }
}
