class BbkMapWarning {
  final String id;
  final int version;
  final DateTime startDate;
  final String severity;
  final String urgency;
  final String type;
  final Map<String, String> titles;
  final Map<String, String> translationKeys;

  const BbkMapWarning({
    required this.id,
    required this.version,
    required this.startDate,
    required this.severity,
    required this.urgency,
    required this.type,
    required this.titles,
    required this.translationKeys,
  });

  String get germanTitle {
    final german = titles['de']?.trim();

    if (german != null && german.isNotEmpty) {
      return german;
    }

    for (final title in titles.values) {
      if (title.trim().isNotEmpty) {
        return title.trim();
      }
    }

    return id;
  }

  bool get isCancellation => type.trim().toLowerCase() == 'cancel';

  bool get isAlertOrUpdate {
    final normalizedType = type.trim().toLowerCase();

    return normalizedType == 'alert' || normalizedType == 'update';
  }
}
