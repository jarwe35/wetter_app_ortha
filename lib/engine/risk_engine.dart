import '../services/weather_service.dart';

enum RiskLevel { green, yellow, orange, red }

class RiskCategoryResult {
  final String name;
  final RiskLevel level;
  final int score;
  final int currentScore;
  final int forecastScore;
  final String? peakTime;
  final String displayValue;
  final String forecastDisplayValue;
  final String message;

  const RiskCategoryResult({
    required this.name,
    required this.level,
    required this.score,
    required this.currentScore,
    required this.forecastScore,
    required this.peakTime,
    required this.displayValue,
    required this.forecastDisplayValue,
    required this.message,
  });
}

class RiskResult {
  final RiskLevel level;
  final int score;
  final String title;
  final String message;
  final List<String> factors;
  final List<String> forecastWarnings;
  final List<RiskCategoryResult> categories;

  const RiskResult({
    required this.level,
    required this.score,
    required this.title,
    required this.message,
    required this.factors,
    required this.forecastWarnings,
    this.categories = const [],
  });
}

class RiskEngine {
  const RiskEngine();

  RiskLevel _levelFromScore(int score) {
    if (score >= 70) return RiskLevel.red;
    if (score >= 40) return RiskLevel.orange;
    if (score >= 15) return RiskLevel.yellow;
    return RiskLevel.green;
  }

  RiskCategoryResult _category(
    String name,
    int score,
    String message, {
    String displayValue = '',
    String forecastDisplayValue = '',
    int? currentScore,
    int? forecastScore,
    String? peakTime,
  }) {
    final normalizedScore = score.clamp(0, 100);

    return RiskCategoryResult(
      name: name,
      level: _levelFromScore(normalizedScore),
      score: normalizedScore,
      currentScore: currentScore ?? normalizedScore,
      forecastScore: forecastScore ?? 0,
      peakTime: peakTime,
      displayValue: displayValue,
      forecastDisplayValue: forecastDisplayValue,
      message: message,
    );
  }

  RiskCategoryResult _evaluateHeat(WeatherData data) {
    int scoreForTemperature(double temperature) {
      if (temperature >= 38) return 85;
      if (temperature >= 32) return 60;
      if (temperature >= 26) return 25;
      return 0;
    }

    final currentScore = scoreForTemperature(data.apparentTemperature);

    var forecastScore = 0;
    String? peakTime;
    double? peakTemperature;

    for (final hour in data.hourlyForecast) {
      final score = scoreForTemperature(hour.apparentTemperature);

      if (score > forecastScore) {
        forecastScore = score;
        peakTime = shortTime(hour.time);
        peakTemperature = hour.apparentTemperature;
      }
    }

    final totalScore = currentScore > forecastScore
        ? currentScore
        : forecastScore;

    final message = forecastScore > currentScore && peakTime != null
        ? 'Aktuell geringere Belastung, stärkere Hitzebelastung ab $peakTime möglich'
        : _heatMessage(totalScore);

    return _category(
      'Hitze',
      totalScore,
      message,
      displayValue: '${data.apparentTemperature.toStringAsFixed(1)} °C gefühlt',
      forecastDisplayValue: peakTemperature == null
          ? 'keine relevante Verschärfung erkannt'
          : '${peakTemperature.toStringAsFixed(1)} °C gefühlt ab $peakTime',
      currentScore: currentScore,
      forecastScore: forecastScore,
      peakTime: peakTime,
    );
  }

  String _heatMessage(int score) {
    if (score >= 85) return 'Extreme thermische Belastung';
    if (score >= 60) return 'Hohe thermische Belastung';
    if (score >= 25) return 'Erhöhte thermische Belastung';
    return 'Keine besondere Hitzebelastung';
  }

  RiskCategoryResult _evaluateUv(WeatherData data) {
    int scoreForUv(double uv) {
      if (uv >= 11) return 85;
      if (uv >= 8) return 60;
      if (uv >= 6) return 35;
      if (uv >= 3) return 15;
      return 0;
    }

    final currentScore = scoreForUv(data.uvIndex);

    var forecastScore = 0;
    String? peakTime;
    double? peakUv;

    for (final hour in data.hourlyForecast) {
      final score = scoreForUv(hour.uvIndex);

      if (score > forecastScore) {
        forecastScore = score;
        peakTime = shortTime(hour.time);
        peakUv = hour.uvIndex;
      }
    }

    final totalScore = currentScore > forecastScore
        ? currentScore
        : forecastScore;

    final message = forecastScore > currentScore && peakTime != null
        ? 'Aktuell geringere Belastung, stärkere UV-Strahlung ab $peakTime möglich'
        : _uvMessage(totalScore);

    return _category(
      'UV',
      totalScore,
      message,
      displayValue: 'UV ${data.uvIndex.toStringAsFixed(1)}',
      forecastDisplayValue: peakUv == null
          ? 'keine relevante Verschärfung erkannt'
          : 'UV ${peakUv.toStringAsFixed(1)} ab $peakTime',
      currentScore: currentScore,
      forecastScore: forecastScore,
      peakTime: peakTime,
    );
  }

  String _uvMessage(int score) {
    if (score >= 85) return 'Extreme UV-Strahlung';
    if (score >= 60) return 'Sehr hohe UV-Strahlung';
    if (score >= 35) return 'Hohe UV-Strahlung';
    if (score >= 15) return 'Erhöhte UV-Strahlung';
    return 'Geringe UV-Belastung';
  }

  RiskCategoryResult _evaluateWind(WeatherData data) {
    int scoreForGusts(double gusts) {
      if (gusts >= 90) return 85;
      if (gusts >= 65) return 60;
      if (gusts >= 40) return 35;
      if (gusts >= 25) return 15;
      return 0;
    }

    final currentScore = scoreForGusts(data.windGusts);

    var forecastScore = 0;
    String? peakTime;
    double? peakGusts;

    for (final hour in data.hourlyForecast) {
      final score = scoreForGusts(hour.windGusts);

      if (score > forecastScore) {
        forecastScore = score;
        peakTime = shortTime(hour.time);
        peakGusts = hour.windGusts;
      }
    }

    final totalScore = currentScore > forecastScore
        ? currentScore
        : forecastScore;

    final message = forecastScore > currentScore && peakTime != null
        ? 'Aktuell geringere Windbelastung, stärkere Böen ab $peakTime möglich'
        : _windMessage(totalScore);

    return _category(
      'Wind/Sturm',
      totalScore,
      message,
      displayValue: '${data.windGusts.toStringAsFixed(0)} km/h Böen',
      forecastDisplayValue: peakGusts == null
          ? 'keine relevante Verschärfung erkannt'
          : '${peakGusts.toStringAsFixed(0)} km/h Böen ab $peakTime',
      currentScore: currentScore,
      forecastScore: forecastScore,
      peakTime: peakTime,
    );
  }

  String _windMessage(int score) {
    if (score >= 85) return 'Schwere Sturmgefahr';
    if (score >= 60) return 'Starke Sturmgefahr';
    if (score >= 35) return 'Deutliche Windböen';
    if (score >= 15) return 'Erhöhte Windbelastung';
    return 'Keine besondere Windbelastung';
  }

  RiskCategoryResult _evaluatePrecipitation(WeatherData data) {
    int scoreForCurrentPrecipitation(double precipitation) {
      if (precipitation >= 15) return 75;
      if (precipitation >= 5) return 45;
      if (precipitation > 0) return 25;
      return 0;
    }

    int scoreForProbability(int probability) {
      if (probability >= 90) return 75;
      if (probability >= 70) return 45;
      if (probability >= 40) return 20;
      return 0;
    }

    int scoreForWeatherCode(int code) {
      if ([95, 96, 99].contains(code)) return 75;
      if ([65, 66, 67, 82].contains(code)) return 60;
      if ([61, 63, 80, 81].contains(code)) return 45;
      if ([51, 53, 55, 56, 57].contains(code)) return 25;
      return 0;
    }

    final currentAmountScore = scoreForCurrentPrecipitation(data.precipitation);
    final currentCodeScore = scoreForWeatherCode(data.weatherCode);
    final currentScore = currentAmountScore > currentCodeScore
        ? currentAmountScore
        : currentCodeScore;

    var forecastScore = 0;
    String? peakTime;
    int? peakProbability;

    for (final hour in data.hourlyForecast) {
      final probabilityScore = scoreForProbability(
        hour.precipitationProbability,
      );
      final codeScore = scoreForWeatherCode(hour.weatherCode);
      final score = probabilityScore > codeScore ? probabilityScore : codeScore;

      if (score > forecastScore ||
          (score > 0 &&
              score == forecastScore &&
              hour.precipitationProbability > (peakProbability ?? -1))) {
        forecastScore = score;
        peakTime = shortTime(hour.time);
        peakProbability = hour.precipitationProbability;
      }
    }

    final totalScore = currentScore > forecastScore
        ? currentScore
        : forecastScore;

    final message = currentScore > 0 && currentScore >= forecastScore
        ? _precipitationMessage(currentScore)
        : forecastScore > currentScore && peakTime != null
        ? 'Aktuell geringerer Niederschlag, erhöhte Niederschlagslage ab $peakTime möglich'
        : _precipitationMessage(totalScore);

    return _category(
      'Niederschlag',
      totalScore,
      message,
      displayValue: data.precipitation > 0
          ? '${data.precipitation.toStringAsFixed(1)} l/m² aktuell'
          : 'aktuell kein messbarer Niederschlag',
      forecastDisplayValue: peakProbability == null || peakTime == null
          ? 'keine relevante Niederschlagslage erkannt'
          : '$peakProbability % Regenwahrscheinlichkeit ab $peakTime',
      currentScore: currentScore,
      forecastScore: forecastScore,
      peakTime: peakTime,
    );
  }

  String _precipitationMessage(int score) {
    if (score >= 75) return 'Gewitter oder sehr starker Niederschlag erkannt';
    if (score >= 60) return 'Starker Niederschlag erkannt';
    if (score >= 45) return 'Regen oder Schauer erkannt';
    if (score >= 25) return 'Leichter Niederschlag oder Nieselregen erkannt';
    return 'Kein relevanter Niederschlag';
  }

  RiskCategoryResult _evaluateVisibility(WeatherData data) {
    int scoreForVisibility(double visibility, int weatherCode) {
      if ([45, 48].contains(weatherCode)) return 60;
      if (visibility < 1000) return 75;
      if (visibility < 5000) return 35;
      if (visibility < 10000) return 15;
      return 0;
    }

    final currentScore = scoreForVisibility(data.visibility, data.weatherCode);

    var forecastScore = 0;
    String? peakTime;
    double? lowestVisibility;

    for (final hour in data.hourlyForecast) {
      final score = scoreForVisibility(hour.visibility, hour.weatherCode);

      if (score > forecastScore ||
          (score == forecastScore &&
              hour.visibility < (lowestVisibility ?? double.infinity))) {
        forecastScore = score;
        peakTime = shortTime(hour.time);
        lowestVisibility = hour.visibility;
      }
    }

    final totalScore = currentScore > forecastScore
        ? currentScore
        : forecastScore;

    final message = forecastScore > currentScore && peakTime != null
        ? 'Aktuell bessere Sicht, stärkere Sichtbeeinträchtigung ab $peakTime möglich'
        : _visibilityMessage(totalScore);

    return _category(
      'Sicht',
      totalScore,
      message,
      displayValue: data.visibility >= 1000
          ? '${(data.visibility / 1000).toStringAsFixed(1)} km Sicht'
          : '${data.visibility.toStringAsFixed(0)} m Sicht',
      forecastDisplayValue: lowestVisibility == null || peakTime == null
          ? 'keine relevante Verschlechterung erkannt'
          : lowestVisibility >= 1000
          ? '${(lowestVisibility / 1000).toStringAsFixed(1)} km Sicht ab $peakTime'
          : '${lowestVisibility.toStringAsFixed(0)} m Sicht ab $peakTime',
      currentScore: currentScore,
      forecastScore: forecastScore,
      peakTime: peakTime,
    );
  }

  String _visibilityMessage(int score) {
    if (score >= 75) return 'Sehr schlechte Sicht';
    if (score >= 60) return 'Nebel oder deutliche Sichtbeeinträchtigung';
    if (score >= 35) return 'Eingeschränkte Sicht';
    if (score >= 15) return 'Leicht eingeschränkte Sicht';
    return 'Gute Sichtverhältnisse';
  }

  RiskCategoryResult _evaluateThunderstorm(WeatherData data) {
    int scoreForThunderstorm(int weatherCode, int precipitationProbability) {
      if (weatherCode == 99) return 85;
      if (weatherCode == 96) return 75;
      if (weatherCode == 95) return 70;
      if ([80, 81, 82].contains(weatherCode) &&
          precipitationProbability >= 70) {
        return 45;
      }
      if (precipitationProbability >= 90) return 35;
      return 0;
    }

    final currentProbability = data.hourlyForecast.isNotEmpty
        ? data.hourlyForecast.first.precipitationProbability
        : 0;

    final currentScore = scoreForThunderstorm(
      data.weatherCode,
      currentProbability,
    );

    var forecastScore = 0;
    String? peakTime;
    int? peakProbability;
    int? peakWeatherCode;

    for (final hour in data.hourlyForecast) {
      final score = scoreForThunderstorm(
        hour.weatherCode,
        hour.precipitationProbability,
      );

      if (score > forecastScore ||
          (score == forecastScore &&
              hour.precipitationProbability > (peakProbability ?? -1))) {
        forecastScore = score;
        peakTime = shortTime(hour.time);
        peakProbability = hour.precipitationProbability;
        peakWeatherCode = hour.weatherCode;
      }
    }

    final totalScore = currentScore > forecastScore
        ? currentScore
        : forecastScore;

    final message = forecastScore > currentScore && peakTime != null
        ? 'Aktuell keine oder geringere Gewitterlage, erhöhtes Gewitterrisiko ab $peakTime möglich'
        : _thunderstormMessage(totalScore);

    return _category(
      'Gewitter',
      totalScore,
      message,
      displayValue: currentScore > 0
          ? _thunderstormDisplayText(data.weatherCode, currentProbability)
          : 'aktuell kein Gewitter erkannt',
      forecastDisplayValue:
          peakTime == null || peakProbability == null || peakWeatherCode == null
          ? 'keine Gewitterlage erkannt'
          : '${_thunderstormDisplayText(peakWeatherCode, peakProbability)} ab $peakTime',
      currentScore: currentScore,
      forecastScore: forecastScore,
      peakTime: peakTime,
    );
  }

  String _thunderstormDisplayText(
    int weatherCode,
    int precipitationProbability,
  ) {
    if (weatherCode == 99) {
      return 'schweres Gewitter · $precipitationProbability % Niederschlagswahrscheinlichkeit';
    }
    if (weatherCode == 96) {
      return 'Gewitter mit Hagelrisiko · $precipitationProbability % Niederschlagswahrscheinlichkeit';
    }
    if (weatherCode == 95) {
      return 'Gewitter · $precipitationProbability % Niederschlagswahrscheinlichkeit';
    }
    if ([80, 81, 82].contains(weatherCode)) {
      return 'Schauerlage mit Gewitterrisiko · $precipitationProbability % Niederschlagswahrscheinlichkeit';
    }
    return 'erhöhtes Gewitterrisiko · $precipitationProbability % Niederschlagswahrscheinlichkeit';
  }

  String _thunderstormMessage(int score) {
    if (score >= 85) return 'Schweres Gewitter möglich';
    if (score >= 75) return 'Gewitter mit erhöhter Intensität möglich';
    if (score >= 70) return 'Gewitter möglich';
    if (score >= 45) return 'Schauerlage mit möglichem Gewitterrisiko';
    if (score >= 35) {
      return 'Erhöhte Unsicherheit durch sehr hohe Niederschlagswahrscheinlichkeit';
    }
    return 'Keine Gewitterlage erkannt';
  }

  RiskResult evaluate(WeatherData data) {
    final categories = <RiskCategoryResult>[
      _evaluateHeat(data),
      _evaluateUv(data),
      _evaluateWind(data),
      _evaluatePrecipitation(data),
      _evaluateVisibility(data),
      _evaluateThunderstorm(data),
    ];

    final relevantCategories = categories
        .where((category) => category.score >= 15)
        .toList();

    final factors = relevantCategories
        .map((category) => '${category.name}: ${category.message}')
        .toList();

    final forecastWarnings = categories
        .where(
          (category) =>
              category.forecastScore > category.currentScore &&
              category.peakTime != null,
        )
        .map((category) => '${category.name}: ${category.forecastDisplayValue}')
        .toList();

    var strongestScore = 0;

    for (final category in categories) {
      if (category.score > strongestScore) {
        strongestScore = category.score;
      }
    }

    final additionalRisks = relevantCategories.length > 1
        ? relevantCategories.length - 1
        : 0;

    final normalizedScore = (strongestScore + additionalRisks * 5).clamp(
      0,
      100,
    );

    final level = _levelFromScore(normalizedScore);

    switch (level) {
      case RiskLevel.red:
        return RiskResult(
          level: level,
          score: normalizedScore,
          title: 'Rot · Hohe Wetterbelastung',
          message:
              'Mindestens ein Wetterrisiko erreicht einen kritischen Bereich. Aktivitäten und Wege sollten angepasst werden.',
          factors: factors,
          forecastWarnings: forecastWarnings,
          categories: categories,
        );

      case RiskLevel.orange:
        return RiskResult(
          level: level,
          score: normalizedScore,
          title: 'Orange · Erhöhte Wetterbelastung',
          message:
              'Die Wetterlage weist relevante Belastungsfaktoren auf. Zusätzliche Vorsicht ist sinnvoll.',
          factors: factors,
          forecastWarnings: forecastWarnings,
          categories: categories,
        );

      case RiskLevel.yellow:
        return RiskResult(
          level: level,
          score: normalizedScore,
          title: 'Gelb · Erhöhte Aufmerksamkeit',
          message:
              'Einzelne Wetterfaktoren sind erhöht. Die Entwicklung sollte beobachtet werden.',
          factors: factors,
          forecastWarnings: forecastWarnings,
          categories: categories,
        );

      case RiskLevel.green:
        return RiskResult(
          level: level,
          score: normalizedScore,
          title: 'Grün · Geringe Wetterbelastung',
          message:
              'Aus den aktuellen Wetterdaten und Prognosen ergibt sich keine besondere Belastung.',
          factors: factors,
          forecastWarnings: forecastWarnings,
          categories: categories,
        );
    }
  }
}

String shortTime(String value) {
  final parts = value.split('T');
  if (parts.length != 2) return value;
  return parts[1].substring(0, 5);
}
