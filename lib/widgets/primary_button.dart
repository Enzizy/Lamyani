import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = true,
    this.backgroundColor = AppColors.primaryOrange,
    this.foregroundColor = AppColors.white,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;
  final Color backgroundColor;
  final Color foregroundColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          disabledBackgroundColor: AppColors.primaryOrange.withValues(
            alpha: 0.5,
          ),
          disabledForegroundColor: AppColors.white,
          shadowColor: AppColors.primaryOrange.withValues(alpha: 0.35),
          elevation: onPressed == null ? 0 : 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 18),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: onPressed == null
                ? null
                : LinearGradient(
                    colors: [
                      backgroundColor,
                      Color.lerp(
                            backgroundColor,
                            AppColors.yellowAccent,
                            0.18,
                          ) ??
                          backgroundColor,
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                if (icon != null) ...[
                  const SizedBox(width: 8),
                  Icon(icon, size: 18),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
