class BbkWarning {
  final String identifier;
  final String headline;
  final String description;
  final String instruction;
  final String sender;
  final String severity;
  final String urgency;
  final String certainty;
  final String messageType;
  final DateTime? sent;
  final DateTime? effective;
  final DateTime? expires;
  final List<String> areaDescriptions;
  final Map<String, String> geocodes;
  final List<String> polygons;

  const BbkWarning({
    required this.identifier,
    required this.headline,
    required this.description,
    required this.instruction,
    required this.sender,
    required this.severity,
    required this.urgency,
    required this.certainty,
    required this.messageType,
    required this.sent,
    required this.effective,
    required this.expires,
    this.areaDescriptions = const [],
    this.geocodes = const {},
    this.polygons = const [],
  });

  bool get isCancellation {
    final normalizedMessageType = messageType.trim().toLowerCase();
    final normalizedHeadline = headline.trim().toLowerCase();

    return normalizedMessageType == 'cancel' ||
        normalizedHeadline.startsWith('entwarnung');
  }

  bool get hasGeometry => polygons.isNotEmpty;

  bool isActiveAt(DateTime moment) {
    if (effective != null && moment.isBefore(effective!)) {
      return false;
    }

    if (expires != null && !moment.isBefore(expires!)) {
      return false;
    }

    return !isCancellation;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is BbkWarning &&
            identifier == other.identifier &&
            headline == other.headline &&
            description == other.description &&
            instruction == other.instruction &&
            sender == other.sender &&
            severity == other.severity &&
            urgency == other.urgency &&
            certainty == other.certainty &&
            messageType == other.messageType &&
            sent == other.sent &&
            effective == other.effective &&
            expires == other.expires &&
            _listEquals(areaDescriptions, other.areaDescriptions) &&
            _mapEquals(geocodes, other.geocodes) &&
            _listEquals(polygons, other.polygons);
  }

  @override
  int get hashCode {
    return Object.hash(
      identifier,
      headline,
      description,
      instruction,
      sender,
      severity,
      urgency,
      certainty,
      messageType,
      sent,
      effective,
      expires,
      Object.hashAll(areaDescriptions),
      Object.hashAll(
        geocodes.entries.map((entry) => Object.hash(entry.key, entry.value)),
      ),
      Object.hashAll(polygons),
    );
  }

  static bool _listEquals<T>(List<T> first, List<T> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (var index = 0; index < first.length; index++) {
      if (first[index] != second[index]) return false;
    }

    return true;
  }

  static bool _mapEquals<K, V>(Map<K, V> first, Map<K, V> second) {
    if (identical(first, second)) return true;
    if (first.length != second.length) return false;

    for (final entry in first.entries) {
      if (!second.containsKey(entry.key) || second[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }
}
