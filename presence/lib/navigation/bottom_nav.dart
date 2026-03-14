import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../components/sos_button.dart';
import 'app_router.dart';

/// Main application shell with persistent bottom navigation and SOS button.
class MainShell extends StatefulWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const _destinations = [
    _NavDestination(
      path: AppRoutes.home,
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
      label: 'Home',
    ),
    _NavDestination(
      path: AppRoutes.routePlanner,
      icon: Icons.route_outlined,
      selectedIcon: Icons.route_rounded,
      label: 'Routes',
    ),
    _NavDestination(
      path: AppRoutes.community,
      icon: Icons.group_outlined,
      selectedIcon: Icons.group_rounded,
      label: 'Community',
    ),
    _NavDestination(
      path: AppRoutes.profile,
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  void _onDestinationSelected(int index) {
    setState(() => _currentIndex = index);
    context.go(_destinations[index].path);
  }

  String _locationToIndex(String location) {
    if (location.startsWith(AppRoutes.home)) return '0';
    if (location.startsWith(AppRoutes.routePlanner)) return '1';
    if (location.startsWith(AppRoutes.community)) return '2';
    if (location.startsWith(AppRoutes.profile)) return '3';
    return '0';
  }

  @override
  Widget build(BuildContext context) {
    // Sync index with current route
    final location = GoRouterState.of(context).uri.toString();
    final idx = int.parse(_locationToIndex(location));
    if (idx != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _currentIndex = idx);
      });
    }

    return Scaffold(
      body: widget.child,
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: SOSFloatingButton(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _PresenceBottomNav(
        currentIndex: _currentIndex,
        destinations: _destinations,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

class _PresenceBottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  const _PresenceBottomNav({
    required this.currentIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PresenceColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final isSelected = index == currentIndex;

              return Expanded(
                child: _NavItem(
                  icon: dest.icon,
                  selectedIcon: dest.selectedIcon,
                  label: dest.label,
                  isSelected: isSelected,
                  onTap: () => onDestinationSelected(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: isSelected ? 64 : 48,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected
                    ? PresenceColors.primaryContainer
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSelected ? selectedIcon : icon,
                color: isSelected
                    ? PresenceColors.primary
                    : PresenceColors.onSurfaceDim,
                size: 22,
                semanticLabel: label,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: PresenceTypography.navigationLabel.copyWith(
                color: isSelected
                    ? PresenceColors.primary
                    : PresenceColors.onSurfaceDim,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavDestination {
  final String path;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.path,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
