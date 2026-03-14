import 'package:flutter/material.dart';
import '../core/theme/colors.dart';

/// Alert severity levels
enum AlertSeverity { low, medium, high, critical }

/// Alert categories for community reporting
enum AlertCategory {
  harassment,
  suspiciousBehavior,
  poorLighting,
  unsafeStreet,
  crowdedArea,
  policeActivity,
  accident,
  other,
}

/// A community-reported safety alert
class AlertModel {
  final String id;
  final AlertCategory category;
  final AlertSeverity severity;
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final DateTime timestamp;
  final int upvoteCount;
  final bool isVerified;
  final String? reporterAvatarInitial;

  const AlertModel({
    required this.id,
    required this.category,
    required this.severity,
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    required this.timestamp,
    this.upvoteCount = 0,
    this.isVerified = false,
    this.reporterAvatarInitial,
  });

  /// Human-readable category label
  String get categoryLabel => switch (category) {
    AlertCategory.harassment => 'Harassment',
    AlertCategory.suspiciousBehavior => 'Suspicious Behavior',
    AlertCategory.poorLighting => 'Poor Lighting',
    AlertCategory.unsafeStreet => 'Unsafe Street',
    AlertCategory.crowdedArea => 'Crowded Area',
    AlertCategory.policeActivity => 'Police Activity',
    AlertCategory.accident => 'Accident',
    AlertCategory.other => 'Other',
  };

  /// Icon for each category
  IconData get categoryIcon => switch (category) {
    AlertCategory.harassment => Icons.report_problem_rounded,
    AlertCategory.suspiciousBehavior => Icons.visibility_rounded,
    AlertCategory.poorLighting => Icons.lightbulb_outline_rounded,
    AlertCategory.unsafeStreet => Icons.warning_amber_rounded,
    AlertCategory.crowdedArea => Icons.people_rounded,
    AlertCategory.policeActivity => Icons.local_police_rounded,
    AlertCategory.accident => Icons.car_crash_rounded,
    AlertCategory.other => Icons.info_outline_rounded,
  };

  /// Semantic color for severity
  Color get severityColor => switch (severity) {
    AlertSeverity.low => PresenceColors.safeGreen,
    AlertSeverity.medium => PresenceColors.cautionAmber,
    AlertSeverity.high => PresenceColors.alertOrange,
    AlertSeverity.critical => PresenceColors.dangerRed,
  };

  Color get severitySurface => switch (severity) {
    AlertSeverity.low => PresenceColors.safeGreenSurface,
    AlertSeverity.medium => PresenceColors.cautionAmberSurface,
    AlertSeverity.high => PresenceColors.alertOrangeSurface,
    AlertSeverity.critical => PresenceColors.dangerRedSurface,
  };

  String get severityLabel => switch (severity) {
    AlertSeverity.low => 'Low',
    AlertSeverity.medium => 'Medium',
    AlertSeverity.high => 'High',
    AlertSeverity.critical => 'Critical',
  };

  /// Relative timestamp string
  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  AlertModel copyWith({int? upvoteCount}) => AlertModel(
    id: id,
    category: category,
    severity: severity,
    title: title,
    description: description,
    latitude: latitude,
    longitude: longitude,
    locationName: locationName,
    timestamp: timestamp,
    upvoteCount: upvoteCount ?? this.upvoteCount,
    isVerified: isVerified,
    reporterAvatarInitial: reporterAvatarInitial,
  );
}

/// Mock alert data for prototype
class MockAlerts {
  static final List<AlertModel> alerts = [
    AlertModel(
      id: '1',
      category: AlertCategory.poorLighting,
      severity: AlertSeverity.medium,
      title: 'Dark underpass on Oak Street',
      description: 'Street lights are broken. Very dark at night.',
      latitude: 37.7749,
      longitude: -122.4194,
      locationName: 'Oak Street underpass',
      timestamp: DateTime.now().subtract(const Duration(minutes: 23)),
      upvoteCount: 14,
      isVerified: true,
      reporterAvatarInitial: 'S',
    ),
    AlertModel(
      id: '2',
      category: AlertCategory.suspiciousBehavior,
      severity: AlertSeverity.high,
      title: 'Suspicious group near Park Ave',
      description: 'Group of individuals approached multiple people near the entrance.',
      latitude: 37.7751,
      longitude: -122.4180,
      locationName: 'Park Avenue entrance',
      timestamp: DateTime.now().subtract(const Duration(minutes: 47)),
      upvoteCount: 8,
      isVerified: false,
      reporterAvatarInitial: 'M',
    ),
    AlertModel(
      id: '3',
      category: AlertCategory.harassment,
      severity: AlertSeverity.high,
      title: 'Verbal harassment reported',
      description: 'Woman was verbally harassed near the bus stop. Avoid the area.',
      latitude: 37.7760,
      longitude: -122.4170,
      locationName: 'Mission St bus stop',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      upvoteCount: 31,
      isVerified: true,
      reporterAvatarInitial: 'A',
    ),
    AlertModel(
      id: '4',
      category: AlertCategory.unsafeStreet,
      severity: AlertSeverity.medium,
      title: 'Broken sidewalk — tripping hazard',
      description: 'Large cracks in pavement near the intersection.',
      latitude: 37.7740,
      longitude: -122.4200,
      locationName: 'Market & 5th intersection',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      upvoteCount: 6,
      isVerified: false,
      reporterAvatarInitial: 'J',
    ),
    AlertModel(
      id: '5',
      category: AlertCategory.policeActivity,
      severity: AlertSeverity.low,
      title: 'Police presence on Union Square',
      description: 'Increased police patrol in the area. Stay calm.',
      latitude: 37.7879,
      longitude: -122.4074,
      locationName: 'Union Square',
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      upvoteCount: 22,
      isVerified: true,
      reporterAvatarInitial: 'R',
    ),
    AlertModel(
      id: '6',
      category: AlertCategory.poorLighting,
      severity: AlertSeverity.critical,
      title: 'Entire block without lighting',
      description: 'Power outage on Elm Street — the whole block is pitch black.',
      latitude: 37.7730,
      longitude: -122.4210,
      locationName: 'Elm Street block',
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      upvoteCount: 45,
      isVerified: true,
      reporterAvatarInitial: 'K',
    ),
  ];
}
