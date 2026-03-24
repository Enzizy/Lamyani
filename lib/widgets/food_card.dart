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
  });

  final MenuProduct item;
  final VoidCallback onTap;
  final VoidCallback onAddTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final priceLabel = item.hasMultipleVariants
        ? 'From \u20B1${item.startingPrice.toStringAsFixed(0)}'
        : '\u20B1${item.defaultVariant.price.toStringAsFixed(0)}';
    final tileRadius = compact ? 20.0 : 24.0;
    final imageFit = compact ? BoxFit.cover : BoxFit.cover;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(tileRadius),
        child: Ink(
          width: compact ? null : 210,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(tileRadius),
            border: Border.all(
              color: AppColors.peachSurface.withValues(alpha: 0.9),
            ),
            boxShadow: AppTheme.softShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(tileRadius),
            child: compact
                ? _CompactFoodCardBody(
                    item: item,
                    imageFit: imageFit,
                    priceLabel: priceLabel,
                    onAddTap: onAddTap,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(tileRadius),
                        ),
                        child: Hero(
                          tag: 'food-${item.id}',
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: Container(
                              color: const Color(0xFFFFF8F2),
                              child: AppImage(
                                source: item.imageAsset,
                                width: double.infinity,
                                fit: imageFit,
                                alignment: Alignment.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.copyWith(height: 1.3),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.peachSurface,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 14,
                                        color: AppColors.yellowAccent,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.rating.toStringAsFixed(1),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkText,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Spacer(),
                                Flexible(
                                  child: Text(
                                    item.prepTime,
                                    textAlign: TextAlign.right,
                                    style: Theme.of(context).textTheme.bodyMedium
                                        ?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                            if (item.hasMultipleVariants) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.cardSurface,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  '${item.variants.length} size options',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: AppColors.brownAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    priceLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.titleMedium
                                        ?.copyWith(
                                          color: AppColors.primaryOrange,
                                        ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Material(
                                  color: AppColors.primaryOrange,
                                  borderRadius: BorderRadius.circular(14),
                                  child: InkWell(
                                    onTap: onAddTap,
                                    borderRadius: BorderRadius.circular(14),
                                    child: const Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Icon(
                                        Icons.add_rounded,
                                        color: AppColors.white,
                                      ),
                                    ),
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
        ),
      ),
    );
  }
}

class _CompactFoodCardBody extends StatelessWidget {
  const _CompactFoodCardBody({
    required this.item,
    required this.imageFit,
    required this.priceLabel,
    required this.onAddTap,
  });

  final MenuProduct item;
  final BoxFit imageFit;
  final String priceLabel;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
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
                    fit: imageFit,
                    alignment: Alignment.center,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 10,
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
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 13,
                      color: AppColors.yellowAccent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.rating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.brownAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      height: 1.12,
                    ),
                  ),
                ),
                if (item.hasMultipleVariants) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cardSurface,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${item.variants.length} sizes',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.brownAccent,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        priceLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Material(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: onAddTap,
                        borderRadius: BorderRadius.circular(16),
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.add_rounded,
                            size: 22,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
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
