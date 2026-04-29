import 'package:flutter/material.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';

/// ويدجت مخصصة لعرض الحالات الفارغة
class EmptyStateWidget extends StatelessWidget {
  final String? message;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    this.message,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 56,
              color: AppColors.gold.withValues(alpha:0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message ?? AppStrings.noData,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (action != null) ...[
              const SizedBox(height: 24),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
