import 'package:flutter/material.dart';

import '../services/cart_controller.dart';
import '../theme/app_theme.dart';

class CartActionButton extends StatelessWidget {
  const CartActionButton({
    super.key,
    required this.onTap,
    this.backgroundColor,
    this.iconColor,
    this.size = 50,
  });

  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cart = CartScope.of(context);

    return AnimatedBuilder(
      animation: cart,
      builder: (context, _) {
        final count = cart.totalItems;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: backgroundColor ?? AppColors.white,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    color: iconColor ?? AppColors.darkText,
                  ),
                ),
              ),
            ),
            if (count > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.yellowAccent,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                  child: Text(
                    '$count',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.darkText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
