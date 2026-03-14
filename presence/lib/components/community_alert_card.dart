import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../models/alert_model.dart';

/// Card for displaying a single community safety alert in the feed.
class CommunityAlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onUpvote;
  final VoidCallback? onTap;
  final int index;

  const CommunityAlertCard({
    super.key,
    required this.alert,
    this.onUpvote,
    this.onTap,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: PresenceColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: PresenceColors.outlineVariant),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: alert.severitySurface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      alert.categoryIcon,
                      color: alert.severityColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                alert.title,
                                style: PresenceTypography.textTheme.titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w700),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Severity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: alert.severitySurface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                alert.severityLabel,
                                style: PresenceTypography.textTheme.labelSmall
                                    ?.copyWith(
                                  color: alert.severityColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 12,
                              color: PresenceColors.onSurfaceDim,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                alert.locationName,
                                style: PresenceTypography.textTheme.bodySmall
                                    ?.copyWith(color: PresenceColors.onSurfaceDim),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '· ${alert.timeAgo}',
                              style: PresenceTypography.textTheme.bodySmall
                                  ?.copyWith(color: PresenceColors.onSurfaceDim),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Description
              if (alert.description.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  alert.description,
                  style: PresenceTypography.textTheme.bodyMedium
                      ?.copyWith(color: PresenceColors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Footer row
              Row(
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: PresenceColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      alert.categoryLabel,
                      style: PresenceTypography.textTheme.labelSmall
                          ?.copyWith(color: PresenceColors.onSurfaceVariant),
                    ),
                  ),
                  if (alert.isVerified) ...[
                    const SizedBox(width: 6),
                    Row(
                      children: [
                        Icon(Icons.verified_rounded,
                            size: 12, color: PresenceColors.primary),
                        const SizedBox(width: 3),
                        Text(
                          'Verified',
                          style: PresenceTypography.textTheme.labelSmall
                              ?.copyWith(color: PresenceColors.primary),
                        ),
                      ],
                    ),
                  ],
                  const Spacer(),
                  // Reporter avatar
                  if (alert.reporterAvatarInitial != null)
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: PresenceColors.primaryContainer,
                      child: Text(
                        alert.reporterAvatarInitial!,
                        style: PresenceTypography.textTheme.labelSmall
                            ?.copyWith(
                          color: PresenceColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  // Upvote button
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onUpvote?.call();
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.thumb_up_outlined,
                          size: 14,
                          color: PresenceColors.onSurfaceDim,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${alert.upvoteCount}',
                          style: PresenceTypography.textTheme.labelSmall
                              ?.copyWith(color: PresenceColors.onSurfaceDim),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 60))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}
