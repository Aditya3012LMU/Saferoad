import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../models/alert_model.dart';

/// Grid of incident category buttons for the report incident screen.
class IncidentCategorySelector extends StatelessWidget {
  final AlertCategory? selected;
  final ValueChanged<AlertCategory> onSelected;

  const IncidentCategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _categories = [
    (AlertCategory.harassment, Icons.report_problem_rounded, 'Harassment'),
    (AlertCategory.suspiciousBehavior, Icons.visibility_rounded, 'Suspicious'),
    (AlertCategory.poorLighting, Icons.lightbulb_outline_rounded, 'Poor Lighting'),
    (AlertCategory.unsafeStreet, Icons.warning_amber_rounded, 'Unsafe Street'),
    (AlertCategory.crowdedArea, Icons.people_rounded, 'Crowded Area'),
    (AlertCategory.accident, Icons.car_crash_rounded, 'Accident'),
    (AlertCategory.policeActivity, Icons.local_police_rounded, 'Police'),
    (AlertCategory.other, Icons.more_horiz_rounded, 'Other'),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final (category, icon, label) = _categories[index];
        final isSelected = selected == category;

        return GestureDetector(
          onTap: () => onSelected(category),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? PresenceColors.primaryContainer
                  : PresenceColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? PresenceColors.primary
                    : PresenceColors.outlineVariant,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: isSelected
                      ? PresenceColors.primary
                      : PresenceColors.onSurfaceVariant,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: PresenceTypography.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? PresenceColors.primary
                        : PresenceColors.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        )
            .animate(delay: Duration(milliseconds: index * 40))
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack);
      },
    );
  }
}

/// Severity selector chips
class SeveritySelectorRow extends StatelessWidget {
  final AlertSeverity selected;
  final ValueChanged<AlertSeverity> onSelected;

  const SeveritySelectorRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AlertSeverity.values.map((severity) {
        final isSelected = selected == severity;
        final dummy = AlertModel(
          id: '',
          category: AlertCategory.other,
          severity: severity,
          title: '',
          description: '',
          latitude: 0,
          longitude: 0,
          locationName: '',
          timestamp: DateTime.now(),
        );
        return Expanded(
          child: GestureDetector(
            onTap: () => onSelected(severity),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? dummy.severitySurface : PresenceColors.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? dummy.severityColor : PresenceColors.outlineVariant,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: dummy.severityColor,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dummy.severityLabel,
                    style: PresenceTypography.textTheme.labelSmall?.copyWith(
                      color: isSelected
                          ? dummy.severityColor
                          : PresenceColors.onSurfaceDim,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
