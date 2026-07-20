enum PollenType { alder, birch, grass, mugwort, olive, ragweed }

extension PollenTypePresentation on PollenType {
  String get apiKey {
    switch (this) {
      case PollenType.alder:
        return 'alder_pollen';
      case PollenType.birch:
        return 'birch_pollen';
      case PollenType.grass:
        return 'grass_pollen';
      case PollenType.mugwort:
        return 'mugwort_pollen';
      case PollenType.olive:
        return 'olive_pollen';
      case PollenType.ragweed:
        return 'ragweed_pollen';
    }
  }

  String get label {
    switch (this) {
      case PollenType.alder:
        return 'Erle';
      case PollenType.birch:
        return 'Birke';
      case PollenType.grass:
        return 'Gräser';
      case PollenType.mugwort:
        return 'Beifuß';
      case PollenType.olive:
        return 'Olive';
      case PollenType.ragweed:
        return 'Ambrosia';
    }
  }
}

enum PollenLoadLevel { none, low, moderate, high, veryHigh }

extension PollenLoadLevelPresentation on PollenLoadLevel {
  String get label {
    switch (this) {
      case PollenLoadLevel.none:
        return 'Keine';
      case PollenLoadLevel.low:
        return 'Gering';
      case PollenLoadLevel.moderate:
        return 'Mäßig';
      case PollenLoadLevel.high:
        return 'Hoch';
      case PollenLoadLevel.veryHigh:
        return 'Sehr hoch';
    }
  }
}

class PollenValue {
  final PollenType type;
  final double concentration;

  const PollenValue({required this.type, required this.concentration});

  PollenLoadLevel get level {
    if (concentration <= 0) {
      return PollenLoadLevel.none;
    }

    if (concentration < 10) {
      return PollenLoadLevel.low;
    }

    if (concentration < 50) {
      return PollenLoadLevel.moderate;
    }

    if (concentration < 100) {
      return PollenLoadLevel.high;
    }

    return PollenLoadLevel.veryHigh;
  }
}

class DailyPollenForecast {
  final DateTime date;
  final List<PollenValue> values;

  const DailyPollenForecast({required this.date, required this.values});

  PollenValue? get strongestValue {
    if (values.isEmpty) {
      return null;
    }

    return values.reduce(
      (current, next) =>
          next.concentration > current.concentration ? next : current,
    );
  }
}

class PollenForecast {
  final double latitude;
  final double longitude;
  final String timezone;
  final List<DailyPollenForecast> days;

  const PollenForecast({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.days,
  });

  bool get hasMeasurements {
    return days.any(
      (day) => day.values.any((value) => value.concentration > 0),
    );
  }
}
