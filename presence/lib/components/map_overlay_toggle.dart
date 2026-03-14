import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../state/user_provider.dart';

/// Bottom sheet panel for toggling map overlay layers
class MapOverlayToggleSheet extends ConsumerWidget {
  const MapOverlayToggleSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlays = ref.watch(mapOverlayProvider);
    final notifier = ref.read(mapOverlayProvider.notifier);

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 32,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: PresenceColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text(
            'Map Layers',
            style: PresenceTypography.textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Customize what you see on the map',
            style: PresenceTypography.textTheme.bodySmall
                ?.copyWith(color: PresenceColors.onSurfaceDim),
          ),
          const SizedBox(height: 20),
          _OverlayToggleTile(
            icon: Icons.shield_rounded,
            label: 'Safe Routes',
            description: 'Show highlighted safe walking paths',
            color: PresenceColors.safeGreen,
            value: overlays.showSafeRoutes,
            onChanged: (_) => notifier.toggle(safeRoutes: true),
          ),
          _OverlayToggleTile(
            icon: Icons.people_rounded,
            label: 'Crowd Density',
            description: 'Visualize pedestrian activity levels',
            color: PresenceColors.primary,
            value: overlays.showCrowdDensity,
            onChanged: (_) => notifier.toggle(crowdDensity: true),
          ),
          _OverlayToggleTile(
            icon: Icons.lightbulb_rounded,
            label: 'Street Lighting',
            description: 'Show well-lit and dark areas',
            color: PresenceColors.cautionAmber,
            value: overlays.showLighting,
            onChanged: (_) => notifier.toggle(lighting: true),
          ),
          _OverlayToggleTile(
            icon: Icons.local_police_rounded,
            label: 'Police Stations',
            description: 'Nearby law enforcement locations',
            color: PresenceColors.mapPoliceStation,
            value: overlays.showPoliceStations,
            onChanged: (_) => notifier.toggle(policeStations: true),
          ),
          _OverlayToggleTile(
            icon: Icons.report_problem_rounded,
            label: 'Community Alerts',
            description: 'User-reported safety incidents',
            color: PresenceColors.alertOrange,
            value: overlays.showAlerts,
            onChanged: (_) => notifier.toggle(alerts: true),
          ),
        ],
      ),
    );
  }
}

class _OverlayToggleTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _OverlayToggleTile({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: value ? color.withOpacity(0.12) : PresenceColors.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: value ? color : PresenceColors.onSurfaceDim,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: PresenceTypography.textTheme.titleSmall?.copyWith(
                        color: value
                            ? PresenceColors.onSurface
                            : PresenceColors.onSurfaceDim,
                      ),
                    ),
                    Text(
                      description,
                      style: PresenceTypography.textTheme.bodySmall
                          ?.copyWith(color: PresenceColors.onSurfaceDim),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact floating toggle buttons row for the map
class MapLayerToggleRow extends ConsumerWidget {
  const MapLayerToggleRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlays = ref.watch(mapOverlayProvider);
    final notifier = ref.read(mapOverlayProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _LayerToggleChip(
            icon: Icons.shield_rounded,
            label: 'Safe Routes',
            color: PresenceColors.safeGreen,
            active: overlays.showSafeRoutes,
            onTap: () => notifier.toggle(safeRoutes: true),
          ),
          const SizedBox(width: 8),
          _LayerToggleChip(
            icon: Icons.people_rounded,
            label: 'Crowd',
            color: PresenceColors.primary,
            active: overlays.showCrowdDensity,
            onTap: () => notifier.toggle(crowdDensity: true),
          ),
          const SizedBox(width: 8),
          _LayerToggleChip(
            icon: Icons.lightbulb_rounded,
            label: 'Lighting',
            color: PresenceColors.cautionAmber,
            active: overlays.showLighting,
            onTap: () => notifier.toggle(lighting: true),
          ),
          const SizedBox(width: 8),
          _LayerToggleChip(
            icon: Icons.local_police_rounded,
            label: 'Police',
            color: PresenceColors.mapPoliceStation,
            active: overlays.showPoliceStations,
            onTap: () => notifier.toggle(policeStations: true),
          ),
          const SizedBox(width: 8),
          _LayerToggleChip(
            icon: Icons.report_problem_rounded,
            label: 'Alerts',
            color: PresenceColors.alertOrange,
            active: overlays.showAlerts,
            onTap: () => notifier.toggle(alerts: true),
          ),
        ],
      ),
    );
  }
}

class _LayerToggleChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  const _LayerToggleChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? color.withOpacity(0.15) : PresenceColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: active ? color : PresenceColors.outlineVariant,
            width: active ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: active ? color : PresenceColors.onSurfaceDim),
            const SizedBox(width: 6),
            Text(
              label,
              style: PresenceTypography.textTheme.labelSmall?.copyWith(
                color: active ? color : PresenceColors.onSurfaceDim,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
