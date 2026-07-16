import 'package:flutter_test/flutter_test.dart';
import 'package:wetter_app_ortha/engine/recommendation_engine.dart';
import 'package:wetter_app_ortha/engine/risk_engine.dart';

void main() {
  const engine = RecommendationEngine();

  RiskCategoryResult category({
    required String name,
    required RiskLevel level,
    required int score,
    required String message,
  }) {
    return RiskCategoryResult(
      name: name,
      level: level,
      score: score,
      currentScore: score,
      forecastScore: 0,
      peakTime: null,
      displayValue: '',
      forecastDisplayValue: '',
      message: message,
    );
  }

  RiskResult resultWith(List<RiskCategoryResult> categories) {
    return RiskResult(
      level: RiskLevel.green,
      score: 0,
      title: '',
      message: '',
      factors: const [],
      forecastWarnings: const [],
      categories: categories,
    );
  }

  test('grüne Kategorien erzeugen keine Empfehlung', () {
    final result = resultWith([
      category(
        name: 'Wind/Sturm',
        level: RiskLevel.green,
        score: 0,
        message: 'Keine besondere Windbelastung',
      ),
    ]);

    expect(engine.evaluate(result), isEmpty);
  });

  test('gelbe Kategorie erzeugt mittlere Priorität', () {
    final recommendations = engine.evaluate(
      resultWith([
        category(
          name: 'UV',
          level: RiskLevel.yellow,
          score: 15,
          message: 'Erhöhte UV-Strahlung',
        ),
      ]),
    );

    expect(recommendations, hasLength(1));
    expect(recommendations.first.priority, RecommendationPriority.medium);
    expect(recommendations.first.title, 'UV');
  });

  test('orange Kategorie erzeugt hohe Priorität', () {
    final recommendations = engine.evaluate(
      resultWith([
        category(
          name: 'Wind/Sturm',
          level: RiskLevel.orange,
          score: 60,
          message: 'Starke Sturmgefahr',
        ),
      ]),
    );

    expect(recommendations, hasLength(1));
    expect(recommendations.first.priority, RecommendationPriority.high);
  });

  test('rote Kategorie erzeugt kritische Priorität', () {
    final recommendations = engine.evaluate(
      resultWith([
        category(
          name: 'Gewitter',
          level: RiskLevel.red,
          score: 85,
          message: 'Schweres Gewitter möglich',
        ),
      ]),
    );

    expect(recommendations, hasLength(1));
    expect(recommendations.first.priority, RecommendationPriority.critical);
  });

  test('mehrere relevante Kategorien werden vollständig übernommen', () {
    final recommendations = engine.evaluate(
      resultWith([
        category(
          name: 'Hitze',
          level: RiskLevel.yellow,
          score: 25,
          message: 'Erhöhte thermische Belastung',
        ),
        category(
          name: 'UV',
          level: RiskLevel.orange,
          score: 60,
          message: 'Sehr hohe UV-Strahlung',
        ),
      ]),
    );

    expect(recommendations, hasLength(2));
    expect(
      recommendations.map((entry) => entry.title),
      containsAll(<String>['Hitze', 'UV']),
    );
  });

  test('Wind und Gewitter erzeugen kombinierte Empfehlung', () {
    final recommendations = engine.evaluate(
      resultWith([
        category(
          name: 'Wind/Sturm',
          level: RiskLevel.orange,
          score: 60,
          message: 'Starke Sturmgefahr',
        ),
        category(
          name: 'Gewitter',
          level: RiskLevel.yellow,
          score: 35,
          message: 'Erhöhtes Gewitterrisiko',
        ),
      ]),
    );

    expect(recommendations, hasLength(1));
    expect(
      recommendations.first.title,
      'Kombinierte Sturm- und Gewittergefahr',
    );
    expect(recommendations.first.priority, RecommendationPriority.high);
    expect(
      recommendations.first.contributingCategories,
      containsAll(<String>['Wind/Sturm', 'Gewitter']),
    );
  });

  test('rote Wind- oder Gewitterlage hebt Kombination auf kritisch', () {
    final recommendations = engine.evaluate(
      resultWith([
        category(
          name: 'Wind/Sturm',
          level: RiskLevel.red,
          score: 85,
          message: 'Schwere Sturmgefahr',
        ),
        category(
          name: 'Gewitter',
          level: RiskLevel.orange,
          score: 70,
          message: 'Gewitter möglich',
        ),
      ]),
    );

    expect(recommendations, hasLength(1));
    expect(recommendations.first.priority, RecommendationPriority.critical);
  });
}
