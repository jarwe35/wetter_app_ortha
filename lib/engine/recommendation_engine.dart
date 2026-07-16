import 'risk_engine.dart';

enum RecommendationPriority { low, medium, high, critical }

class Recommendation {
  final RecommendationPriority priority;
  final String title;
  final String description;
  final List<String> contributingCategories;

  const Recommendation({
    required this.priority,
    required this.title,
    required this.description,
    this.contributingCategories = const [],
  });
}

abstract class RecommendationRule {
  const RecommendationRule();

  Recommendation? evaluate(Map<String, RiskCategoryResult> categories);
}

class WindThunderstormRule extends RecommendationRule {
  const WindThunderstormRule();

  @override
  Recommendation? evaluate(Map<String, RiskCategoryResult> categories) {
    final wind = categories['Wind/Sturm'];
    final thunderstorm = categories['Gewitter'];

    if (wind == null || thunderstorm == null) {
      return null;
    }

    final windRelevant = wind.level.index >= RiskLevel.orange.index;
    final thunderstormRelevant =
        thunderstorm.level.index >= RiskLevel.yellow.index;

    if (!windRelevant || !thunderstormRelevant) {
      return null;
    }

    final priority =
        wind.level == RiskLevel.red || thunderstorm.level == RiskLevel.red
        ? RecommendationPriority.critical
        : RecommendationPriority.high;

    return Recommendation(
      priority: priority,
      title: 'Kombinierte Sturm- und Gewittergefahr',
      description:
          'Starke Windbelastung und Gewitter treten gleichzeitig auf. '
          'Exponierte Bereiche, Wälder und Außenaktivitäten sollten '
          'gemieden werden. Lose Gegenstände sind zu sichern.',
      contributingCategories: const ['Wind/Sturm', 'Gewitter'],
    );
  }
}

class RecommendationEngine {
  final List<RecommendationRule> rules;

  const RecommendationEngine({this.rules = const [WindThunderstormRule()]});

  List<Recommendation> evaluate(RiskResult risk) {
    final recommendations = <Recommendation>[];

    final categories = {
      for (final category in risk.categories) category.name: category,
    };

    for (final rule in rules) {
      final recommendation = rule.evaluate(categories);

      if (recommendation != null) {
        recommendations.add(recommendation);
      }
    }

    for (final category in risk.categories) {
      if (_isCoveredByCombinedRecommendation(category.name, recommendations)) {
        continue;
      }

      final recommendation = _recommendationForCategory(category);

      if (recommendation != null) {
        recommendations.add(recommendation);
      }
    }

    recommendations.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index),
    );

    return recommendations;
  }

  Recommendation? _recommendationForCategory(RiskCategoryResult category) {
    switch (category.level) {
      case RiskLevel.red:
        return Recommendation(
          priority: RecommendationPriority.critical,
          title: category.name,
          description: category.message,
          contributingCategories: [category.name],
        );

      case RiskLevel.orange:
        return Recommendation(
          priority: RecommendationPriority.high,
          title: category.name,
          description: category.message,
          contributingCategories: [category.name],
        );

      case RiskLevel.yellow:
        return Recommendation(
          priority: RecommendationPriority.medium,
          title: category.name,
          description: category.message,
          contributingCategories: [category.name],
        );

      case RiskLevel.green:
        return null;
    }
  }

  bool _isCoveredByCombinedRecommendation(
    String categoryName,
    List<Recommendation> recommendations,
  ) {
    return recommendations.any(
      (recommendation) =>
          recommendation.contributingCategories.length > 1 &&
          recommendation.contributingCategories.contains(categoryName),
    );
  }
}
