import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/alert_model.dart';

/// All community alerts
final communityAlertsProvider =
    StateNotifierProvider<CommunityAlertsNotifier, List<AlertModel>>(
  (ref) => CommunityAlertsNotifier(),
);

class CommunityAlertsNotifier extends StateNotifier<List<AlertModel>> {
  CommunityAlertsNotifier() : super(MockAlerts.alerts);

  void addAlert(AlertModel alert) {
    state = [alert, ...state];
  }

  void upvote(String alertId) {
    state = state.map((a) {
      if (a.id == alertId) return a.copyWith(upvoteCount: a.upvoteCount + 1);
      return a;
    }).toList();
  }

  void removeAlert(String alertId) {
    state = state.where((a) => a.id != alertId).toList();
  }
}

/// Active filter for community alerts
final alertFilterProvider = StateProvider<AlertCategory?>((ref) => null);

/// Filtered alerts (null = all)
final filteredAlertsProvider = Provider<List<AlertModel>>((ref) {
  final alerts = ref.watch(communityAlertsProvider);
  final filter = ref.watch(alertFilterProvider);
  if (filter == null) return alerts;
  return alerts.where((a) => a.category == filter).toList();
});

/// Alert severity filter
final alertSeverityFilterProvider = StateProvider<AlertSeverity?>((ref) => null);

/// Incident report form state
class IncidentReportState {
  final AlertCategory? selectedCategory;
  final AlertSeverity severity;
  final String description;
  final String locationName;
  final bool isSubmitting;
  final bool isSubmitted;

  const IncidentReportState({
    this.selectedCategory,
    this.severity = AlertSeverity.medium,
    this.description = '',
    this.locationName = '',
    this.isSubmitting = false,
    this.isSubmitted = false,
  });

  IncidentReportState copyWith({
    AlertCategory? selectedCategory,
    AlertSeverity? severity,
    String? description,
    String? locationName,
    bool? isSubmitting,
    bool? isSubmitted,
  }) =>
      IncidentReportState(
        selectedCategory: selectedCategory ?? this.selectedCategory,
        severity: severity ?? this.severity,
        description: description ?? this.description,
        locationName: locationName ?? this.locationName,
        isSubmitting: isSubmitting ?? this.isSubmitting,
        isSubmitted: isSubmitted ?? this.isSubmitted,
      );
}

final incidentReportProvider =
    StateNotifierProvider<IncidentReportNotifier, IncidentReportState>(
  (ref) => IncidentReportNotifier(ref),
);

class IncidentReportNotifier extends StateNotifier<IncidentReportState> {
  final Ref _ref;

  IncidentReportNotifier(this._ref) : super(const IncidentReportState());

  void selectCategory(AlertCategory category) =>
      state = state.copyWith(selectedCategory: category);

  void setSeverity(AlertSeverity severity) =>
      state = state.copyWith(severity: severity);

  void setDescription(String desc) => state = state.copyWith(description: desc);

  void setLocation(String location) => state = state.copyWith(locationName: location);

  void reset() => state = const IncidentReportState();

  Future<void> submit() async {
    if (state.selectedCategory == null) return;
    state = state.copyWith(isSubmitting: true);

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1200));

    final alert = AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: state.selectedCategory!,
      severity: state.severity,
      title: '${state.selectedCategory!.name} reported nearby',
      description: state.description.isEmpty
          ? 'Reported by community member'
          : state.description,
      latitude: 37.7749,
      longitude: -122.4194,
      locationName: state.locationName.isEmpty ? 'Current location' : state.locationName,
      timestamp: DateTime.now(),
      upvoteCount: 1,
      isVerified: false,
      reporterAvatarInitial: 'Y',
    );

    _ref.read(communityAlertsProvider.notifier).addAlert(alert);
    state = state.copyWith(isSubmitting: false, isSubmitted: true);
  }
}
