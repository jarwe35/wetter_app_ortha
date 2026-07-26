/// Erstellt eine begrenzte und deduplizierte Preload-Reihenfolge.
///
/// Zuerst werden die unmittelbar folgenden Frames eingeplant. Danach können
/// optional vorherige Frames ergänzt werden, damit auch Rückwärtssprünge
/// ohne sichtbare Ladepause möglich bleiben.
class RadarPreloadPlanner<T> {
  const RadarPreloadPlanner({
    this.lookAhead = 3,
    this.lookBehind = 1,
    this.wrapAround = true,
  }) : assert(lookAhead >= 0),
       assert(lookBehind >= 0);

  final int lookAhead;
  final int lookBehind;
  final bool wrapAround;

  List<T> createPlan({required List<T> frames, required int currentIndex}) {
    if (frames.isEmpty) {
      return <T>[];
    }

    if (currentIndex < 0 || currentIndex >= frames.length) {
      throw RangeError.range(
        currentIndex,
        0,
        frames.length - 1,
        'currentIndex',
      );
    }

    final plannedIndexes = <int>[];
    final knownIndexes = <int>{currentIndex};

    for (var offset = 1; offset <= lookAhead; offset++) {
      final index = _resolveIndex(currentIndex + offset, frames.length);

      if (index != null && knownIndexes.add(index)) {
        plannedIndexes.add(index);
      }
    }

    for (var offset = 1; offset <= lookBehind; offset++) {
      final index = _resolveIndex(currentIndex - offset, frames.length);

      if (index != null && knownIndexes.add(index)) {
        plannedIndexes.add(index);
      }
    }

    return List<T>.unmodifiable(plannedIndexes.map((index) => frames[index]));
  }

  int? _resolveIndex(int index, int length) {
    if (index >= 0 && index < length) {
      return index;
    }

    if (!wrapAround || length == 0) {
      return null;
    }

    return index % length;
  }
}
