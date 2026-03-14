import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../components/sos_button.dart';
import '../../components/alert_banner.dart';
import '../../models/alert_model.dart';
import '../../models/route_model.dart';
import '../../navigation/app_router.dart';
import '../../state/route_provider.dart';
import '../../state/user_provider.dart';

/// Full-screen safe walk navigation mode.
/// Shows map, progress, live alerts, and SOS.
class SafeWalkScreen extends ConsumerStatefulWidget {
  const SafeWalkScreen({super.key});

  @override
  ConsumerState<SafeWalkScreen> createState() => _SafeWalkScreenState();
}

class _SafeWalkScreenState extends ConsumerState<SafeWalkScreen>
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _pulseController;
  Timer? _walkTimer;
  int _elapsedSeconds = 0;
  bool _showAlert = false;
  bool _arrived = false;
  double _progress = 0.0;

  // Simulated alerts triggered during walk
  final List<_WalkAlert> _activeAlerts = [];

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    ref.read(safeWalkActiveProvider.notifier).state = true;
    _startWalk();
  }

  void _startWalk() {
    _walkTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _elapsedSeconds++;
        _progress = (_elapsedSeconds / 90).clamp(0.0, 1.0);
        if (_progress >= 1.0 && !_arrived) {
          _arrived = true;
          timer.cancel();
          _showArrivalDialog();
        }
      });

      // Trigger simulated alert at 15s
      if (_elapsedSeconds == 15 && _activeAlerts.isEmpty) {
        setState(() {
          _activeAlerts.add(const _WalkAlert(
            message: 'Dark area ahead — poor lighting on Oak Street',
            severity: AlertSeverity.medium,
            icon: Icons.lightbulb_outline_rounded,
          ));
        });
        HapticFeedback.mediumImpact();
      }
      if (_elapsedSeconds == 35) {
        setState(() {
          _activeAlerts.add(const _WalkAlert(
            message: 'Suspicious activity reported 100m to the left',
            severity: AlertSeverity.high,
            icon: Icons.visibility_rounded,
          ));
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _showArrivalDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: PresenceColors.safeGreen, size: 28),
            SizedBox(width: 12),
            Text('You Arrived!'),
          ],
        ),
        content: const Text(
          'You have safely reached your destination. Your emergency contacts have been notified.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.go(AppRoutes.home);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _endWalk() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('End Safe Walk?'),
        content: const Text('Are you sure you want to end your safe walk session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Continue'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PresenceColors.dangerRed),
            onPressed: () {
              _walkTimer?.cancel();
              ref.read(safeWalkActiveProvider.notifier).state = false;
              Navigator.pop(ctx);
              context.go(AppRoutes.home);
            },
            child: const Text('End Walk'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _walkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = ref.watch(selectedRouteProvider) ?? MockRoutes.routes[0];
    final remainingMinutes = ((route.estimatedMinutes * (1 - _progress)).round());

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        body: Stack(
          children: [
            // ── Map ──────────────────────────────────────────────────────
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  37.7749 + (_progress * 0.003),
                  -122.4194 + (_progress * 0.002),
                ),
                zoom: 17,
                tilt: 30,
                bearing: 45,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              compassEnabled: true,
              mapToolbarEnabled: false,
              polylines: {
                Polyline(
                  polylineId: const PolylineId('walk_route'),
                  color: PresenceColors.mapSafeRoute,
                  width: 6,
                  points: route.waypoints,
                  startCap: Cap.roundCap,
                  endCap: Cap.roundCap,
                  jointType: JointType.round,
                ),
              },
              markers: {
                Marker(
                  markerId: const MarkerId('destination'),
                  position: route.waypoints.last,
                  infoWindow: const InfoWindow(title: 'Destination'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
              },
              padding: const EdgeInsets.only(bottom: 260),
            ),

            // ── Safe Walk Active Indicator ───────────────────────────────
            SafeArea(
              child: Column(
                children: [
                  // Top nav bar
                  _SafeWalkTopBar(
                    onEnd: _endWalk,
                    elapsedSeconds: _elapsedSeconds,
                    pulse: _pulseController,
                  ),

                  // Active alerts
                  ..._activeAlerts.reversed.take(1).map((alert) => AlertBanner(
                    message: alert.message,
                    severity: alert.severity,
                    icon: alert.icon,
                    onDismiss: () => setState(() => _activeAlerts.remove(alert)),
                    actionLabel: 'Reroute',
                    onAction: () {},
                  )),
                ],
              ),
            ),

            // ── Bottom Panel ─────────────────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _SafeWalkBottomPanel(
                route: route,
                progress: _progress,
                remainingMinutes: remainingMinutes,
                elapsedSeconds: _elapsedSeconds,
              ),
            ),

            // ── SOS Button ───────────────────────────────────────────────
            Positioned(
              right: 16,
              bottom: 240,
              child: const SOSFloatingButton(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafeWalkTopBar extends StatelessWidget {
  final VoidCallback onEnd;
  final int elapsedSeconds;
  final AnimationController pulse;

  const _SafeWalkTopBar({
    required this.onEnd,
    required this.elapsedSeconds,
    required this.pulse,
  });

  String get _elapsed {
    final m = elapsedSeconds ~/ 60;
    final s = elapsedSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: PresenceColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 16,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pulsing safe walk indicator
          AnimatedBuilder(
            animation: pulse,
            builder: (context, _) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: PresenceColors.safeGreen,
                boxShadow: [
                  BoxShadow(
                    color: PresenceColors.safeGreen
                        .withOpacity(0.4 + pulse.value * 0.4),
                    blurRadius: 6 + pulse.value * 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Safe Walk Active',
            style: PresenceTypography.textTheme.titleSmall?.copyWith(
              color: PresenceColors.safeGreen,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Elapsed timer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: PresenceColors.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _elapsed,
              style: PresenceTypography.textTheme.labelMedium?.copyWith(
                fontFamily: 'monospace',
                color: PresenceColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // End walk
          GestureDetector(
            onTap: onEnd,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: PresenceColors.dangerRedSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.stop_rounded,
                color: PresenceColors.dangerRed,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0);
  }
}

class _SafeWalkBottomPanel extends StatelessWidget {
  final RouteModel route;
  final double progress;
  final int remainingMinutes;
  final int elapsedSeconds;

  const _SafeWalkBottomPanel({
    required this.route,
    required this.progress,
    required this.remainingMinutes,
    required this.elapsedSeconds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 16 + MediaQuery.of(context).padding.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 32,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: PresenceColors.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Progress bar
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress',
                          style: PresenceTypography.textTheme.labelMedium
                              ?.copyWith(color: PresenceColors.onSurfaceDim),
                        ),
                        Text(
                          '${(progress * 100).round()}%',
                          style: PresenceTypography.textTheme.labelMedium
                              ?.copyWith(color: PresenceColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, value, _) => LinearProgressIndicator(
                        value: value,
                        minHeight: 8,
                        backgroundColor: PresenceColors.primaryContainer,
                        valueColor: const AlwaysStoppedAnimation(
                          PresenceColors.primary,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Stats
          Row(
            children: [
              _WalkStat(
                icon: Icons.access_time_rounded,
                value: '$remainingMinutes min',
                label: 'Remaining',
                color: PresenceColors.primary,
              ),
              const SizedBox(width: 16),
              _WalkStat(
                icon: Icons.directions_walk_rounded,
                value: route.distanceLabel,
                label: 'Total',
                color: PresenceColors.secondary,
              ),
              const SizedBox(width: 16),
              _WalkStat(
                icon: Icons.shield_rounded,
                value: '${route.safetyScore}',
                label: 'Safety',
                color: route.safetyColor,
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Destination info
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: PresenceColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.navigation_rounded,
                    color: PresenceColors.primary, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Heading to',
                        style: PresenceTypography.textTheme.bodySmall
                            ?.copyWith(color: PresenceColors.onSurfaceDim),
                      ),
                      Text(
                        route.title,
                        style: PresenceTypography.textTheme.titleSmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: PresenceColors.safeGreenSurface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    route.safetyLabel,
                    style: PresenceTypography.textTheme.labelSmall?.copyWith(
                      color: PresenceColors.safeGreen,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WalkStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _WalkStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: PresenceTypography.safetyScore(16, color),
            ),
            Text(
              label,
              style: PresenceTypography.textTheme.labelSmall
                  ?.copyWith(color: PresenceColors.onSurfaceDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalkAlert {
  final String message;
  final AlertSeverity severity;
  final IconData icon;

  const _WalkAlert({
    required this.message,
    required this.severity,
    required this.icon,
  });
}
