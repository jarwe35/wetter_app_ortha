class NovaSpeechVoice {
  const NovaSpeechVoice({required this.name, required this.locale});

  final String name;
  final String locale;

  String get id => '$name|$locale';

  String get displayName {
    final normalizedLocale = locale.replaceAll('_', '-');

    switch (normalizedLocale.toLowerCase()) {
      case 'de-de':
        return '$name · Deutsch (Deutschland)';
      case 'de-at':
        return '$name · Deutsch (Österreich)';
      case 'de-ch':
        return '$name · Deutsch (Schweiz)';
      default:
        return '$name · $normalizedLocale';
    }
  }

  @override
  bool operator ==(Object other) {
    return other is NovaSpeechVoice &&
        other.name == name &&
        other.locale == locale;
  }

  @override
  int get hashCode => Object.hash(name, locale);
}
