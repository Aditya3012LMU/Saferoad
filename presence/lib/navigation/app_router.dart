import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_map_screen.dart';
import '../screens/route_planner/route_planner_screen.dart';
import '../screens/safe_walk/safe_walk_screen.dart';
import '../screens/community/community_alerts_screen.dart';
import '../screens/community/report_incident_screen.dart';
import '../screens/profile/profile_screen.dart';
import 'bottom_nav.dart';
import '../state/user_provider.dart';

/// Route path constants
class AppRoutes {
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const routePlanner = '/route-planner';
  static const safeWalk = '/safe-walk';
  static const community = '/community';
  static const reportIncident = '/report-incident';
  static const profile = '/profile';
}

/// Global GoRouter instance
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      // Could check onboarding state here for production
      return null;
    },
    routes: [
      // ── Onboarding (outside shell) ─────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _fadePage(
          state,
          const OnboardingScreen(),
        ),
      ),

      // ── Safe Walk (full-screen, outside shell) ─────────────────────────
      GoRoute(
        path: AppRoutes.safeWalk,
        pageBuilder: (context, state) => _slidePage(
          state,
          const SafeWalkScreen(),
        ),
      ),

      // ── Report Incident (modal) ────────────────────────────────────────
      GoRoute(
        path: AppRoutes.reportIncident,
        pageBuilder: (context, state) => _slidePage(
          state,
          const ReportIncidentScreen(),
        ),
      ),

      // ── Main Shell with Bottom Nav ─────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (context, state) => _noTransitionPage(state, const HomeMapScreen()),
          ),
          GoRoute(
            path: AppRoutes.routePlanner,
            pageBuilder: (context, state) => _noTransitionPage(state, const RoutePlannerScreen()),
          ),
          GoRoute(
            path: AppRoutes.community,
            pageBuilder: (context, state) => _noTransitionPage(state, const CommunityAlertsScreen()),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _noTransitionPage(state, const ProfileScreen()),
          ),
        ],
      ),
    ],
  );
});

/// Fade page transition
CustomTransitionPage _fadePage(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    );

/// Slide-up transition (for modals/full-screen overlays)
CustomTransitionPage _slidePage(GoRouterState state, Widget child) =>
    CustomTransitionPage(
      key: state.pageKey,
      child: child,
      transitionsBuilder: (_, animation, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
        child: child,
      ),
    );

/// No transition for bottom-nav tabs
NoTransitionPage _noTransitionPage(GoRouterState state, Widget child) =>
    NoTransitionPage(key: state.pageKey, child: child);
