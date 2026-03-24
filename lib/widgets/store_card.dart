import 'package:flutter/material.dart';

import '../screens/mock_data.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';
import 'primary_button.dart';

class StoreCard extends StatelessWidget {
  const StoreCard({
    super.key,
    required this.store,
    required this.distanceLabel,
    required this.onDirectionsTap,
    required this.onOrderTap,
    this.onMapTap,
  });

  final StoreItem store;
  final String distanceLabel;
  final VoidCallback onDirectionsTap;
  final VoidCallback onOrderTap;
  final VoidCallback? onMapTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: AppImage(
              source: store.imageUrl,
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 340;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            store.name,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: store.isOpen
                                ? const Color(0x142E8B57)
                                : const Color(0x14C44D34),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            store.statusLabel,
                            style: TextStyle(
                              color: store.isOpen
                                  ? AppColors.success
                                  : AppColors.danger,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _StoreMetaChip(
                          icon: Icons.location_city_outlined,
                          label: store.region,
                        ),
                        _StoreMetaChip(
                          icon: Icons.schedule_outlined,
                          label: store.hours,
                        ),
                        if (store.productCount > 0)
                          _StoreMetaChip(
                            icon: Icons.restaurant_menu_rounded,
                            label: '${store.productCount} items',
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(
                            Icons.place_outlined,
                            size: 18,
                            color: AppColors.primaryOrange,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            store.address,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      distanceLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.brownAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardSurface,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store notes',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.primaryOrange,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manager: ${store.manager}',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.darkText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Next promo: ${store.nextPromo}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    if (onMapTap != null) ...[
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: onMapTap,
                        borderRadius: BorderRadius.circular(999),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 2,
                            vertical: 2,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.map_outlined,
                                size: 18,
                                color: AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'View on map',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    if (narrow) ...[
                      PrimaryButton(
                        label: 'Directions',
                        expanded: true,
                        backgroundColor: AppColors.peachSurface,
                        foregroundColor: AppColors.brownAccent,
                        onPressed: onDirectionsTap,
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Order Now',
                        expanded: true,
                        onPressed: onOrderTap,
                      ),
                    ] else
                      Row(
                        children: [
                          Expanded(
                            child: PrimaryButton(
                              label: 'Directions',
                              expanded: true,
                              backgroundColor: AppColors.peachSurface,
                              foregroundColor: AppColors.brownAccent,
                              onPressed: onDirectionsTap,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PrimaryButton(
                              label: 'Order Now',
                              expanded: true,
                              onPressed: onOrderTap,
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _StoreMetaChip extends StatelessWidget {
  const _StoreMetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primaryOrange),
          const SizedBox(width: 6),
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
