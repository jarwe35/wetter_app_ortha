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

class RecommendationEngine {
  const RecommendationEngine();

  List<Recommendation> evaluate(RiskResult risk) {
    final recommendations = <Recommendation>[];
    final categories = {
      for (final category in risk.categories) category.name: category,
    };

    final wind = categories['Wind/Sturm'];
    final thunderstorm = categories['Gewitter'];

    if (wind != null &&
        thunderstorm != null &&
        wind.level.index >= RiskLevel.orange.index &&
        thunderstorm.level.index >= RiskLevel.yellow.index) {
      recommendations.add(
        Recommendation(
          priority:
              wind.level == RiskLevel.red || thunderstorm.level == RiskLevel.red
              ? RecommendationPriority.critical
              : RecommendationPriority.high,
          title: 'Kombinierte Sturm- und Gewittergefahr',
          description:
              'Starke Windbelastung und Gewitter treten gleichzeitig auf. '
              'Exponierte Bereiche, Wälder und Außenaktivitäten sollten '
              'gemieden werden. Lose Gegenstände sind zu sichern.',
          contributingCategories: const ['Wind/Sturm', 'Gewitter'],
        ),
      );
    }

    for (final category in risk.categories) {
      if (_isCoveredByCombinedRecommendation(category.name, recommendations)) {
        continue;
      }

      if (category.level == RiskLevel.red) {
        recommendations.add(
          Recommendation(
            priority: RecommendationPriority.critical,
            title: category.name,
            description: category.message,
            contributingCategories: [category.name],
          ),
        );
      } else if (category.level == RiskLevel.orange) {
        recommendations.add(
          Recommendation(
            priority: RecommendationPriority.high,
            title: category.name,
            description: category.message,
            contributingCategories: [category.name],
          ),
        );
      } else if (category.level == RiskLevel.yellow) {
        recommendations.add(
          Recommendation(
            priority: RecommendationPriority.medium,
            title: category.name,
            description: category.message,
            contributingCategories: [category.name],
          ),
        );
      }
    }

    recommendations.sort(
      (a, b) => b.priority.index.compareTo(a.priority.index),
    );

    return recommendations;
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
