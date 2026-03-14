import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/route_model.dart';

/// Currently selected route for navigation
final selectedRouteProvider = StateProvider<RouteModel?>((ref) => null);

/// Active route type filter
final activeRouteTypeProvider = StateProvider<RouteType>((ref) => RouteType.safest);

/// Available routes (normally from a routing API)
final availableRoutesProvider = Provider<List<RouteModel>>((ref) => MockRoutes.routes);

/// Destination search query
final destinationQueryProvider = StateProvider<String>((ref) => '');

/// Whether route planning mode is open
final routePlanningActiveProvider = StateProvider<bool>((ref) => false);

/// Safe walk progress (0.0 - 1.0)
final safeWalkProgressProvider = StateProvider<double>((ref) => 0.0);

/// Safe walk elapsed time in seconds
final safeWalkElapsedProvider = StateProvider<int>((ref) => 0);

/// Route waypoint index currently at
final currentWaypointProvider = StateProvider<int>((ref) => 0);

/// Upcoming safety alerts on active route
final routeAlertsProvider = Provider<List<String>>((ref) {
  final route = ref.watch(selectedRouteProvider);
  return route?.warnings ?? [];
});
