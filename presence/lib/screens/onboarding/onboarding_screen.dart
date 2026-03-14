import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../navigation/app_router.dart';
import '../../state/user_provider.dart';

/// Full onboarding flow: Welcome → Features → Permissions → Emergency Contact
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      illustration: Icons.shield_rounded,
      illustrationColor: PresenceColors.primary,
      title: 'Walk with\nConfidence',
      body:
          'Presence gives you real-time safety awareness so you can focus on your journey, not your anxiety.',
      ctaLabel: 'Get Started',
      isFirst: true,
    ),
    _OnboardingPage(
      illustration: Icons.map_rounded,
      illustrationColor: PresenceColors.mapPoliceStation,
      title: 'Smart Safety\nRoutes',
      body:
          'Get directions that prioritise well-lit streets, high foot traffic, and proximity to police stations.',
      ctaLabel: 'Next',
    ),
    _OnboardingPage(
      illustration: Icons.people_rounded,
      illustrationColor: PresenceColors.mapCrowdDensity,
      title: 'Community\nAlerts',
      body:
          'See real-time reports from other walkers — harassment, poor lighting, and suspicious activity.',
      ctaLabel: 'Next',
    ),
    _OnboardingPage(
      illustration: Icons.sos_rounded,
      illustrationColor: PresenceColors.sosRed,
      title: 'One-Tap\nSOS',
      body:
          'Instantly alert your emergency contacts and share your live location with a single press.',
      ctaLabel: 'Next',
    ),
    _OnboardingPage(
      illustration: Icons.location_on_rounded,
      illustrationColor: PresenceColors.primary,
      title: 'Allow Location\nAccess',
      body:
          'Presence needs your location to show nearby safety data and guide you on safe routes.',
      ctaLabel: 'Allow Location',
      isPermission: true,
    ),
    _OnboardingPage(
      illustration: Icons.contact_phone_rounded,
      illustrationColor: PresenceColors.tertiary,
      title: 'Add Emergency\nContact',
      body:
          'Add a trusted person who will receive your SOS alerts and live location in emergencies.',
      ctaLabel: 'Add Contact',
      isContact: true,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _completeOnboarding() async {
    await setOnboardingComplete();
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            _currentPage == 0 ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: PresenceColors.background,
        body: Stack(
          children: [
            // Background gradient for first page
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: _currentPage == 0
                    ? PresenceColors.heroGradient
                    : null,
                color: _currentPage == 0 ? null : PresenceColors.background,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  // Skip button (not on first/last pages)
                  if (_currentPage > 0 && _currentPage < _pages.length - 1)
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextButton(
                          onPressed: _completeOnboarding,
                          child: Text(
                            'Skip',
                            style: PresenceTypography.textTheme.labelLarge
                                ?.copyWith(
                              color: PresenceColors.onSurfaceDim,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 56),

                  // Page content
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (i) => setState(() => _currentPage = i),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        return _OnboardingPageView(
                          page: _pages[index],
                          isFirstPage: _currentPage == 0,
                        );
                      },
                    ),
                  ),

                  // Dots indicator
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: i == _currentPage ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: i == _currentPage
                                ? PresenceColors.primary
                                : PresenceColors.outlineVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // CTA Button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                    child: _OnboardingCTA(
                      label: _pages[_currentPage].ctaLabel,
                      isLast: _currentPage == _pages.length - 1,
                      isPermission: _pages[_currentPage].isPermission,
                      isContact: _pages[_currentPage].isContact,
                      onPressed: _nextPage,
                      onComplete: _completeOnboarding,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageView extends StatelessWidget {
  final _OnboardingPage page;
  final bool isFirstPage;

  const _OnboardingPageView({required this.page, required this.isFirstPage});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: page.illustrationColor.withOpacity(
                  isFirstPage && page.isFirst ? 0.2 : 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.illustration,
              size: 68,
              color: isFirstPage && page.isFirst
                  ? Colors.white
                  : page.illustrationColor,
            ),
          )
              .animate()
              .scale(
                  begin: const Offset(0.7, 0.7),
                  curve: Curves.elasticOut,
                  duration: 700.ms)
              .fadeIn(duration: 400.ms),

          const SizedBox(height: 40),

          // Title
          Text(
            page.title,
            style: PresenceTypography.textTheme.headlineLarge?.copyWith(
              color: isFirstPage && page.isFirst
                  ? Colors.white
                  : PresenceColors.onBackground,
              height: 1.15,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),

          const SizedBox(height: 20),

          // Body
          Text(
            page.body,
            style: PresenceTypography.textTheme.bodyLarge?.copyWith(
              color: isFirstPage && page.isFirst
                  ? Colors.white.withOpacity(0.85)
                  : PresenceColors.onSurfaceVariant,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 500.ms)
              .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic),
        ],
      ),
    );
  }
}

class _OnboardingCTA extends StatefulWidget {
  final String label;
  final bool isLast;
  final bool isPermission;
  final bool isContact;
  final VoidCallback onPressed;
  final VoidCallback onComplete;

  const _OnboardingCTA({
    required this.label,
    required this.isLast,
    required this.isPermission,
    required this.isContact,
    required this.onPressed,
    required this.onComplete,
  });

  @override
  State<_OnboardingCTA> createState() => _OnboardingCTAState();
}

class _OnboardingCTAState extends State<_OnboardingCTA> {
  bool _permissionGranted = false;
  bool _contactAdded = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handlePermission() async {
    setState(() => _permissionGranted = true);
    widget.onPressed();
  }

  void _handleAddContact() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Emergency Contact',
                style: PresenceTypography.textTheme.titleLarge),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Contact name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() => _contactAdded = true);
                Navigator.pop(ctx);
                widget.onComplete();
              },
              child: const Text('Save Contact'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isPermission) {
      return Column(
        children: [
          FilledButton.icon(
            onPressed: _handlePermission,
            icon: const Icon(Icons.location_on_rounded),
            label: const Text('Allow Location Access'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onPressed,
            child: Text(
              'Not now',
              style: PresenceTypography.textTheme.labelLarge
                  ?.copyWith(color: PresenceColors.onSurfaceDim),
            ),
          ),
        ],
      );
    }

    if (widget.isContact) {
      return Column(
        children: [
          FilledButton.icon(
            onPressed: _handleAddContact,
            icon: const Icon(Icons.contact_phone_rounded),
            label: const Text('Add Emergency Contact'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: widget.onComplete,
            child: Text(
              'Skip for now',
              style: PresenceTypography.textTheme.labelLarge
                  ?.copyWith(color: PresenceColors.onSurfaceDim),
            ),
          ),
        ],
      );
    }

    return FilledButton(
      onPressed: widget.onPressed,
      child: Text(widget.label),
    );
  }
}

class _OnboardingPage {
  final IconData illustration;
  final Color illustrationColor;
  final String title;
  final String body;
  final String ctaLabel;
  final bool isFirst;
  final bool isPermission;
  final bool isContact;

  const _OnboardingPage({
    required this.illustration,
    required this.illustrationColor,
    required this.title,
    required this.body,
    required this.ctaLabel,
    this.isFirst = false,
    this.isPermission = false,
    this.isContact = false,
  });
}
