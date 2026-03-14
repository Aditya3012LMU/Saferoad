import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../utils/safety_score.dart';

/// Displays the current area safety score with animated progress arc.
class SafetyScoreCard extends StatelessWidget {
  final int score;
  final String areaName;
  final String statusMessage;
  final List<String> features;
  final VoidCallback? onTap;
  final bool compact;

  const SafetyScoreCard({
    super.key,
    required this.score,
    required this.areaName,
    required this.statusMessage,
    this.features = const [],
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = SafetyScoreUtils.colorForScore(score);
    final surface = SafetyScoreUtils.surfaceForScore(score);
    final label = SafetyScoreUtils.labelForScore(score);

    if (compact) return _buildCompact(context, color, label);
    return _buildFull(context, color, surface, label);
  }

  Widget _buildCompact(BuildContext context, Color color, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(SafetyScoreUtils.iconForScore(score), color: color, size: 16),
            const SizedBox(width: 6),
            Text(
              '$label · $score',
              style: PresenceTypography.alertText.copyWith(color: color),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildFull(
    BuildContext context,
    Color color,
    Color surface,
    String label,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.25), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Score Arc Widget
                  _SafetyArc(score: score, color: color),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: PresenceTypography.textTheme.titleMedium
                              ?.copyWith(color: color, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          areaName,
                          style: PresenceTypography.textTheme.bodyMedium
                              ?.copyWith(color: PresenceColors.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          statusMessage,
                          style: PresenceTypography.textTheme.bodySmall
                              ?.copyWith(color: PresenceColors.onSurfaceVariant),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (features.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: features
                      .map((f) => _FeatureChip(label: f, color: color))
                      .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic);
  }
}

class _SafetyArc extends StatelessWidget {
  final int score;
  final Color color;

  const _SafetyArc({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: score / 100),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color),
                strokeCap: StrokeCap.round,
              );
            },
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$score',
                style: PresenceTypography.safetyScore(20, color),
              ),
              Text(
                '/100',
                style: PresenceTypography.textTheme.labelSmall
                    ?.copyWith(color: color.withOpacity(0.7), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;
  final Color color;

  const _FeatureChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: PresenceTypography.textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
