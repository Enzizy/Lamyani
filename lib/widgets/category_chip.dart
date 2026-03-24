import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.label,
    required this.selected,
    this.icon,
    this.compact = false,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final IconData? icon;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 14 : 16,
          vertical: compact ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryOrange : AppColors.white,
          borderRadius: BorderRadius.circular(compact ? 16 : 18),
          boxShadow: selected ? AppTheme.softShadow : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: compact ? 16 : 18,
                color: selected ? AppColors.white : AppColors.brownAccent,
              ),
              SizedBox(width: compact ? 6 : 8),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.white : AppColors.darkText,
                fontWeight: FontWeight.w700,
                fontSize: compact ? 14 : 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
