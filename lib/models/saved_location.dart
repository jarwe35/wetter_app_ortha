class SavedLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? timezone;

  const SavedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.timezone,
  });

  factory SavedLocation.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];

    if (name is! String || name.trim().isEmpty) {
      throw const FormatException(
        'SavedLocation enthält keinen gültigen Ortsnamen.',
      );
    }

    if (latitude is! num || longitude is! num) {
      throw const FormatException(
        'SavedLocation enthält keine gültigen Koordinaten.',
      );
    }

    return SavedLocation(
      name: name.trim(),
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
      country: json['country'] is String ? json['country'] as String : null,
      timezone: json['timezone'] is String ? json['timezone'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (country != null) 'country': country,
      if (timezone != null) 'timezone': timezone,
    };
  }

  SavedLocation copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? timezone,
  }) {
    return SavedLocation(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      timezone: timezone ?? this.timezone,
    );
  }

  bool hasSameCoordinatesAs(SavedLocation other) {
    return latitude == other.latitude && longitude == other.longitude;
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SavedLocation &&
            name == other.name &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            country == other.country &&
            timezone == other.timezone;
  }

  @override
  int get hashCode {
    return Object.hash(name, latitude, longitude, country, timezone);
  }

  @override
  String toString() {
    return 'SavedLocation('
        'name: $name, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'country: $country, '
        'timezone: $timezone'
        ')';
  }
}
