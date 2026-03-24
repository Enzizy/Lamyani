import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.actionLabel,
    this.onActionTap,
    this.subtitle,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onActionTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: subtitle != null ? 42 : 24,
          margin: const EdgeInsets.only(top: 2, right: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryOrange,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: textTheme.titleLarge),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(subtitle!, style: textTheme.bodyMedium),
              ],
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}
