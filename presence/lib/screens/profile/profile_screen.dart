import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../models/safety_data.dart';
import '../../state/user_provider.dart';

/// Profile & Safety Settings screen
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _shareLocation = true;
  bool _autoSOS = false;
  bool _vibrationAlerts = true;
  bool _nightModeAlerts = true;
  bool _communityAlerts = true;

  @override
  Widget build(BuildContext context) {
    final contacts = ref.watch(emergencyContactsProvider);

    return Scaffold(
      backgroundColor: PresenceColors.background,
      body: CustomScrollView(
        slivers: [
          // ── App Bar / Hero ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _ProfileHero(),
          ),

          // ── Emergency Contacts ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _SectionCard(
                title: 'Emergency Contacts',
                icon: Icons.contact_phone_rounded,
                iconColor: PresenceColors.sosRed,
                action: TextButton(
                  onPressed: () => _showAddContactSheet(context),
                  child: const Text('Add'),
                ),
                child: Column(
                  children: [
                    ...contacts.asMap().entries.map((e) => _EmergencyContactTile(
                      contact: e.value,
                      index: e.key,
                      onRemove: () {
                        ref
                            .read(emergencyContactsProvider.notifier)
                            .removeContact(e.value.name);
                      },
                      onSetPrimary: () {
                        ref
                            .read(emergencyContactsProvider.notifier)
                            .setPrimary(e.value.name);
                      },
                    )),
                    if (contacts.isEmpty)
                      _EmptyContactsPlaceholder(
                          onAdd: () => _showAddContactSheet(context)),
                  ],
                ),
              ),
            ),
          ),

          // ── Safety Preferences ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SectionCard(
                title: 'Safety Preferences',
                icon: Icons.tune_rounded,
                iconColor: PresenceColors.primary,
                child: Column(
                  children: [
                    _ToggleTile(
                      icon: Icons.share_location_rounded,
                      title: 'Share my location',
                      subtitle: 'Share live location with contacts during walk',
                      value: _shareLocation,
                      onChanged: (v) => setState(() => _shareLocation = v),
                    ),
                    _ToggleTile(
                      icon: Icons.sos_rounded,
                      title: 'Auto SOS after 1 min',
                      subtitle: 'Trigger SOS if walk stops unexpectedly',
                      value: _autoSOS,
                      onChanged: (v) => setState(() => _autoSOS = v),
                    ),
                    _ToggleTile(
                      icon: Icons.vibration_rounded,
                      title: 'Vibration alerts',
                      subtitle: 'Haptic feedback for safety warnings',
                      value: _vibrationAlerts,
                      onChanged: (v) => setState(() => _vibrationAlerts = v),
                    ),
                    _ToggleTile(
                      icon: Icons.nightlight_round,
                      title: 'Enhanced night alerts',
                      subtitle: 'More sensitive alerts between 9PM – 6AM',
                      value: _nightModeAlerts,
                      onChanged: (v) => setState(() => _nightModeAlerts = v),
                    ),
                    _ToggleTile(
                      icon: Icons.people_rounded,
                      title: 'Community alerts',
                      subtitle: 'Receive nearby incident notifications',
                      value: _communityAlerts,
                      onChanged: (v) => setState(() => _communityAlerts = v),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Privacy ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SectionCard(
                title: 'Privacy & Data',
                icon: Icons.lock_rounded,
                iconColor: PresenceColors.tertiary,
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.history_rounded,
                      title: 'Walk history',
                      subtitle: '12 walks in the last 30 days',
                      onTap: () {},
                    ),
                    _ActionTile(
                      icon: Icons.delete_outline_rounded,
                      title: 'Clear location data',
                      subtitle: 'Remove all stored location history',
                      onTap: () => _showClearDataDialog(context),
                      destructive: true,
                    ),
                    _ActionTile(
                      icon: Icons.policy_rounded,
                      title: 'Privacy policy',
                      subtitle: 'How we use your data',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Notifications ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SectionCard(
                title: 'Notifications',
                icon: Icons.notifications_rounded,
                iconColor: PresenceColors.cautionAmber,
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.notifications_active_rounded,
                      title: 'Push notifications',
                      subtitle: 'Currently enabled',
                      onTap: () {},
                      trailingLabel: 'On',
                    ),
                    _ActionTile(
                      icon: Icons.schedule_rounded,
                      title: 'Quiet hours',
                      subtitle: '11:00 PM – 7:00 AM',
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── About ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SectionCard(
                title: 'About',
                icon: Icons.info_outline_rounded,
                iconColor: PresenceColors.secondary,
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.star_outline_rounded,
                      title: 'Rate Presence',
                      subtitle: 'Help us improve the app',
                      onTap: () {},
                    ),
                    _ActionTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help & Support',
                      subtitle: 'FAQs and contact',
                      onTap: () {},
                    ),
                    _ActionTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App version',
                      subtitle: 'Presence 1.0.0 (build 1)',
                      onTap: null,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  void _showAddContactSheet(BuildContext context) {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: PresenceColors.surface,
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
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Name',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: relationCtrl,
              decoration: const InputDecoration(
                labelText: 'Relationship',
                prefixIcon: Icon(Icons.group_outlined),
                hintText: 'e.g. Family, Friend, Partner',
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                  ref.read(emergencyContactsProvider.notifier).addContact(
                    EmergencyContact(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      relation: relationCtrl.text.isEmpty
                          ? 'Contact'
                          : relationCtrl.text,
                    ),
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Save Contact'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Clear Location Data?'),
        content: const Text(
            'This will permanently delete all your stored location history and walk records.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style:
                FilledButton.styleFrom(backgroundColor: PresenceColors.dangerRed),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Clear Data'),
          ),
        ],
      ),
    );
  }
}

// ── Profile Hero ───────────────────────────────────────────────────────────
class _ProfileHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, MediaQuery.of(context).padding.top + 16, 24, 24),
      decoration: const BoxDecoration(
        gradient: PresenceColors.heroGradient,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Profile',
                      style: PresenceTypography.textTheme.labelMedium?.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'Sarah M.',
                      style:
                          PresenceTypography.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Text(
                      'S',
                      style: PresenceTypography.safetyScore(24, Colors.white),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: PresenceColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: PresenceColors.primary, width: 2),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          size: 10, color: PresenceColors.primary),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Walk stats
          Row(
            children: [
              _HeroStat(value: '47', label: 'Walks'),
              _HeroStatDivider(),
              _HeroStat(value: '112km', label: 'Distance'),
              _HeroStatDivider(),
              _HeroStat(value: '3', label: 'Reports'),
              _HeroStatDivider(),
              _HeroStat(value: '92', label: 'Avg Score'),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

class _HeroStat extends StatelessWidget {
  final String value;
  final String label;

  const _HeroStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: PresenceTypography.safetyScore(20, Colors.white),
          ),
          Text(
            label,
            style: PresenceTypography.textTheme.labelSmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroStatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: Colors.white.withOpacity(0.25),
      margin: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

// ── Section Card ───────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: PresenceColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: PresenceColors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Icon(icon, size: 18, color: iconColor),
                const SizedBox(width: 8),
                Text(title, style: PresenceTypography.textTheme.titleSmall),
                if (action != null) ...[
                  const Spacer(),
                  action!,
                ],
              ],
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          child,
          const SizedBox(height: 8),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }
}

// ── Emergency Contact Tile ─────────────────────────────────────────────────
class _EmergencyContactTile extends StatelessWidget {
  final EmergencyContact contact;
  final int index;
  final VoidCallback onRemove;
  final VoidCallback onSetPrimary;

  const _EmergencyContactTile({
    required this.contact,
    required this.index,
    required this.onRemove,
    required this.onSetPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: PresenceColors.primaryContainer,
            child: Text(
              contact.name[0],
              style: PresenceTypography.textTheme.titleSmall
                  ?.copyWith(color: PresenceColors.primary),
            ),
          ),
          if (contact.isPrimary)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: PresenceColors.sosRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: PresenceColors.surface, width: 1.5),
                ),
                child: const Icon(Icons.star_rounded,
                    size: 8, color: Colors.white),
              ),
            ),
        ],
      ),
      title: Text(
        contact.name,
        style: PresenceTypography.textTheme.titleSmall,
      ),
      subtitle: Text(
        '${contact.relation} · ${contact.phone}',
        style: PresenceTypography.textTheme.bodySmall
            ?.copyWith(color: PresenceColors.onSurfaceDim),
      ),
      trailing: PopupMenuButton<String>(
        icon: Icon(Icons.more_vert_rounded,
            color: PresenceColors.onSurfaceDim, size: 20),
        itemBuilder: (_) => [
          if (!contact.isPrimary)
            const PopupMenuItem(
              value: 'primary',
              child: Text('Set as primary'),
            ),
          const PopupMenuItem(
            value: 'call',
            child: Text('Call'),
          ),
          const PopupMenuItem(
            value: 'remove',
            child: Text('Remove',
                style: TextStyle(color: PresenceColors.dangerRed)),
          ),
        ],
        onSelected: (action) {
          if (action == 'remove') onRemove();
          if (action == 'primary') onSetPrimary();
        },
      ),
    );
  }
}

class _EmptyContactsPlaceholder extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyContactsPlaceholder({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(Icons.person_add_rounded,
              size: 32, color: PresenceColors.onSurfaceDim),
          const SizedBox(height: 8),
          Text(
            'No emergency contacts added.',
            style: PresenceTypography.textTheme.bodyMedium
                ?.copyWith(color: PresenceColors.onSurfaceDim),
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 16),
            label: const Text('Add a contact'),
          ),
        ],
      ),
    );
  }
}

// ── Toggle Tile ────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon,
          color: value ? PresenceColors.primary : PresenceColors.onSurfaceDim,
          size: 22),
      title: Text(title, style: PresenceTypography.textTheme.bodyMedium),
      subtitle: Text(
        subtitle,
        style: PresenceTypography.textTheme.bodySmall
            ?.copyWith(color: PresenceColors.onSurfaceDim),
      ),
      value: value,
      onChanged: (v) {
        HapticFeedback.lightImpact();
        onChanged(v);
      },
      activeColor: PresenceColors.primary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}

// ── Action Tile ────────────────────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;
  final String? trailingLabel;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.destructive = false,
    this.trailingLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: destructive
            ? PresenceColors.dangerRed
            : PresenceColors.onSurfaceVariant,
        size: 22,
      ),
      title: Text(
        title,
        style: PresenceTypography.textTheme.bodyMedium?.copyWith(
          color: destructive ? PresenceColors.dangerRed : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: PresenceTypography.textTheme.bodySmall
            ?.copyWith(color: PresenceColors.onSurfaceDim),
      ),
      trailing: trailingLabel != null
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: PresenceColors.safeGreenSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                trailingLabel!,
                style: PresenceTypography.textTheme.labelSmall
                    ?.copyWith(color: PresenceColors.safeGreen),
              ),
            )
          : onTap != null
              ? Icon(Icons.chevron_right_rounded,
                  color: PresenceColors.onSurfaceDim)
              : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
    );
  }
}
