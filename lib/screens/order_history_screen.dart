import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/order_service.dart';
import '../theme/app_motion.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import 'login_screen.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Order History')),
      body: SafeArea(
        child: user == null
            ? const _OrderHistoryGuestState()
            : StreamBuilder<List<AppOrder>>(
                stream: OrderService.streamCurrentUserOrders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return _OrderHistoryMessageState(
                      icon: Icons.cloud_off_rounded,
                      title: 'Unable to load orders',
                      description:
                          'Check your connection and Firestore setup, then try again.',
                    );
                  }

                  final orders = snapshot.data ?? const [];
                  if (orders.isEmpty) {
                    return const _OrderHistoryMessageState(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      description:
                          'Once you place your first Lamyani order, it will show up here with its branch, status, and total.',
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 16),
                    itemBuilder: (context, index) => _OrderCard(order: orders[index]),
                  );
                },
              ),
      ),
    );
  }
}

class _OrderHistoryGuestState extends StatelessWidget {
  const _OrderHistoryGuestState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: AppColors.peachSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.lock_person_rounded,
                  size: 36,
                  color: AppColors.primaryOrange,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Sign in to see your orders',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Order tracking and history are tied to your Lamyani account so your past meals stay synced across devices.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Log In',
                icon: Icons.login_rounded,
                onPressed: () {
                  Navigator.of(context).push(AppMotion.route(const LoginScreen()));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderHistoryMessageState extends StatelessWidget {
  const _OrderHistoryMessageState({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: AppTheme.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.cardSurface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(icon, size: 34, color: AppColors.primaryOrange),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.mutedText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final AppOrder order;

  @override
  Widget build(BuildContext context) {
    final placedLabel = _formatPlacedAt(order.placedAt);
    final status = _statusMeta(order.status);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.itemsSummary,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${order.branchName} • $placedLabel',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: status.background,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  status.label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: status.foreground,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _OrderMetaPill(
                icon: Icons.shopping_bag_outlined,
                label: '${order.totalItems} item${order.totalItems == 1 ? '' : 's'}',
              ),
              _OrderMetaPill(
                icon: Icons.receipt_long_outlined,
                label: order.id.substring(0, 6).toUpperCase(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity}x ${item.productName}${item.variantLabel == 'Regular' ? '' : ' (${item.variantLabel})'}',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '\u20B1${item.lineTotal.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.primaryOrange,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 28),
          Row(
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                '\u20B1${order.total.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatPlacedAt(DateTime? placedAt) {
    if (placedAt == null) {
      return 'Just now';
    }

    final difference = DateTime.now().difference(placedAt);
    if (difference.inMinutes < 1) {
      return 'Just now';
    }
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hr ago';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    }
    return '${placedAt.month}/${placedAt.day}/${placedAt.year}';
  }

  static ({String label, Color background, Color foreground}) _statusMeta(
    String status,
  ) {
    switch (status) {
      case 'ready':
        return (
          label: 'Ready',
          background: const Color(0xFFE7F8ED),
          foreground: AppColors.success,
        );
      case 'delivered':
        return (
          label: 'Delivered',
          background: const Color(0xFFEAF1FF),
          foreground: const Color(0xFF2E6DEB),
        );
      case 'cancelled':
        return (
          label: 'Cancelled',
          background: const Color(0xFFFFEEE9),
          foreground: AppColors.danger,
        );
      default:
        return (
          label: 'Preparing',
          background: AppColors.peachSurface,
          foreground: AppColors.primaryOrange,
        );
    }
  }
}

class _OrderMetaPill extends StatelessWidget {
  const _OrderMetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
