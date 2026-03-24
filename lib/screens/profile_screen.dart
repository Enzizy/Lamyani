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

                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryOrange, AppColors.brownAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: AppTheme.softShadow,
                  ),
                  child: Column(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final narrow = constraints.maxWidth < 330;

                          if (narrow) {
                            return Column(
                              children: [
                                const CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppColors.white,
                                  child: Icon(
                                    Icons.person_rounded,
                                    size: 38,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: AppColors.white),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  email,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: const Color(0xFFFDE9DA),
                                      ),
                                ),
                                const SizedBox(height: 12),
                                const BrandLogo(size: 54),
                              ],
                            );
                          }

                          return Row(
                            children: [
                              const CircleAvatar(
                                radius: 36,
                                backgroundColor: AppColors.white,
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 38,
                                  color: AppColors.primaryOrange,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(color: AppColors.white),
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
                                  ],
                                ),
                              ),
                              const BrandLogo(size: 54),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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
                                    const Expanded(
                                      child: _ProfileStat(
                                        label: 'Tier',
                                        value: 'Starter',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                const _ProfileStat(
                                  label: 'Status',
                                  value: 'Active',
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
                              const Expanded(
                                child: _ProfileStat(
                                  label: 'Tier',
                                  value: 'Starter',
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: _ProfileStat(
                                  label: 'Status',
                                  value: 'Active',
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 26),
            const SectionTitle(
              title: 'Account',
              subtitle: 'Manage your orders, rewards, and preferences',
            ),
            const SizedBox(height: 18),
            _ProfileMenuTile(
              icon: Icons.receipt_long_outlined,
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
            _ProfileMenuTile(
              icon: Icons.location_on_outlined,
              title: 'Addresses',
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

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.white.withValues(alpha: 0.86),
            ),
          ),
        ],
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
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
