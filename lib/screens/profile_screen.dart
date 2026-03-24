import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/section_title.dart';
import 'login_screen.dart';
import 'order_history_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    await AuthService.signOut();
    if (!context.mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      AppMotion.route(const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _showInfoSheet(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required List<String> bullets,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 5,
                  decoration: BoxDecoration(
                    color: AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(icon, color: AppColors.primaryOrange),
                ),
                const SizedBox(height: 16),
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 18),
                ...bullets.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Icon(
                            Icons.circle,
                            size: 8,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Profile',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rewards, orders, and account preferences in one place',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: AppTheme.softShadow,
                    border: Border.all(
                      color: AppColors.peachSurface.withValues(alpha: 0.78),
                    ),
                  ),
                  child: const Icon(
                    Icons.person_outline_rounded,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreamBuilder(
              stream: AuthService.profileStream(),
              builder: (context, snapshot) {
                final data = snapshot.data?.data();
                final firstName = (data?['firstName'] as String?)?.trim();
                final lastName = (data?['lastName'] as String?)?.trim();
                final fullName = [
                  if (firstName != null && firstName.isNotEmpty) firstName,
                  if (lastName != null && lastName.isNotEmpty) lastName,
                ].join(' ');
                final name = fullName.isNotEmpty
                    ? fullName
                    : user?.displayName?.trim().isNotEmpty == true
                    ? user!.displayName!.trim()
                    : 'Guest User';
                final email = user?.email ?? 'Guest session';
                final points = data?['points']?.toString() ?? '0';
                final memberTier = _tierForPoints(int.tryParse(points) ?? 0);
                final verifiedLabel = user?.emailVerified == true
                    ? 'Verified email'
                    : 'Email pending';
                final providerLabel = user?.providerData.isNotEmpty == true
                    ? user!.providerData.first.providerId.replaceAll('.com', '')
                    : 'firebase';

                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: AppTheme.softShadow,
                        border: Border.all(
                          color: AppColors.peachSurface.withValues(alpha: 0.78),
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.primaryOrange,
                                  AppColors.brownAccent,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final narrow = constraints.maxWidth < 340;

                                if (narrow) {
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const CircleAvatar(
                                            radius: 30,
                                            backgroundColor: AppColors.white,
                                            child: Icon(
                                              Icons.person_rounded,
                                              size: 30,
                                              color: AppColors.primaryOrange,
                                            ),
                                          ),
                                          const Spacer(),
                                          const BrandLogo(size: 44),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        name,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                              color: AppColors.white,
                                              fontSize: 30,
                                            ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        email,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              color: const Color(0xFFFDE9DA),
                                            ),
                                      ),
                                      const SizedBox(height: 14),
                                      _ProfileMemberChip(
                                        label: verifiedLabel,
                                      ),
                                    ],
                                  );
                                }

                                return Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 30,
                                      backgroundColor: AppColors.white,
                                      child: Icon(
                                        Icons.person_rounded,
                                        size: 30,
                                        color: AppColors.primaryOrange,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            name,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color: AppColors.white,
                                                  fontSize: 30,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            email,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: const Color(
                                                    0xFFFDE9DA,
                                                  ),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                          _ProfileMemberChip(
                                            label: verifiedLabel,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const BrandLogo(size: 48),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 330;

                              if (narrow) {
                                return Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _ProfileStat(
                                            label: 'Points',
                                            value: points,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _ProfileStat(
                                            label: 'Tier',
                                            value: memberTier,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    _ProfileStat(
                                      label: 'Status',
                                      value: verifiedLabel,
                                    ),
                                  ],
                                );
                              }

                              return Row(
                                children: [
                                  Expanded(
                                    child: _ProfileStat(
                                      label: 'Points',
                                      value: points,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ProfileStat(
                                      label: 'Tier',
                                      value: memberTier,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _ProfileStat(
                                      label: 'Status',
                                      value: verifiedLabel,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.cardSurface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppColors.peachSurface.withValues(
                                  alpha: 0.75,
                                ),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Account health',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _AccountHealthTile(
                                        icon: Icons.verified_user_outlined,
                                        label: verifiedLabel,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _AccountHealthTile(
                                        icon: Icons.lock_outline_rounded,
                                        label: 'Secure sign-in',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _AccountHealthTile(
                                        icon: Icons.hub_outlined,
                                        label: providerLabel,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _AccountHealthTile(
                                        icon: Icons.local_fire_department_outlined,
                                        label: '$memberTier tier',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final shortcuts = [
                          _ProfileShortcut(
                            icon: Icons.receipt_long_outlined,
                            label: 'Orders',
                            onTap: () => Navigator.of(context).push(
                              AppMotion.route(const OrderHistoryScreen()),
                            ),
                          ),
                          _ProfileShortcut(
                            icon: Icons.card_giftcard_rounded,
                            label: 'Rewards',
                            onTap: () => _showInfoSheet(
                              context,
                              icon: Icons.card_giftcard_rounded,
                              title: 'Rewards',
                              description:
                                  'Your points system is active in profile data, and this screen is ready for richer rewards content next.',
                              bullets: const [
                                'Current tier is shown on the profile header',
                                'Points will map cleanly to reward milestones',
                                'Promo perks and redemption UI can plug in later',
                              ],
                            ),
                          ),
                          _ProfileShortcut(
                            icon: Icons.location_on_outlined,
                            label: 'Addresses',
                            onTap: () => _showInfoSheet(
                              context,
                              icon: Icons.location_on_outlined,
                              title: 'Saved Addresses',
                              description:
                                  'Address management will connect naturally with the branch and location flow already in the app.',
                              bullets: const [
                                'Support home, work, and pinned delivery locations',
                                'Use your nearest branch to guide service availability',
                                'Keep the current Stores experience as the fallback',
                              ],
                            ),
                          ),
                        ];

                        final narrow = constraints.maxWidth < 360;
                        if (narrow) {
                          return Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(child: shortcuts[0]),
                                  const SizedBox(width: 12),
                                  Expanded(child: shortcuts[1]),
                                ],
                              ),
                              const SizedBox(height: 12),
                              shortcuts[2],
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(child: shortcuts[0]),
                            const SizedBox(width: 12),
                            Expanded(child: shortcuts[1]),
                            const SizedBox(width: 12),
                            Expanded(child: shortcuts[2]),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),
            const SectionTitle(
              title: 'Activity',
              subtitle: 'Track orders, rewards, and account actions',
            ),
            const SizedBox(height: 18),
            _ProfileMenuTile(
              icon: Icons.receipt_long_rounded,
              title: 'Order History',
              onTap: () => Navigator.of(
                context,
              ).push(AppMotion.route(const OrderHistoryScreen())),
            ),
            _ProfileMenuTile(
              icon: Icons.card_giftcard_rounded,
              title: 'Rewards',
              onTap: () => _showInfoSheet(
                context,
                icon: Icons.card_giftcard_rounded,
                title: 'Rewards',
                description:
                    'Your points system is active in profile data, and this screen is ready for richer rewards content next.',
                bullets: const [
                  'Current tier is shown on the profile header',
                  'Points will map cleanly to reward milestones',
                  'Promo perks and redemption UI can plug in later',
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SectionTitle(
              title: 'Preferences',
              subtitle: 'Manage your app settings and profile preferences',
            ),
            const SizedBox(height: 18),
            _ProfileMenuTile(
              icon: Icons.location_on_outlined,
              title: 'Saved Addresses',
              onTap: () => _showInfoSheet(
                context,
                icon: Icons.location_on_outlined,
                title: 'Saved Addresses',
                description:
                    'Address management will connect naturally with the branch and location flow already in the app.',
                bullets: const [
                  'Support home, work, and pinned delivery locations',
                  'Use your nearest branch to guide service availability',
                  'Keep the current Stores experience as the fallback',
                ],
              ),
            ),
            _ProfileMenuTile(
              icon: Icons.settings_outlined,
              title: 'Settings',
              onTap: () => _showInfoSheet(
                context,
                icon: Icons.settings_outlined,
                title: 'Settings',
                description:
                    'This settings panel is ready for notification, privacy, and account controls as the app backend grows.',
                bullets: const [
                  'Notification preferences',
                  'Privacy and account controls',
                  'Location and promo communication settings',
                ],
              ),
            ),
            _ProfileMenuTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              danger: true,
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}

String _tierForPoints(int points) {
  if (points >= 250) {
    return 'Gold';
  }
  if (points >= 100) {
    return 'Plus';
  }
  return 'Starter';
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.peachSurface.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.darkText),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.mutedText,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMemberChip extends StatelessWidget {
  const _ProfileMemberChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _AccountHealthTile extends StatelessWidget {
  const _AccountHealthTile({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.peachSurface.withValues(alpha: 0.8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.peachSurface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: AppColors.primaryOrange),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.darkText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileShortcut extends StatelessWidget {
  const _ProfileShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: AppTheme.softShadow,
            border: Border.all(
              color: AppColors.peachSurface.withValues(alpha: 0.78),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.peachSurface,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: AppColors.primaryOrange, size: 20),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: AppColors.peachSurface.withValues(alpha: 0.78),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: danger ? const Color(0x14C44D34) : AppColors.peachSurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            icon,
            color: danger ? AppColors.danger : AppColors.primaryOrange,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: danger ? AppColors.danger : AppColors.darkText,
          ),
        ),
        trailing: Icon(
          danger ? Icons.logout_rounded : Icons.chevron_right_rounded,
          color: danger ? AppColors.danger : AppColors.darkText,
        ),
      ),
    );
  }
}
