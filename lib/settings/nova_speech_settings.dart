import 'package:flutter/foundation.dart';

@immutable
class NovaSpeechSettings {
  const NovaSpeechSettings({
    this.language = 'de-DE',
    this.speechRate = 0.48,
    this.pitch = 1.0,
    this.volume = 1.0,
    this.repeatCriticalWarnings = true,
    this.announceWarningSource = true,
    this.announceLocation = true,
  });

  static const NovaSpeechSettings defaults = NovaSpeechSettings();

  final String language;
  final double speechRate;
  final double pitch;
  final double volume;
  final bool repeatCriticalWarnings;
  final bool announceWarningSource;
  final bool announceLocation;

  NovaSpeechSettings copyWith({
    String? language,
    double? speechRate,
    double? pitch,
    double? volume,
    bool? repeatCriticalWarnings,
    bool? announceWarningSource,
    bool? announceLocation,
  }) {
    return NovaSpeechSettings(
      language: language ?? this.language,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      repeatCriticalWarnings:
          repeatCriticalWarnings ?? this.repeatCriticalWarnings,
      announceWarningSource:
          announceWarningSource ?? this.announceWarningSource,
      announceLocation: announceLocation ?? this.announceLocation,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is NovaSpeechSettings &&
            other.language == language &&
            other.speechRate == speechRate &&
            other.pitch == pitch &&
            other.volume == volume &&
            other.repeatCriticalWarnings == repeatCriticalWarnings &&
            other.announceWarningSource == announceWarningSource &&
            other.announceLocation == announceLocation;
  }

  @override
  int get hashCode => Object.hash(
    language,
    speechRate,
    pitch,
    volume,
    repeatCriticalWarnings,
    announceWarningSource,
    announceLocation,
  );
}
