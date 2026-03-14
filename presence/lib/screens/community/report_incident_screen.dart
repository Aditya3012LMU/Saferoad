import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../components/incident_category_selector.dart';
import '../../models/alert_model.dart';
import '../../navigation/app_router.dart';
import '../../state/community_provider.dart';

/// Report incident screen — category, severity, description, location.
class ReportIncidentScreen extends ConsumerWidget {
  const ReportIncidentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(incidentReportProvider);
    final notifier = ref.read(incidentReportProvider.notifier);

    if (state.isSubmitted) {
      return _SubmittedScreen(onDone: () => context.go(AppRoutes.community));
    }

    return Scaffold(
      backgroundColor: PresenceColors.background,
      appBar: AppBar(
        title: Text('Report Incident',
            style: PresenceTypography.textTheme.titleLarge),
        backgroundColor: PresenceColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            notifier.reset();
            context.go(AppRoutes.community);
          },
        ),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            color: PresenceColors.outlineVariant,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Location Row ────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.location_on_rounded,
              title: 'Location',
            ),
            const SizedBox(height: 12),
            _LocationPickerCard(),
            const SizedBox(height: 28),

            // ── Incident Category ───────────────────────────────────────
            _SectionHeader(
              icon: Icons.category_rounded,
              title: 'What happened?',
            ),
            const SizedBox(height: 12),
            IncidentCategorySelector(
              selected: state.selectedCategory,
              onSelected: notifier.selectCategory,
            ),
            const SizedBox(height: 28),

            // ── Severity ────────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.warning_amber_rounded,
              title: 'How severe?',
            ),
            const SizedBox(height: 12),
            SeveritySelectorRow(
              selected: state.severity,
              onSelected: notifier.setSeverity,
            ),
            const SizedBox(height: 28),

            // ── Description ─────────────────────────────────────────────
            _SectionHeader(
              icon: Icons.description_rounded,
              title: 'Describe what you saw',
            ),
            const SizedBox(height: 12),
            TextField(
              onChanged: notifier.setDescription,
              maxLines: 4,
              maxLength: 280,
              decoration: InputDecoration(
                hintText:
                    'Optional: Add details to help others understand the situation...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: PresenceColors.outlineVariant),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: PresenceColors.outlineVariant),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                      color: PresenceColors.primary, width: 2),
                ),
                filled: true,
                fillColor: PresenceColors.surface,
                contentPadding: const EdgeInsets.all(16),
              ),
              style: PresenceTypography.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),

            // ── Anonymous notice ────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: PresenceColors.primaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.privacy_tip_outlined,
                      size: 18, color: PresenceColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Your report is anonymous. Only your general location is shared.',
                      style: PresenceTypography.textTheme.bodySmall?.copyWith(
                        color: PresenceColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Submit Button ───────────────────────────────────────────
            FilledButton(
              onPressed: state.selectedCategory == null || state.isSubmitting
                  ? null
                  : () => notifier.submit(),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Submit Report'),
            ),

            if (state.selectedCategory == null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Please select an incident category to continue.',
                  style: PresenceTypography.textTheme.bodySmall
                      ?.copyWith(color: PresenceColors.onSurfaceDim),
                  textAlign: TextAlign.center,
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;

  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: PresenceColors.primary),
        const SizedBox(width: 8),
        Text(title, style: PresenceTypography.textTheme.titleSmall),
      ],
    );
  }
}

class _LocationPickerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: PresenceColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: PresenceColors.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: PresenceColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.my_location_rounded,
                color: PresenceColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current location',
                  style: PresenceTypography.textTheme.labelMedium
                      ?.copyWith(color: PresenceColors.onSurfaceDim),
                ),
                Text(
                  'Market Street & 4th, San Francisco',
                  style: PresenceTypography.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Icon(Icons.edit_location_alt_rounded,
              color: PresenceColors.onSurfaceDim, size: 20),
        ],
      ),
    );
  }
}

/// Success screen shown after submission
class _SubmittedScreen extends StatelessWidget {
  final VoidCallback onDone;

  const _SubmittedScreen({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PresenceColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: PresenceColors.safeGreenSurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: PresenceColors.safeGreen,
                  size: 60,
                ),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.5, 0.5),
                      curve: Curves.elasticOut,
                      duration: 700.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 32),

              Text(
                'Report Submitted',
                style: PresenceTypography.textTheme.headlineMedium,
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              Text(
                'Thank you for helping keep the community safe. Your anonymous report has been shared with nearby users.',
                style: PresenceTypography.textTheme.bodyLarge?.copyWith(
                  color: PresenceColors.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 48),

              FilledButton.icon(
                onPressed: onDone,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Back to Community'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}
