/// Overall safety score and area data for the home map

class AreaSafetyData {
  final int overallScore;       // 0–100
  final double lightingScore;
  final double crowdScore;
  final double incidentScore;   // Inverse of incident frequency
  final String areaName;
  final String statusMessage;
  final List<String> activeSafetyFeatures;

  const AreaSafetyData({
    required this.overallScore,
    required this.lightingScore,
    required this.crowdScore,
    required this.incidentScore,
    required this.areaName,
    required this.statusMessage,
    required this.activeSafetyFeatures,
  });

  String get scoreLabel {
    if (overallScore >= 80) return 'Safe';
    if (overallScore >= 60) return 'Moderate';
    if (overallScore >= 40) return 'Caution';
    return 'Unsafe';
  }

  /// For prototype — default location safety context
  static const AreaSafetyData downtown = AreaSafetyData(
    overallScore: 78,
    lightingScore: 82,
    crowdScore: 91,
    incidentScore: 61,
    areaName: 'Downtown',
    statusMessage: 'Area is moderately safe. Foot traffic is high.',
    activeSafetyFeatures: [
      'CCTV Coverage',
      'Police Patrol Active',
      'Bus Stop Nearby',
      'Open Businesses',
    ],
  );

  static const AreaSafetyData residential = AreaSafetyData(
    overallScore: 55,
    lightingScore: 60,
    crowdScore: 38,
    incidentScore: 67,
    areaName: 'Residential Zone',
    statusMessage: 'Quiet area. Stay alert — limited foot traffic.',
    activeSafetyFeatures: [
      'Residential Area',
      'Low Incident Rate',
    ],
  );
}

/// Emergency contact model
class EmergencyContact {
  final String name;
  final String phone;
  final String relation;
  final bool isPrimary;

  const EmergencyContact({
    required this.name,
    required this.phone,
    required this.relation,
    this.isPrimary = false,
  });
}
