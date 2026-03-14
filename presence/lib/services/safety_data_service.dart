import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/safety_data.dart';

/// Safety data service — simulates real-time safety scoring
/// In production, this would connect to a backend API.

class SafetyDataService {
  static final Random _random = Random();

  /// Compute a safety score given location context
  /// Score: 0–100 (higher = safer)
  static int computeAreaScore({
    required double lat,
    required double lng,
    required DateTime time,
  }) {
    // Simulate time-based safety factor
    final hour = time.hour;
    int timeScore;
    if (hour >= 7 && hour <= 20) {
      timeScore = 85 + _random.nextInt(10);  // Daytime — safer
    } else if (hour > 20 && hour <= 23) {
      timeScore = 60 + _random.nextInt(20);  // Evening
    } else {
      timeScore = 35 + _random.nextInt(25);  // Night — less safe
    }

    return timeScore.clamp(0, 100);
  }

  /// Lighting score based on time
  static double lightingScore(DateTime time) {
    final hour = time.hour;
    if (hour >= 7 && hour <= 19) return 95.0;
    if (hour == 6 || hour == 20) return 75.0;
    if (hour == 5 || hour == 21) return 50.0;
    return 30.0;
  }

  /// Crowd score (simulated based on time/location)
  static double crowdScore(DateTime time) {
    final hour = time.hour;
    if (hour >= 8 && hour <= 10) return 90.0;  // Morning commute
    if (hour >= 17 && hour <= 19) return 92.0; // Evening commute
    if (hour >= 11 && hour <= 16) return 75.0; // Midday
    if (hour >= 20 && hour <= 22) return 55.0; // Evening
    return 25.0;                                // Late night
  }

  /// Incident score (lower incidents = higher score)
  static double incidentScore() => 60 + _random.nextDouble() * 25;

  /// Get area safety data for current position
  static AreaSafetyData getAreaData(double lat, double lng) {
    // Downtown area simulation
    return AreaSafetyData(
      overallScore: computeAreaScore(lat: lat, lng: lng, time: DateTime.now()),
      lightingScore: lightingScore(DateTime.now()),
      crowdScore: crowdScore(DateTime.now()),
      incidentScore: incidentScore(),
      areaName: 'Downtown',
      statusMessage: _getStatusMessage(computeAreaScore(lat: lat, lng: lng, time: DateTime.now())),
      activeSafetyFeatures: _getSafetyFeatures(lat, lng),
    );
  }

  static String _getStatusMessage(int score) {
    if (score >= 80) return 'This area is safe. Enjoy your walk.';
    if (score >= 60) return 'Moderate safety. Stay aware of your surroundings.';
    if (score >= 40) return 'Use caution. Consider an alternate route.';
    return 'This area is unsafe. Please take a different route.';
  }

  static List<String> _getSafetyFeatures(double lat, double lng) {
    return [
      'CCTV Coverage',
      'Police Patrol Active',
      'Well-lit Streets',
      'High Foot Traffic',
    ];
  }
}

/// Auto-refreshing safety score provider
final safetyScoreStreamProvider = StreamProvider<int>((ref) async* {
  while (true) {
    await Future.delayed(const Duration(seconds: 30));
    yield SafetyDataService.computeAreaScore(
      lat: 37.7749,
      lng: -122.4194,
      time: DateTime.now(),
    );
  }
});
