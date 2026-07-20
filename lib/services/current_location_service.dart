import 'package:geolocator/geolocator.dart';

import '../models/saved_location.dart';

enum CurrentLocationFailure {
  servicesDisabled,
  permissionDenied,
  permissionPermanentlyDenied,
  unavailable,
}

class CurrentLocationException implements Exception {
  final CurrentLocationFailure failure;
  final String message;

  const CurrentLocationException({
    required this.failure,
    required this.message,
  });

  @override
  String toString() => message;
}

class CurrentLocationService {
  const CurrentLocationService();

  Future<SavedLocation> determineCurrentLocation() async {
    final servicesEnabled = await Geolocator.isLocationServiceEnabled();

    if (!servicesEnabled) {
      throw const CurrentLocationException(
        failure: CurrentLocationFailure.servicesDisabled,
        message:
            'Die Standortdienste sind deaktiviert. Bitte aktiviere GPS und versuche es erneut.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const CurrentLocationException(
        failure: CurrentLocationFailure.permissionDenied,
        message: 'Der Zugriff auf Deinen Standort wurde nicht erlaubt.',
      );
    }

    if (permission == LocationPermission.deniedForever) {
      throw const CurrentLocationException(
        failure: CurrentLocationFailure.permissionPermanentlyDenied,
        message:
            'Der Standortzugriff wurde dauerhaft abgelehnt. Bitte erlaube ihn in den Systemeinstellungen.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      return SavedLocation(
        name: 'Mein Standort',
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (_) {
      throw const CurrentLocationException(
        failure: CurrentLocationFailure.unavailable,
        message:
            'Dein aktueller Standort konnte momentan nicht bestimmt werden.',
      );
    }
  }

  Future<bool> openLocationSettings() {
    return Geolocator.openLocationSettings();
  }

  Future<bool> openAppSettings() {
    return Geolocator.openAppSettings();
  }
}
