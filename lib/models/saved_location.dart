class SavedLocation {
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1;
  final String? timezone;

  const SavedLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
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
      admin1: json['admin1'] is String ? json['admin1'] as String : null,
      timezone: json['timezone'] is String ? json['timezone'] as String : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      if (country != null) 'country': country,
      if (admin1 != null) 'admin1': admin1,
      if (timezone != null) 'timezone': timezone,
    };
  }

  SavedLocation copyWith({
    String? name,
    double? latitude,
    double? longitude,
    String? country,
    String? admin1,
    String? timezone,
  }) {
    return SavedLocation(
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      country: country ?? this.country,
      admin1: admin1 ?? this.admin1,
      timezone: timezone ?? this.timezone,
    );
  }

  bool hasSameCoordinatesAs(SavedLocation other) {
    return latitude == other.latitude && longitude == other.longitude;
  }

  String get displayLabel {
    final parts = <String>[name];

    final normalizedName = name.trim().toLowerCase();

    if (admin1 != null &&
        admin1!.trim().isNotEmpty &&
        admin1!.trim().toLowerCase() != normalizedName) {
      parts.add(admin1!.trim());
    }

    if (country != null &&
        country!.trim().isNotEmpty &&
        country!.trim().toLowerCase() != normalizedName) {
      parts.add(country!.trim());
    }

    return parts.join(' · ');
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SavedLocation &&
            name == other.name &&
            latitude == other.latitude &&
            longitude == other.longitude &&
            country == other.country &&
            admin1 == other.admin1 &&
            timezone == other.timezone;
  }

  @override
  int get hashCode {
    return Object.hash(name, latitude, longitude, country, admin1, timezone);
  }

  @override
  String toString() {
    return 'SavedLocation('
        'name: $name, '
        'latitude: $latitude, '
        'longitude: $longitude, '
        'country: $country, '
        'admin1: $admin1, '
        'timezone: $timezone'
        ')';
  }
}
