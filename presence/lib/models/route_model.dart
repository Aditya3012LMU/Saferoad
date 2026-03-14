import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/theme/colors.dart';

/// Route type preference
enum RouteType { safest, fastest, mostActive }

/// Safety level of a route segment
enum SegmentSafety { safe, caution, danger }

/// A route option shown to the user
class RouteModel {
  final String id;
  final RouteType type;
  final String title;
  final String subtitle;
  final int safetyScore;     // 0-100
  final double distanceKm;
  final int estimatedMinutes;
  final double lightingScore; // 0-100
  final double crowdScore;    // 0-100
  final List<LatLng> waypoints;
  final List<String> highlights;
  final List<String> warnings;
  final bool isRecommended;

  const RouteModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.safetyScore,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.lightingScore,
    required this.crowdScore,
    required this.waypoints,
    required this.highlights,
    required this.warnings,
    this.isRecommended = false,
  });

  Color get safetyColor {
    if (safetyScore >= 75) return PresenceColors.safeGreen;
    if (safetyScore >= 50) return PresenceColors.cautionAmber;
    return PresenceColors.dangerRed;
  }

  Color get safetySurface {
    if (safetyScore >= 75) return PresenceColors.safeGreenSurface;
    if (safetyScore >= 50) return PresenceColors.cautionAmberSurface;
    return PresenceColors.dangerRedSurface;
  }

  String get safetyLabel {
    if (safetyScore >= 75) return 'Safe';
    if (safetyScore >= 50) return 'Caution';
    return 'Unsafe';
  }

  IconData get typeIcon => switch (type) {
    RouteType.safest => Icons.shield_rounded,
    RouteType.fastest => Icons.bolt_rounded,
    RouteType.mostActive => Icons.people_rounded,
  };

  String get typeLabel => switch (type) {
    RouteType.safest => 'Safest Route',
    RouteType.fastest => 'Fastest Route',
    RouteType.mostActive => 'Most Active',
  };

  String get distanceLabel => distanceKm < 1
    ? '${(distanceKm * 1000).round()}m'
    : '${distanceKm.toStringAsFixed(1)}km';

  String get durationLabel => estimatedMinutes < 60
    ? '${estimatedMinutes} min'
    : '${estimatedMinutes ~/ 60}h ${estimatedMinutes % 60}min';
}

/// Mock route data
class MockRoutes {
  static final List<RouteModel> routes = [
    RouteModel(
      id: 'route_safe',
      type: RouteType.safest,
      title: 'Via Market Street',
      subtitle: 'Well-lit, high pedestrian traffic',
      safetyScore: 92,
      distanceKm: 1.8,
      estimatedMinutes: 22,
      lightingScore: 95,
      crowdScore: 88,
      waypoints: const [
        LatLng(37.7749, -122.4194),
        LatLng(37.7760, -122.4180),
        LatLng(37.7770, -122.4165),
        LatLng(37.7780, -122.4150),
      ],
      highlights: ['High foot traffic', 'Well-lit streets', 'CCTV coverage', 'Bus stops nearby'],
      warnings: [],
      isRecommended: true,
    ),
    RouteModel(
      id: 'route_fast',
      type: RouteType.fastest,
      title: 'Via Oak Street',
      subtitle: 'Shorter path, moderate lighting',
      safetyScore: 61,
      distanceKm: 1.2,
      estimatedMinutes: 15,
      lightingScore: 58,
      crowdScore: 45,
      waypoints: const [
        LatLng(37.7749, -122.4194),
        LatLng(37.7755, -122.4188),
        LatLng(37.7765, -122.4175),
        LatLng(37.7780, -122.4150),
      ],
      highlights: ['Fastest route', 'Quiet streets'],
      warnings: ['Poor lighting after 8PM', 'Low foot traffic', 'Dark underpass'],
      isRecommended: false,
    ),
    RouteModel(
      id: 'route_active',
      type: RouteType.mostActive,
      title: 'Via Union Square',
      subtitle: 'Busiest streets, lots of people',
      safetyScore: 85,
      distanceKm: 2.1,
      estimatedMinutes: 26,
      lightingScore: 90,
      crowdScore: 97,
      waypoints: const [
        LatLng(37.7749, -122.4194),
        LatLng(37.7770, -122.4170),
        LatLng(37.7800, -122.4140),
        LatLng(37.7780, -122.4150),
      ],
      highlights: ['Maximum crowd density', 'Multiple open shops', 'Police presence nearby'],
      warnings: ['Slightly longer path'],
      isRecommended: false,
    ),
  ];
}
