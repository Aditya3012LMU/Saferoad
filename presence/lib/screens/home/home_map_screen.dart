import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../components/safety_score_card.dart';
import '../../components/alert_banner.dart';
import '../../components/map_overlay_toggle.dart';
import '../../components/sos_button.dart';
import '../../models/alert_model.dart';
import '../../navigation/app_router.dart';
import '../../state/user_provider.dart';
import '../../state/community_provider.dart';

/// Home screen — live safety map with overlay layers and quick actions.
class HomeMapScreen extends ConsumerStatefulWidget {
  const HomeMapScreen({super.key});

  @override
  ConsumerState<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends ConsumerState<HomeMapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _mapLoaded = false;
  bool _showAlertBanner = true;
  bool _cardExpanded = false;

  // Default location — San Francisco downtown
  static const CameraPosition _defaultCamera = CameraPosition(
    target: LatLng(37.7749, -122.4194),
    zoom: 15.5,
    tilt: 15,
  );

  Set<Marker> _buildMarkers(List<AlertModel> alerts) {
    return {
      // User location pulse marker (simulated with a regular marker)
      const Marker(
        markerId: MarkerId('user_location'),
        position: LatLng(37.7749, -122.4194),
        infoWindow: InfoWindow(title: 'You are here'),
      ),
      // Police station markers
      const Marker(
        markerId: MarkerId('police_1'),
        position: LatLng(37.7760, -122.4210),
        infoWindow: InfoWindow(title: 'Mission Police Station'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      const Marker(
        markerId: MarkerId('police_2'),
        position: LatLng(37.7800, -122.4150),
        infoWindow: InfoWindow(title: 'Central Police Station'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
      // Community alert markers
      ...alerts.map((a) => Marker(
        markerId: MarkerId('alert_${a.id}'),
        position: LatLng(a.latitude, a.longitude),
        infoWindow: InfoWindow(title: a.title, snippet: a.locationName),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          a.severity == AlertSeverity.critical
              ? BitmapDescriptor.hueRed
              : a.severity == AlertSeverity.high
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueYellow,
        ),
      )),
    };
  }

  Set<Polyline> _buildPolylines() {
    return {
      const Polyline(
        polylineId: PolylineId('safe_route_1'),
        color: PresenceColors.mapSafeRoute,
        width: 5,
        points: [
          LatLng(37.7749, -122.4194),
          LatLng(37.7755, -122.4185),
          LatLng(37.7765, -122.4172),
          LatLng(37.7775, -122.4158),
        ],
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        jointType: JointType.round,
      ),
    };
  }

  Set<Circle> _buildCircles() {
    return {
      // User location accuracy circle
      Circle(
        circleId: const CircleId('user_accuracy'),
        center: const LatLng(37.7749, -122.4194),
        radius: 40,
        fillColor: PresenceColors.primary.withOpacity(0.12),
        strokeColor: PresenceColors.primary.withOpacity(0.4),
        strokeWidth: 2,
      ),
      // Danger zone overlay
      Circle(
        circleId: const CircleId('danger_zone_1'),
        center: const LatLng(37.7730, -122.4210),
        radius: 120,
        fillColor: PresenceColors.dangerRed.withOpacity(0.08),
        strokeColor: PresenceColors.dangerRed.withOpacity(0.3),
        strokeWidth: 2,
      ),
      // Caution zone
      Circle(
        circleId: const CircleId('caution_zone_1'),
        center: const LatLng(37.7760, -122.4180),
        radius: 80,
        fillColor: PresenceColors.cautionAmber.withOpacity(0.08),
        strokeColor: PresenceColors.cautionAmber.withOpacity(0.3),
        strokeWidth: 1,
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final safetyScore = ref.watch(currentSafetyScoreProvider);
    final areaSafety = ref.watch(currentAreaSafetyProvider);
    final alerts = ref.watch(communityAlertsProvider);
    final locationSharing = ref.watch(locationSharingProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PresenceColors.background,
        body: Stack(
          children: [
            // ── Google Map ─────────────────────────────────────────────────
            GoogleMap(
              initialCameraPosition: _defaultCamera,
              onMapCreated: (controller) {
                _mapController = controller;
                setState(() => _mapLoaded = true);
              },
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: false,
              mapToolbarEnabled: false,
              markers: _buildMarkers(alerts),
              polylines: _buildPolylines(),
              circles: _buildCircles(),
              padding: const EdgeInsets.only(bottom: 320),
            ),

            // ── Top Bar ────────────────────────────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  _TopBar(
                    safetyScore: safetyScore,
                    locationSharing: locationSharing,
                    onLocationShare: () {
                      HapticFeedback.mediumImpact();
                      ref.read(locationSharingProvider.notifier).state =
                          !locationSharing;
                    },
                    onLayersPressed: () => _showLayersSheet(context),
                  ),

                  // Alert Banner
                  if (_showAlertBanner)
                    AlertBanner(
                      message: 'Poorly lit area reported 200m ahead — Oak St',
                      severity: AlertSeverity.medium,
                      icon: Icons.lightbulb_outline_rounded,
                      onDismiss: () =>
                          setState(() => _showAlertBanner = false),
                      actionLabel: 'Reroute',
                      onAction: () => context.go(AppRoutes.routePlanner),
                    ),
                ],
              ),
            ),

            // ── Layer Toggle Row ───────────────────────────────────────────
            Positioned(
              top: MediaQuery.of(context).padding.top + (_showAlertBanner ? 145 : 80),
              left: 0,
              right: 0,
              child: const MapLayerToggleRow(),
            ),

            // ── Bottom Sheet Panel ─────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _BottomPanel(
                safetyScore: safetyScore,
                areaName: areaSafety.areaName,
                statusMessage: areaSafety.statusMessage,
                features: areaSafety.activeSafetyFeatures,
                onPlanRoute: () => context.go(AppRoutes.routePlanner),
                onExpand: () => setState(() => _cardExpanded = !_cardExpanded),
                expanded: _cardExpanded,
              ),
            ),

            // ── Recenter Button ────────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: _cardExpanded ? 380 : 260,
              child: _MapActionButton(
                icon: Icons.my_location_rounded,
                onTap: () => _mapController?.animateCamera(
                  CameraUpdate.newCameraPosition(_defaultCamera),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLayersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor: PresenceColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => const MapOverlayToggleSheet(),
    );
  }
}

// ── Top Bar ────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  final int safetyScore;
  final bool locationSharing;
  final VoidCallback onLocationShare;
  final VoidCallback onLayersPressed;

  const _TopBar({
    required this.safetyScore,
    required this.locationSharing,
    required this.onLocationShare,
    required this.onLayersPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // App brand
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: PresenceColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(Icons.shield_rounded,
                    color: PresenceColors.primary, size: 20),
                const SizedBox(width: 6),
                Text(
                  'presence',
                  style: PresenceTypography.textTheme.titleSmall?.copyWith(
                    color: PresenceColors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Safety score compact badge
          SafetyScoreCard(
            score: safetyScore,
            areaName: '',
            statusMessage: '',
            compact: true,
          ),

          const Spacer(),

          // Location share toggle
          _MapIconButton(
            icon: locationSharing
                ? Icons.share_location_rounded
                : Icons.location_disabled_rounded,
            active: locationSharing,
            onTap: onLocationShare,
            semanticLabel: 'Share location',
          ),
          const SizedBox(width: 8),

          // Layers button
          _MapIconButton(
            icon: Icons.layers_rounded,
            onTap: onLayersPressed,
            semanticLabel: 'Map layers',
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0);
  }
}

class _MapIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final String? semanticLabel;

  const _MapIconButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Semantics(
        label: semanticLabel,
        button: true,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: active
                ? PresenceColors.primaryContainer
                : PresenceColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: active ? PresenceColors.primary : PresenceColors.onSurface,
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MapActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: PresenceColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: PresenceColors.onSurface, size: 20),
      ),
    );
  }
}

// ── Bottom Panel ───────────────────────────────────────────────────────────
class _BottomPanel extends StatelessWidget {
  final int safetyScore;
  final String areaName;
  final String statusMessage;
  final List<String> features;
  final VoidCallback onPlanRoute;
  final VoidCallback onExpand;
  final bool expanded;

  const _BottomPanel({
    required this.safetyScore,
    required this.areaName,
    required this.statusMessage,
    required this.features,
    required this.onPlanRoute,
    required this.onExpand,
    required this.expanded,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: PresenceColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          GestureDetector(
            onTap: onExpand,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: PresenceColors.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Location & time
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 16, color: PresenceColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      'Downtown San Francisco',
                      style: PresenceTypography.textTheme.bodyMedium?.copyWith(
                        color: PresenceColors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _currentTime(),
                      style: PresenceTypography.textTheme.bodySmall?.copyWith(
                        color: PresenceColors.onSurfaceDim,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Safety score card
                SafetyScoreCard(
                  score: safetyScore,
                  areaName: areaName,
                  statusMessage: statusMessage,
                  features: expanded ? features : [],
                  compact: false,
                ),

                const SizedBox(height: 16),

                // Quick action buttons
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        onPressed: onPlanRoute,
                        icon: const Icon(Icons.route_rounded, size: 18),
                        label: const Text('Plan Safe Route'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Icon(Icons.share_location_rounded, size: 20),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  String _currentTime() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
