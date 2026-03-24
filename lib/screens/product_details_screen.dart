import 'package:flutter/material.dart';

import '../services/cart_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_image.dart';
import '../widgets/cart_action_button.dart';
import '../widgets/primary_button.dart';
import 'mock_data.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({
    super.key,
    required this.item,
    required this.onCartTap,
  });

  final MenuProduct item;
  final VoidCallback onCartTap;

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late ProductVariant _selectedVariant;
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedVariant = widget.item.defaultVariant;
  }

  @override
  Widget build(BuildContext context) {
    final total = _selectedVariant.price * quantity;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 320,
                  pinned: true,
                  leading: Padding(
                    padding: const EdgeInsets.all(8),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_rounded),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CartActionButton(
                        onTap: widget.onCartTap,
                        backgroundColor: AppColors.white.withValues(alpha: 0.9),
                        size: 46,
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        Hero(
                          tag: 'food-${widget.item.id}',
                          child: AppImage(
                            source: _selectedVariant.imageAsset,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0x22000000), Color(0xCC2A160D)],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.peachSurface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                widget.item.category,
                                style: const TextStyle(
                                  color: AppColors.brownAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star_rounded,
                              color: AppColors.yellowAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.item.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '\u20B1${_selectedVariant.price.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.primaryOrange),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.item.name,
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.item.description,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (widget.item.hasMultipleVariants) ...[
                          const SizedBox(height: 28),
                          Text(
                            'Choose size',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 360;
                              final width = narrow
                                  ? constraints.maxWidth
                                  : (constraints.maxWidth - 12) / 2;

                              return Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: widget.item.variants.map((variant) {
                                  return _VariantCard(
                                    variant: variant,
                                    selected: variant.id == _selectedVariant.id,
                                    width: width,
                                    onTap: () => setState(
                                      () => _selectedVariant = variant,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                        const SizedBox(height: 24),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.cardSurface,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.local_fire_department_rounded,
                                color: AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'Official Lamyani POS item with refreshed local image assets and ready-to-order sizing.',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(color: AppColors.brownAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final narrow = constraints.maxWidth < 340;

                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _InfoPill(
                                    icon: Icons.timer_outlined,
                                    label: widget.item.prepTime,
                                    width: narrow
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 20) / 3,
                                  ),
                                  _InfoPill(
                                    icon: Icons.delivery_dining_rounded,
                                    label: 'Fast delivery',
                                    width: narrow
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 20) / 3,
                                  ),
                                  _InfoPill(
                                    icon: Icons.thumb_up_alt_outlined,
                                    label: widget.item.hasMultipleVariants
                                        ? '${widget.item.variants.length} sizes'
                                        : 'Top pick',
                                    width: narrow
                                        ? constraints.maxWidth
                                        : (constraints.maxWidth - 20) / 3,
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          'Quantity',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(22),
                            boxShadow: AppTheme.softShadow,
                          ),
                          child: Row(
                            children: [
                              _QuantityButton(
                                icon: Icons.remove_rounded,
                                onTap: quantity > 1
                                    ? () => setState(() => quantity--)
                                    : null,
                              ),
                              Expanded(
                                child: Text(
                                  '$quantity',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ),
                              _QuantityButton(
                                icon: Icons.add_rounded,
                                onTap: () => setState(() => quantity++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 360;

                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '\u20B1${total.toStringAsFixed(0)}',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(color: AppColors.primaryOrange),
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: 'Add to Cart',
                          icon: Icons.shopping_bag_rounded,
                          onPressed: _addToCart,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\u20B1${total.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: AppColors.primaryOrange),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: PrimaryButton(
                          label: 'Add to Cart',
                          icon: Icons.shopping_bag_rounded,
                          onPressed: _addToCart,
                        ),
                      ),
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

  void _addToCart() {
    final cart = CartScope.of(context);
    cart.addSelection(
      CartSelection(product: widget.item, variant: _selectedVariant),
      quantity: quantity,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            '${widget.item.name}${widget.item.hasMultipleVariants ? ' (${_selectedVariant.label})' : ''} added to cart',
          ),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: widget.onCartTap,
          ),
        ),
      );

    setState(() => quantity = 1);
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({
    required this.variant,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final ProductVariant variant;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primaryOrange : AppColors.white,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected
                  ? AppColors.primaryOrange
                  : AppColors.peachSurface.withValues(alpha: 0.9),
            ),
            boxShadow: selected ? null : AppTheme.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (variant.badge != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppColors.white.withValues(alpha: 0.18)
                        : AppColors.peachSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    variant.badge!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: selected
                          ? AppColors.white
                          : AppColors.primaryOrange,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                variant.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: selected ? AppColors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '\u20B1${variant.price.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: selected ? AppColors.white : AppColors.primaryOrange,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: onTap == null ? AppColors.peachSurface : AppColors.primaryOrange,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: onTap == null ? AppColors.mutedText : AppColors.white,
          ),
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.width,
  });

  final IconData icon;
  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardSurface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryOrange),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: AppColors.brownAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
