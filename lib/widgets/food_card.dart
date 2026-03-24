import 'package:flutter/material.dart';

import '../screens/mock_data.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onAddTap,
    this.compact = false,
    this.width,
    this.height,
  });

  final MenuProduct item;
  final VoidCallback onTap;
  final VoidCallback onAddTap;
  final bool compact;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final priceLabel = item.hasMultipleVariants
        ? 'From \u20B1${item.startingPrice.toStringAsFixed(0)}'
        : '\u20B1${item.defaultVariant.price.toStringAsFixed(0)}';
    final tileRadius = compact ? 20.0 : 24.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tileRadius),
        child: Ink(
          width: compact ? null : width ?? 232,
          height: compact ? null : height,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(tileRadius),
            border: Border.all(
              color: AppColors.peachSurface.withValues(alpha: 0.92),
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tileRadius),
            child: compact
                ? _CompactFoodCardBody(
                    item: item,
                    priceLabel: priceLabel,
                    onAddTap: onAddTap,
                  )
                : _FeaturedFoodCardBody(item: item),
          ),
        ),
      ),
    );
  }
}

class _FeaturedFoodCardBody extends StatelessWidget {
  const _FeaturedFoodCardBody({required this.item});

  final MenuProduct item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Hero(
          tag: 'food-${item.id}',
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              color: const Color(0xFFFFF8F2),
              child: AppImage(
                source: item.imageAsset,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 88,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        height: 1.12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompactFoodCardBody extends StatelessWidget {
  const _CompactFoodCardBody({
    required this.item,
    required this.priceLabel,
    required this.onAddTap,
  });

  final MenuProduct item;
  final String priceLabel;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            Hero(
              tag: 'food-${item.id}',
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: const Color(0xFFFFF8F2),
                  child: AppImage(
                    source: item.imageAsset,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
              top: 10,
              child: _MetricPill(
                icon: Icons.star_rounded,
                label: item.rating.toStringAsFixed(1),
                compact: true,
              ),
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.prepTime,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.brownAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 126,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 42,
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        height: 1.12,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 22,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: item.hasMultipleVariants
                        ? _OptionsPill(label: '${item.variants.length} sizes')
                        : const SizedBox.shrink(),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _AddButton(onTap: onAddTap, compact: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 5 : 6,
      ),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: compact ? 13 : 14,
            color: AppColors.yellowAccent,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.darkText,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionsPill extends StatelessWidget {
  const _OptionsPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.brownAccent,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.onTap, this.compact = false});

  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryOrange,
      borderRadius: BorderRadius.circular(compact ? 16 : 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 16 : 14),
        child: Padding(
          padding: EdgeInsets.all(compact ? 10 : 10),
          child: Icon(
            Icons.add_rounded,
            size: compact ? 22 : 20,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}
