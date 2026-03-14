import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/safety_data.dart';

/// Onboarding completion state
final onboardingCompleteProvider = StateProvider<bool>((ref) => false);

/// Whether Safe Walk mode is active
final safeWalkActiveProvider = StateProvider<bool>((ref) => false);

/// Current safety score (dynamic, updated by location)
final currentSafetyScoreProvider = StateProvider<int>((ref) => 78);

/// Current area safety data
final currentAreaSafetyProvider = StateProvider<AreaSafetyData>(
  (ref) => AreaSafetyData.downtown,
);

/// User's emergency contacts
final emergencyContactsProvider =
    StateNotifierProvider<EmergencyContactsNotifier, List<EmergencyContact>>(
  (ref) => EmergencyContactsNotifier(),
);

class EmergencyContactsNotifier extends StateNotifier<List<EmergencyContact>> {
  EmergencyContactsNotifier()
      : super([
          const EmergencyContact(
            name: 'Mom',
            phone: '+1 (555) 234-5678',
            relation: 'Family',
            isPrimary: true,
          ),
          const EmergencyContact(
            name: 'Alex Chen',
            phone: '+1 (555) 876-5432',
            relation: 'Friend',
          ),
        ]);

  void addContact(EmergencyContact contact) {
    state = [...state, contact];
  }

  void removeContact(String name) {
    state = state.where((c) => c.name != name).toList();
  }

  void setPrimary(String name) {
    state = state.map((c) => EmergencyContact(
      name: c.name,
      phone: c.phone,
      relation: c.relation,
      isPrimary: c.name == name,
    )).toList();
  }
}

/// SOS activation state
final sosActivatedProvider = StateProvider<bool>((ref) => false);

/// Location sharing active
final locationSharingProvider = StateProvider<bool>((ref) => false);

/// Map overlay toggles
class MapOverlayState {
  final bool showSafeRoutes;
  final bool showCrowdDensity;
  final bool showLighting;
  final bool showPoliceStations;
  final bool showAlerts;

  const MapOverlayState({
    this.showSafeRoutes = true,
    this.showCrowdDensity = true,
    this.showLighting = true,
    this.showPoliceStations = true,
    this.showAlerts = true,
  });

  MapOverlayState copyWith({
    bool? showSafeRoutes,
    bool? showCrowdDensity,
    bool? showLighting,
    bool? showPoliceStations,
    bool? showAlerts,
  }) =>
      MapOverlayState(
        showSafeRoutes: showSafeRoutes ?? this.showSafeRoutes,
        showCrowdDensity: showCrowdDensity ?? this.showCrowdDensity,
        showLighting: showLighting ?? this.showLighting,
        showPoliceStations: showPoliceStations ?? this.showPoliceStations,
        showAlerts: showAlerts ?? this.showAlerts,
      );
}

final mapOverlayProvider =
    StateNotifierProvider<MapOverlayNotifier, MapOverlayState>(
  (ref) => MapOverlayNotifier(),
);

class MapOverlayNotifier extends StateNotifier<MapOverlayState> {
  MapOverlayNotifier() : super(const MapOverlayState());

  void toggle({
    bool? safeRoutes,
    bool? crowdDensity,
    bool? lighting,
    bool? policeStations,
    bool? alerts,
  }) {
    state = state.copyWith(
      showSafeRoutes: safeRoutes != null ? !state.showSafeRoutes : null,
      showCrowdDensity: crowdDensity != null ? !state.showCrowdDensity : null,
      showLighting: lighting != null ? !state.showLighting : null,
      showPoliceStations: policeStations != null ? !state.showPoliceStations : null,
      showAlerts: alerts != null ? !state.showAlerts : null,
    );
  }
}

/// Persistent onboarding check
final hasCompletedOnboardingProvider =
    FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('onboarding_complete') ?? false;
});

Future<void> setOnboardingComplete() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_complete', true);
}
