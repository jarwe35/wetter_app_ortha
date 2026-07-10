enum TemperatureUnit { celsius, fahrenheit }

enum WindSpeedUnit { kilometersPerHour, knots }

enum VisibilityUnit { kilometers, miles }

enum PrecipitationUnit { millimeters, inches }

class UnitSettings {
  final TemperatureUnit temperatureUnit;
  final WindSpeedUnit windSpeedUnit;
  final VisibilityUnit visibilityUnit;
  final PrecipitationUnit precipitationUnit;

  const UnitSettings({
    this.temperatureUnit = TemperatureUnit.celsius,
    this.windSpeedUnit = WindSpeedUnit.kilometersPerHour,
    this.visibilityUnit = VisibilityUnit.kilometers,
    this.precipitationUnit = PrecipitationUnit.millimeters,
  });

  UnitSettings copyWith({
    TemperatureUnit? temperatureUnit,
    WindSpeedUnit? windSpeedUnit,
    VisibilityUnit? visibilityUnit,
    PrecipitationUnit? precipitationUnit,
  }) {
    return UnitSettings(
      temperatureUnit: temperatureUnit ?? this.temperatureUnit,
      windSpeedUnit: windSpeedUnit ?? this.windSpeedUnit,
      visibilityUnit: visibilityUnit ?? this.visibilityUnit,
      precipitationUnit: precipitationUnit ?? this.precipitationUnit,
    );
  }

  Map<String, String> toMap() {
    return {
      'temperatureUnit': temperatureUnit.name,
      'windSpeedUnit': windSpeedUnit.name,
      'visibilityUnit': visibilityUnit.name,
      'precipitationUnit': precipitationUnit.name,
    };
  }

  factory UnitSettings.fromMap(Map<String, String> map) {
    return UnitSettings(
      temperatureUnit: TemperatureUnit.values.firstWhere(
        (value) => value.name == map['temperatureUnit'],
        orElse: () => TemperatureUnit.celsius,
      ),
      windSpeedUnit: WindSpeedUnit.values.firstWhere(
        (value) => value.name == map['windSpeedUnit'],
        orElse: () => WindSpeedUnit.kilometersPerHour,
      ),
      visibilityUnit: VisibilityUnit.values.firstWhere(
        (value) => value.name == map['visibilityUnit'],
        orElse: () => VisibilityUnit.kilometers,
      ),
      precipitationUnit: PrecipitationUnit.values.firstWhere(
        (value) => value.name == map['precipitationUnit'],
        orElse: () => PrecipitationUnit.millimeters,
      ),
    );
  }
}
