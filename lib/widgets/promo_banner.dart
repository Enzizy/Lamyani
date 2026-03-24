import 'package:flutter/material.dart';

import '../screens/mock_data.dart';
import '../theme/app_theme.dart';
import 'app_image.dart';
import 'brand_logo.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({super.key, required this.promo});

  final PromoItem promo;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 290,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: AppTheme.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          children: [
            AppImage(source: promo.imageUrl, fit: BoxFit.cover),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryOrange.withValues(alpha: 0.92),
                    AppColors.brownAccent.withValues(alpha: 0.72),
                    AppColors.darkText.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BrandLogo(size: 24),
                    SizedBox(width: 8),
                    Text(
                      'Lamyani',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.yellowAccent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Fresh Drop',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    promo.title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    promo.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFFFFF4D7),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 16,
                        color: AppColors.yellowAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Roasted best-seller',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
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
    );
  }
}
