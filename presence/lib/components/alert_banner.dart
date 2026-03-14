import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../models/alert_model.dart';

/// Animated safety alert banner that slides in from the top.
/// Used for real-time environmental alerts during navigation.
class AlertBanner extends StatelessWidget {
  final String message;
  final AlertSeverity severity;
  final IconData? icon;
  final VoidCallback? onDismiss;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AlertBanner({
    super.key,
    required this.message,
    required this.severity,
    this.icon,
    this.onDismiss,
    this.onAction,
    this.actionLabel,
  });

  Color get _bgColor => switch (severity) {
    AlertSeverity.low => PresenceColors.safeGreenSurface,
    AlertSeverity.medium => PresenceColors.cautionAmberSurface,
    AlertSeverity.high => PresenceColors.alertOrangeSurface,
    AlertSeverity.critical => PresenceColors.dangerRedSurface,
  };

  Color get _fgColor => switch (severity) {
    AlertSeverity.low => PresenceColors.safeGreen,
    AlertSeverity.medium => PresenceColors.cautionAmber,
    AlertSeverity.high => PresenceColors.alertOrange,
    AlertSeverity.critical => PresenceColors.dangerRed,
  };

  IconData get _icon => icon ?? switch (severity) {
    AlertSeverity.low => Icons.check_circle_rounded,
    AlertSeverity.medium => Icons.info_rounded,
    AlertSeverity.high => Icons.warning_amber_rounded,
    AlertSeverity.critical => Icons.report_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _fgColor.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _fgColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _fgColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, color: _fgColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: PresenceTypography.alertText.copyWith(color: _fgColor),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onAction != null && actionLabel != null) ...[
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onAction,
                  style: TextButton.styleFrom(
                    foregroundColor: _fgColor,
                    minimumSize: const Size(48, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: Text(
                    actionLabel!,
                    style: PresenceTypography.textTheme.labelMedium
                        ?.copyWith(color: _fgColor),
                  ),
                ),
              ],
              if (onDismiss != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onDismiss,
                  child: Icon(
                    Icons.close_rounded,
                    color: _fgColor.withOpacity(0.6),
                    size: 18,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: -0.3, end: 0, curve: Curves.easeOutCubic, duration: 350.ms)
        .fadeIn(duration: 300.ms);
  }
}

/// Compact inline alert chip used inside cards
class AlertChip extends StatelessWidget {
  final String label;
  final AlertSeverity severity;
  final IconData? icon;

  const AlertChip({
    super.key,
    required this.label,
    required this.severity,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final banner = AlertBanner(message: '', severity: severity);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: banner._bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: banner._fgColor.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: banner._fgColor, size: 12),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: PresenceTypography.textTheme.labelSmall
                ?.copyWith(color: banner._fgColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
