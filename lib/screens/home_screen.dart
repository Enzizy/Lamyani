import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/catalog_service.dart';
import '../theme/app_theme.dart';
import '../widgets/brand_logo.dart';
import '../widgets/cart_action_button.dart';
import '../widgets/category_chip.dart';
import '../widgets/food_card.dart';
import '../widgets/primary_button.dart';
import '../widgets/promo_banner.dart';
import '../widgets/section_title.dart';
import 'mock_data.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onProductTap,
    required this.onCartTap,
    required this.onViewMenuTap,
  });

  final ValueChanged<MenuProduct> onProductTap;
  final VoidCallback onCartTap;
  final VoidCallback onViewMenuTap;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final displayName = user?.displayName?.trim();
    final greetingName = displayName != null && displayName.isNotEmpty
        ? displayName
        : 'User';

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryOrange, Color(0xFFF0852F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hi, $greetingName',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: AppColors.white),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_rounded,
                                    color: AppColors.yellowAccent,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Delivery to Cebu City',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: const Color(0xFFFDEADD),
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const BrandLogo(size: 48),
                            const SizedBox(width: 10),
                            CartActionButton(
                              onTap: onCartTap,
                              backgroundColor: AppColors.white.withValues(
                                alpha: 0.18,
                              ),
                              iconColor: AppColors.white,
                              size: 52,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _HeaderPill(
                          icon: Icons.bolt_rounded,
                          label: 'Quick pickup',
                        ),
                        _HeaderPill(
                          icon: Icons.workspace_premium_outlined,
                          label: 'Rewards ready',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: AppColors.white.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: AppColors.white.withValues(alpha: 0.18),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _QuickOrderLead(onOrderNowTap: onViewMenuTap),
                              const SizedBox(height: 18),
                              Row(
                                children: const [
                                  Expanded(
                                    child: _HeroStat(
                                      icon: Icons.star_rounded,
                                      label: '4.9 rating',
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: _HeroStat(
                                      icon: Icons.local_shipping_outlined,
                                      label: 'Hot delivery',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
            sliver: SliverToBoxAdapter(
              child: StreamBuilder<List<MenuProduct>>(
                stream: CatalogService.streamProducts(),
                builder: (context, productSnapshot) {
                  final products = productSnapshot.data ?? MockData.products;
                  final featuredItems =
                      CatalogService.featuredProductsFor(products);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                const SectionTitle(
                  title: 'Promos for you',
                  subtitle: 'Best bites and bundle deals this week',
                ),
                const SizedBox(height: 18),
                StreamBuilder<List<PromoItem>>(
                  stream: CatalogService.streamPromos(),
                  builder: (context, promoSnapshot) {
                    final promos = promoSnapshot.data ?? MockData.promos;

                    return SizedBox(
                      height: 188,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(right: 20),
                        itemCount: promos.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 16),
                        itemBuilder: (context, index) {
                          return PromoBanner(promo: promos[index]);
                        },
                      ),
                    );
                  },
                ),
                const SizedBox(height: 34),
                const SectionTitle(
                  title: 'Categories',
                  subtitle: 'Choose your favorite roasted classics',
                ),
                const SizedBox(height: 18),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(right: 20),
                    itemCount: MockData.quickCategories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      return CategoryChip(
                        label: MockData.quickCategories[index],
                        selected: index == 0,
                        icon: [
                          Icons.local_fire_department_rounded,
                          Icons.ramen_dining_rounded,
                          Icons.outdoor_grill_rounded,
                          Icons.rice_bowl_rounded,
                        ][index],
                        onTap: onViewMenuTap,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 34),
                SectionTitle(
                  title: 'Featured Menu',
                  subtitle: 'Best sellers roasted fresh today',
                  actionLabel: 'View All',
                  onActionTap: onViewMenuTap,
                ),
                const SizedBox(height: 18),
                _FeaturedMenuCarousel(
                  items: featuredItems,
                  onProductTap: onProductTap,
                ),
                const SizedBox(height: 18),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedMenuCarousel extends StatefulWidget {
  const _FeaturedMenuCarousel({
    required this.items,
    required this.onProductTap,
  });

  final List<MenuProduct> items;
  final ValueChanged<MenuProduct> onProductTap;

  @override
  State<_FeaturedMenuCarousel> createState() => _FeaturedMenuCarouselState();
}

class _FeaturedMenuCarouselState extends State<_FeaturedMenuCarousel> {
  late final PageController _controller;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.84);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = math.min(248.0, constraints.maxWidth * 0.82);
        final cardHeight = cardWidth + 88;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: cardHeight,
              child: PageView.builder(
                controller: _controller,
                padEnds: true,
                itemCount: widget.items.length,
                onPageChanged: (index) {
                  if (!mounted) return;
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  final item = widget.items[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FoodCard(
                        item: item,
                        width: cardWidth,
                        height: cardHeight,
                        onTap: () => widget.onProductTap(item),
                        onAddTap: () => widget.onProductTap(item),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.items.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 18 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.primaryOrange
                        : AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16, color: AppColors.yellowAccent),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.14),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.yellowAccent),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickOrderLead extends StatelessWidget {
  const _QuickOrderLead({required this.onOrderNowTap});

  final VoidCallback onOrderNowTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.yellowAccent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Text(
            'Quick Order',
            style: TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Satisfy your lechon cravings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.white,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fresh roast, rich drippings, and warm rice delivered fast.',
          style: Theme.of(
          context,
          ).textTheme.bodyMedium?.copyWith(color: const Color(0xFFF9E8DC)),
        ),
        const SizedBox(height: 18),
        PrimaryButton(
          label: 'Order Now',
          expanded: false,
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.primaryOrange,
          icon: Icons.arrow_forward_rounded,
          onPressed: onOrderNowTap,
        ),
      ],
    );
  }
}
