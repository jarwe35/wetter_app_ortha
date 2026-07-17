enum OrthaStatusLevel { green, yellow, orange, red }

class OrthaStatusModel {
  final OrthaStatusLevel level;
  final String title;
  final String statusText;
  final String riskText;
  final String warningText;
  final String location;
  final String recommendation;
  final DateTime timestamp;

  const OrthaStatusModel({
    required this.level,
    required this.title,
    required this.statusText,
    required this.riskText,
    required this.warningText,
    required this.location,
    required this.recommendation,
    required this.timestamp,
  });
}
