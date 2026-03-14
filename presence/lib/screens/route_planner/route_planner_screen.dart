import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../components/route_card.dart';
import '../../models/route_model.dart';
import '../../navigation/app_router.dart';
import '../../state/route_provider.dart';

/// Route planning screen — search, compare, and select safe routes.
class RoutePlannerScreen extends ConsumerStatefulWidget {
  const RoutePlannerScreen({super.key});

  @override
  ConsumerState<RoutePlannerScreen> createState() => _RoutePlannerScreenState();
}

class _RoutePlannerScreenState extends ConsumerState<RoutePlannerScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late AnimationController _loadingController;
  bool _isSearching = false;
  bool _showResults = false;
  RouteType _selectedType = RouteType.safest;

  final List<String> _recentDestinations = [
    'Home — 14 Maple Street',
    'Civic Center Station',
    'Mission Dolores Park',
    'California Street & Powell',
  ];

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _loadingController.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.isEmpty) return;
    setState(() => _isSearching = true);

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSearching = false;
        _showResults = true;
      });
    }
  }

  void _selectRoute(RouteModel route) {
    HapticFeedback.mediumImpact();
    ref.read(selectedRouteProvider.notifier).state = route;
  }

  void _startSafeWalk() {
    final selected = ref.read(selectedRouteProvider);
    if (selected == null) return;
    HapticFeedback.heavyImpact();
    context.go(AppRoutes.safeWalk);
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoute = ref.watch(selectedRouteProvider);
    final routes = ref.watch(availableRoutesProvider);

    return Scaffold(
      backgroundColor: PresenceColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: PresenceColors.surface,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.08),
            title: Text(
              'Plan Route',
              style: PresenceTypography.textTheme.titleLarge,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Origin field ─────────────────────────────────────
                  _LocationField(
                    icon: Icons.radio_button_checked_rounded,
                    iconColor: PresenceColors.primary,
                    hintText: 'Current location',
                    readOnly: true,
                    initialValue: 'Market Street & 4th',
                  ).animate().fadeIn(duration: 300.ms),

                  const SizedBox(height: 4),
                  _SwapButton(),
                  const SizedBox(height: 4),

                  // ── Destination field ─────────────────────────────────
                  _LocationField(
                    controller: _searchController,
                    icon: Icons.location_on_rounded,
                    iconColor: PresenceColors.sosRed,
                    hintText: 'Where are you going?',
                    onSubmitted: _search,
                    autofocus: false,
                  ).animate().fadeIn(delay: 100.ms, duration: 300.ms),

                  const SizedBox(height: 20),

                  // ── Route Type Tabs ───────────────────────────────────
                  _RouteTypeTabs(
                    selected: _selectedType,
                    onSelected: (type) => setState(() => _selectedType = type),
                  ).animate().fadeIn(delay: 150.ms, duration: 300.ms),

                  const SizedBox(height: 20),

                  // ── Recent Destinations ───────────────────────────────
                  if (!_showResults && !_isSearching) ...[
                    Text(
                      'Recent destinations',
                      style: PresenceTypography.textTheme.titleSmall?.copyWith(
                        color: PresenceColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._recentDestinations.asMap().entries.map((e) {
                      final idx = e.key;
                      final dest = e.value;
                      return _RecentDestinationTile(
                        label: dest,
                        index: idx,
                        onTap: () {
                          _searchController.text = dest;
                          _search(dest);
                        },
                      );
                    }),
                  ],

                  // ── Loading ───────────────────────────────────────────
                  if (_isSearching)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'Calculating safe routes...',
                              style: PresenceTypography.textTheme.bodyMedium
                                  ?.copyWith(color: PresenceColors.onSurfaceDim),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // ── Route Results ─────────────────────────────────────
                  if (_showResults && !_isSearching) ...[
                    Row(
                      children: [
                        Text(
                          'Available routes',
                          style: PresenceTypography.textTheme.titleSmall
                              ?.copyWith(color: PresenceColors.onSurfaceVariant),
                        ),
                        const Spacer(),
                        Text(
                          '${routes.length} options',
                          style: PresenceTypography.textTheme.bodySmall
                              ?.copyWith(color: PresenceColors.onSurfaceDim),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...routes
                        .where((r) =>
                            _selectedType == RouteType.safest ||
                            r.type == _selectedType)
                        .toList()
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RouteCard(
                              route: e.value,
                              isSelected: selectedRoute?.id == e.value.id,
                              onTap: () => _selectRoute(e.value),
                              index: e.key,
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(height: 100), // Bottom padding for FAB
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Start Safe Walk FAB ───────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: selectedRoute != null
          ? _StartWalkFAB(
              route: selectedRoute,
              onStart: _startSafeWalk,
            )
          : null,
    );
  }
}

// ── Location Field ─────────────────────────────────────────────────────────
class _LocationField extends StatelessWidget {
  final TextEditingController? controller;
  final IconData icon;
  final Color iconColor;
  final String hintText;
  final bool readOnly;
  final String? initialValue;
  final bool autofocus;
  final ValueChanged<String>? onSubmitted;

  const _LocationField({
    this.controller,
    required this.icon,
    required this.iconColor,
    required this.hintText,
    this.readOnly = false,
    this.initialValue,
    this.autofocus = false,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PresenceColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PresenceColors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onSubmitted: onSubmitted,
        textInputAction: TextInputAction.search,
        style: PresenceTypography.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: initialValue ?? hintText,
          prefixIcon: Icon(icon, color: iconColor, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          filled: false,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: PresenceColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: PresenceColors.outlineVariant),
        ),
        child: Icon(
          Icons.swap_vert_rounded,
          size: 18,
          color: PresenceColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ── Route Type Tabs ────────────────────────────────────────────────────────
class _RouteTypeTabs extends StatelessWidget {
  final RouteType selected;
  final ValueChanged<RouteType> onSelected;

  const _RouteTypeTabs({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PresenceColors.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PresenceColors.outlineVariant),
      ),
      child: Row(
        children: RouteType.values.map((type) {
          final isSelected = type == selected;
          final route = MockRoutes.routes.firstWhere(
            (r) => r.type == type,
            orElse: () => MockRoutes.routes[0],
          );
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(type),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                decoration: BoxDecoration(
                  color: isSelected ? PresenceColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                          )
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      route.typeIcon,
                      size: 20,
                      color: isSelected
                          ? PresenceColors.primary
                          : PresenceColors.onSurfaceDim,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type == RouteType.safest
                          ? 'Safest'
                          : type == RouteType.fastest
                              ? 'Fastest'
                              : 'Active',
                      style: PresenceTypography.textTheme.labelSmall?.copyWith(
                        color: isSelected
                            ? PresenceColors.primary
                            : PresenceColors.onSurfaceDim,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Recent Destination Tile ────────────────────────────────────────────────
class _RecentDestinationTile extends StatelessWidget {
  final String label;
  final int index;
  final VoidCallback onTap;

  const _RecentDestinationTile({
    required this.label,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PresenceColors.surfaceContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.history_rounded,
                size: 18,
                color: PresenceColors.onSurfaceDim,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: PresenceTypography.textTheme.bodyMedium,
              ),
            ),
            Icon(
              Icons.north_west_rounded,
              size: 16,
              color: PresenceColors.onSurfaceDim,
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 200 + index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0);
  }
}

// ── Start Walk FAB ─────────────────────────────────────────────────────────
class _StartWalkFAB extends StatelessWidget {
  final RouteModel route;
  final VoidCallback onStart;

  const _StartWalkFAB({required this.route, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        decoration: BoxDecoration(
          color: PresenceColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(route.typeLabel, style: PresenceTypography.textTheme.titleSmall),
                Text(
                  '${route.distanceLabel} · ${route.durationLabel}',
                  style: PresenceTypography.textTheme.bodySmall
                      ?.copyWith(color: PresenceColors.onSurfaceDim),
                ),
              ],
            ),
            const Spacer(),
            FilledButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.directions_walk_rounded, size: 18),
              label: const Text('Start Walk'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.5, end: 0, duration: 350.ms, curve: Curves.easeOutBack);
  }
}
