import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Location permission and position stream service

class LocationService {
  /// Request location permission from user
  static Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;
    return true;
  }

  /// Get the current position
  static Future<Position?> getCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  /// Stream of position updates
  static Stream<Position> positionStream() => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    ),
  );

  /// Calculate distance between two points in meters
  static double distanceBetween(
    double startLat, double startLng,
    double endLat, double endLng,
  ) =>
      Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
}

/// Provider for current user position
final userPositionProvider = StreamProvider<Position?>((ref) async* {
  final hasPermission = await LocationService.requestPermission();
  if (!hasPermission) {
    yield null;
    return;
  }

  final initial = await LocationService.getCurrentPosition();
  yield initial;

  await for (final position in LocationService.positionStream()) {
    yield position;
  }
});

/// Provider for location permission status
final locationPermissionProvider = FutureProvider<bool>((ref) async {
  return await LocationService.requestPermission();
});
