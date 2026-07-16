import 'risk_engine.dart';

enum RecommendationPriority { low, medium, high, critical }

class Recommendation {
  final RecommendationPriority priority;
  final String title;
  final String description;

  const Recommendation({
    required this.priority,
    required this.title,
    required this.description,
  });
}

class RecommendationEngine {
  const RecommendationEngine();

  List<Recommendation> evaluate(RiskResult risk) {
    final recommendations = <Recommendation>[];

    for (final category in risk.categories) {
      if (category.level == RiskLevel.red) {
        recommendations.add(
          Recommendation(
            priority: RecommendationPriority.critical,
            title: category.name,
            description: category.message,
          ),
        );
      } else if (category.level == RiskLevel.orange) {
        recommendations.add(
          Recommendation(
            priority: RecommendationPriority.high,
            title: category.name,
            description: category.message,
          ),
        );
      } else if (category.level == RiskLevel.yellow) {
        recommendations.add(
          Recommendation(
            priority: RecommendationPriority.medium,
            title: category.name,
            description: category.message,
          ),
        );
      }
    }

    return recommendations;
  }
}
