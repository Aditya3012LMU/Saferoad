import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../components/community_alert_card.dart';
import '../../models/alert_model.dart';
import '../../navigation/app_router.dart';
import '../../state/community_provider.dart';

/// Community alerts screen — feed of nearby safety reports.
class CommunityAlertsScreen extends ConsumerStatefulWidget {
  const CommunityAlertsScreen({super.key});

  @override
  ConsumerState<CommunityAlertsScreen> createState() =>
      _CommunityAlertsScreenState();
}

class _CommunityAlertsScreenState
    extends ConsumerState<CommunityAlertsScreen> {
  @override
  Widget build(BuildContext context) {
    final alerts = ref.watch(filteredAlertsProvider);
    final filter = ref.watch(alertFilterProvider);

    return Scaffold(
      backgroundColor: PresenceColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: PresenceColors.surface,
            surfaceTintColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Community',
                    style: PresenceTypography.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16, top: 8),
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.reportIncident),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Report'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: PresenceTypography.textTheme.labelMedium,
                  ),
                ),
              ),
            ],
          ),

          // ── Stats Banner ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _StatsBanner(alertCount: alerts.length),
            ),
          ),

          // ── Category Filter ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: _CategoryFilterRow(
                selected: filter,
                onSelected: (category) {
                  ref.read(alertFilterProvider.notifier).state = category;
                },
              ),
            ),
          ),

          // ── Alert Feed ─────────────────────────────────────────────────
          if (alerts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: _EmptyState(),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.separated(
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => CommunityAlertCard(
                  alert: alerts[index],
                  index: index,
                  onUpvote: () => ref
                      .read(communityAlertsProvider.notifier)
                      .upvote(alerts[index].id),
                  onTap: () => _showAlertDetail(context, alerts[index]),
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAlertDetail(BuildContext context, AlertModel alert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PresenceColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AlertDetailSheet(alert: alert),
    );
  }
}

// ── Stats Banner ───────────────────────────────────────────────────────────
class _StatsBanner extends StatelessWidget {
  final int alertCount;

  const _StatsBanner({required this.alertCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            PresenceColors.primary.withOpacity(0.1),
            PresenceColors.primaryContainer,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: PresenceColors.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          _StatItem(
            icon: Icons.report_problem_rounded,
            value: '$alertCount',
            label: 'Nearby Alerts',
            color: PresenceColors.alertOrange,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.people_rounded,
            value: '247',
            label: 'Active Users',
            color: PresenceColors.primary,
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.verified_rounded,
            value: '${alertCount > 0 ? (alertCount * 0.6).round() : 0}',
            label: 'Verified',
            color: PresenceColors.safeGreen,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: PresenceTypography.safetyScore(18, color),
          ),
          Text(
            label,
            style: PresenceTypography.textTheme.labelSmall
                ?.copyWith(color: PresenceColors.onSurfaceDim),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: PresenceColors.outlineVariant,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}

// ── Category Filter ────────────────────────────────────────────────────────
class _CategoryFilterRow extends StatelessWidget {
  final AlertCategory? selected;
  final ValueChanged<AlertCategory?> onSelected;

  const _CategoryFilterRow({required this.selected, required this.onSelected});

  static const _filters = [
    (null, Icons.all_inclusive_rounded, 'All'),
    (AlertCategory.harassment, Icons.report_problem_rounded, 'Harassment'),
    (AlertCategory.suspiciousBehavior, Icons.visibility_rounded, 'Suspicious'),
    (AlertCategory.poorLighting, Icons.lightbulb_outline_rounded, 'Lighting'),
    (AlertCategory.unsafeStreet, Icons.warning_amber_rounded, 'Street'),
    (AlertCategory.policeActivity, Icons.local_police_rounded, 'Police'),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: _filters.map((f) {
          final (category, icon, label) = f;
          final isSelected = category == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(label),
              avatar: Icon(icon, size: 14),
              selected: isSelected,
              onSelected: (_) => onSelected(isSelected ? null : category),
              selectedColor: PresenceColors.primaryContainer,
              checkmarkColor: PresenceColors.primary,
              labelStyle: PresenceTypography.textTheme.labelMedium?.copyWith(
                color: isSelected
                    ? PresenceColors.primary
                    : PresenceColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              backgroundColor: PresenceColors.surfaceContainer,
              side: BorderSide(
                color: isSelected
                    ? PresenceColors.primary
                    : PresenceColors.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: PresenceColors.safeGreenSurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline_rounded,
            color: PresenceColors.safeGreen,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'All Clear',
          style: PresenceTypography.textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Text(
          'No alerts in your area matching\nthe selected filter.',
          style: PresenceTypography.textTheme.bodyMedium
              ?.copyWith(color: PresenceColors.onSurfaceDim),
          textAlign: TextAlign.center,
        ),
      ],
    ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9));
  }
}

// ── Alert Detail Bottom Sheet ──────────────────────────────────────────────
class _AlertDetailSheet extends StatelessWidget {
  final AlertModel alert;

  const _AlertDetailSheet({required this.alert});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
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

              // Category badge + severity
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: alert.severitySurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(alert.categoryIcon,
                            size: 14, color: alert.severityColor),
                        const SizedBox(width: 6),
                        Text(
                          alert.categoryLabel,
                          style: PresenceTypography.textTheme.labelMedium
                              ?.copyWith(color: alert.severityColor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (alert.isVerified)
                    Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 14, color: PresenceColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'Verified',
                          style: PresenceTypography.textTheme.labelMedium
                              ?.copyWith(color: PresenceColors.primary),
                        ),
                      ],
                    ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                alert.title,
                style: PresenceTypography.textTheme.headlineSmall,
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Icon(Icons.location_on_rounded,
                      size: 14, color: PresenceColors.onSurfaceDim),
                  const SizedBox(width: 4),
                  Text(
                    alert.locationName,
                    style: PresenceTypography.textTheme.bodySmall
                        ?.copyWith(color: PresenceColors.onSurfaceDim),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· ${alert.timeAgo}',
                    style: PresenceTypography.textTheme.bodySmall
                        ?.copyWith(color: PresenceColors.onSurfaceDim),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                alert.description,
                style: PresenceTypography.textTheme.bodyMedium,
              ),

              const SizedBox(height: 24),

              // Map placeholder
              Container(
                height: 160,
                decoration: BoxDecoration(
                  color: PresenceColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: PresenceColors.outlineVariant),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_rounded,
                          size: 32, color: PresenceColors.onSurfaceDim),
                      const SizedBox(height: 8),
                      Text(
                        'Map view',
                        style: PresenceTypography.textTheme.bodySmall
                            ?.copyWith(color: PresenceColors.onSurfaceDim),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.directions_rounded, size: 18),
                      label: const Text('Avoid This Area'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.share_rounded, size: 18),
                      label: const Text('Share Alert'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
