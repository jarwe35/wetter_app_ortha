enum OrthaWidgetBackgroundStyle { gradient, solid }

enum OrthaWidgetThemeStyle { dark, light, automatic }

class OrthaWidgetSettings {
  const OrthaWidgetSettings({
    this.backgroundStyle = OrthaWidgetBackgroundStyle.gradient,
    this.themeStyle = OrthaWidgetThemeStyle.dark,
    this.transparencyPercent = 8,
    this.showPlace = true,
    this.showTemperature = true,
    this.showWeatherIcon = true,
    this.showWarningLight = true,
  });

  static const defaults = OrthaWidgetSettings();

  final OrthaWidgetBackgroundStyle backgroundStyle;
  final OrthaWidgetThemeStyle themeStyle;

  /// Transparenz von 0 bis 40 Prozent.
  ///
  /// In diesem Entwicklungsschritt wird der Wert nur gespeichert und in der
  /// Vorschau angezeigt. Das Android-Widget wird noch nicht verändert.
  final int transparencyPercent;

  final bool showPlace;
  final bool showTemperature;
  final bool showWeatherIcon;
  final bool showWarningLight;

  OrthaWidgetSettings copyWith({
    OrthaWidgetBackgroundStyle? backgroundStyle,
    OrthaWidgetThemeStyle? themeStyle,
    int? transparencyPercent,
    bool? showPlace,
    bool? showTemperature,
    bool? showWeatherIcon,
    bool? showWarningLight,
  }) {
    return OrthaWidgetSettings(
      backgroundStyle: backgroundStyle ?? this.backgroundStyle,
      themeStyle: themeStyle ?? this.themeStyle,
      transparencyPercent: transparencyPercent ?? this.transparencyPercent,
      showPlace: showPlace ?? this.showPlace,
      showTemperature: showTemperature ?? this.showTemperature,
      showWeatherIcon: showWeatherIcon ?? this.showWeatherIcon,
      showWarningLight: showWarningLight ?? this.showWarningLight,
    );
  }
}
