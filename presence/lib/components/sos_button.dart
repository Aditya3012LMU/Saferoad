import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/colors.dart';
import '../core/theme/typography.dart';
import '../state/user_provider.dart';

/// SOS Floating Action Button — always visible, pulsing animation.
/// Long-press activates SOS. Short tap shows confirmation dialog.
class SOSFloatingButton extends ConsumerStatefulWidget {
  final bool expanded;

  const SOSFloatingButton({super.key, this.expanded = false});

  @override
  ConsumerState<SOSFloatingButton> createState() => _SOSFloatingButtonState();
}

class _SOSFloatingButtonState extends ConsumerState<SOSFloatingButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isLongPressActive = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTap() {
    HapticFeedback.mediumImpact();
    _showSOSConfirmationDialog();
  }

  void _onLongPressStart(LongPressStartDetails details) {
    HapticFeedback.heavyImpact();
    setState(() => _isLongPressActive = true);
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    setState(() => _isLongPressActive = false);
    _activateSOS();
  }

  void _activateSOS() {
    HapticFeedback.vibrate();
    ref.read(sosActivatedProvider.notifier).state = true;
    _showSOSActivatedDialog();
  }

  void _showSOSConfirmationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: PresenceColors.surface,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: PresenceColors.dangerRedSurface,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sos_rounded, color: PresenceColors.sosRed, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Send SOS Alert',
              style: PresenceTypography.textTheme.titleMedium?.copyWith(
                color: PresenceColors.sosRed,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will immediately alert your emergency contacts and share your live location.',
              style: PresenceTypography.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            _SOSContactRow(initial: 'M', name: 'Mom', phone: '+1 (555) 234-5678'),
            _SOSContactRow(initial: 'A', name: 'Alex Chen', phone: '+1 (555) 876-5432'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: PresenceTypography.textTheme.labelLarge
                  ?.copyWith(color: PresenceColors.onSurfaceDim),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: PresenceColors.sosRed,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              _activateSOS();
            },
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  void _showSOSActivatedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SOSActivatedOverlay(
        onCancel: () {
          ref.read(sosActivatedProvider.notifier).state = false;
          Navigator.pop(ctx);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isActivated = ref.watch(sosActivatedProvider);

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = isActivated
            ? 1.0 + _pulseController.value * 0.15
            : 1.0 + _pulseController.value * 0.06;

        return Transform.scale(
          scale: _isLongPressActive ? 1.12 : pulse,
          child: GestureDetector(
            onTap: _onTap,
            onLongPressStart: _onLongPressStart,
            onLongPressEnd: _onLongPressEnd,
            child: Container(
              width: widget.expanded ? 120 : 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: isActivated
                    ? const LinearGradient(
                        colors: [PresenceColors.sosRedDark, PresenceColors.sosRed],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : PresenceColors.sosGradient,
                borderRadius: BorderRadius.circular(widget.expanded ? 32 : 32),
                boxShadow: [
                  BoxShadow(
                    color: PresenceColors.sosRed.withOpacity(
                      isActivated ? 0.55 : 0.35 + _pulseController.value * 0.15,
                    ),
                    blurRadius: isActivated ? 24 : 16,
                    spreadRadius: isActivated ? 4 : 0,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isActivated ? Icons.sos_rounded : Icons.sos_rounded,
                    color: Colors.white,
                    size: 28,
                    semanticLabel: 'SOS Emergency',
                  ),
                  if (widget.expanded) ...[
                    const SizedBox(width: 8),
                    Text(
                      'SOS',
                      style: PresenceTypography.textTheme.titleSmall
                          ?.copyWith(color: Colors.white, letterSpacing: 1.2),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SOSContactRow extends StatelessWidget {
  final String initial;
  final String name;
  final String phone;

  const _SOSContactRow({
    required this.initial,
    required this.name,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: PresenceColors.primaryContainer,
            child: Text(
              initial,
              style: PresenceTypography.textTheme.labelMedium
                  ?.copyWith(color: PresenceColors.primary),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: PresenceTypography.textTheme.labelMedium),
              Text(
                phone,
                style: PresenceTypography.textTheme.bodySmall
                    ?.copyWith(color: PresenceColors.onSurfaceDim),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SOSActivatedOverlay extends StatefulWidget {
  final VoidCallback onCancel;

  const _SOSActivatedOverlay({required this.onCancel});

  @override
  State<_SOSActivatedOverlay> createState() => _SOSActivatedOverlayState();
}

class _SOSActivatedOverlayState extends State<_SOSActivatedOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _countdown = 5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat(reverse: true);
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 5; i > 0; i--) {
      if (!mounted) return;
      setState(() => _countdown = i);
      await Future.delayed(const Duration(seconds: 1));
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: PresenceColors.sosRed,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1 + _controller.value * 0.15),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: const Icon(Icons.sos_rounded, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'SOS ACTIVATED',
              style: PresenceTypography.textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Alerting emergency contacts...',
              style: PresenceTypography.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Sharing live location',
              style: PresenceTypography.textTheme.bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 28),
            Text(
              'Auto-dismissing in $_countdown...',
              style: PresenceTypography.textTheme.bodySmall
                  ?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white, width: 1.5),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: widget.onCancel,
              child: const Text('Cancel SOS'),
            ),
          ],
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0.8, 0.8), curve: Curves.elasticOut)
        .fadeIn(duration: 300.ms);
  }
}
