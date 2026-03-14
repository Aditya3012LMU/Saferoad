import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../models/route_model.dart';
import '../utils/safety_score.dart';

/// Displays a single route option with safety score, duration, and highlights.
class RouteCard extends StatelessWidget {
  final RouteModel route;
  final bool isSelected;
  final VoidCallback? onTap;
  final int index;

  const RouteCard({
    super.key,
    required this.route,
    this.isSelected = false,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    final safetyColor = route.safetyColor;
    final safetySurface = route.safetySurface;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected ? safetySurface : PresenceColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? safetyColor.withOpacity(0.5)
                : PresenceColors.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: safetyColor.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: safetyColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(route.typeIcon, color: safetyColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              route.typeLabel,
                              style: PresenceTypography.textTheme.titleSmall,
                            ),
                            if (route.isRecommended) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: PresenceColors.primary,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Recommended',
                                  style: PresenceTypography.textTheme.labelSmall
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          route.title,
                          style: PresenceTypography.textTheme.bodySmall
                              ?.copyWith(color: PresenceColors.onSurfaceDim),
                        ),
                      ],
                    ),
                  ),
                  // Safety score badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: safetyColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${route.safetyScore}',
                          style: PresenceTypography.safetyScore(15, safetyColor),
                        ),
                        Text(
                          route.safetyLabel,
                          style: PresenceTypography.textTheme.labelSmall?.copyWith(
                            color: safetyColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Stats row
              Row(
                children: [
                  _StatPill(
                    icon: Icons.directions_walk_rounded,
                    label: route.distanceLabel,
                    color: PresenceColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon: Icons.access_time_rounded,
                    label: route.durationLabel,
                    color: PresenceColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon: Icons.lightbulb_rounded,
                    label: '${route.lightingScore.round()}%',
                    color: PresenceColors.cautionAmber,
                  ),
                  const SizedBox(width: 8),
                  _StatPill(
                    icon: Icons.people_rounded,
                    label: '${route.crowdScore.round()}%',
                    color: PresenceColors.primary,
                  ),
                ],
              ),

              // Highlights
              if (route.highlights.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: route.highlights
                      .take(3)
                      .map((h) => _HighlightTag(label: h))
                      .toList(),
                ),
              ],

              // Warnings
              if (route.warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...route.warnings.take(2).map(
                  (w) => Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          size: 14,
                          color: PresenceColors.cautionAmber,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            w,
                            style: PresenceTypography.textTheme.labelSmall
                                ?.copyWith(color: PresenceColors.cautionAmber),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 80))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: PresenceColors.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: PresenceTypography.textTheme.labelSmall?.copyWith(
              color: PresenceColors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightTag extends StatelessWidget {
  final String label;

  const _HighlightTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: PresenceColors.safeGreenSurface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded,
              size: 10, color: PresenceColors.safeGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: PresenceTypography.textTheme.labelSmall?.copyWith(
              color: PresenceColors.safeGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
