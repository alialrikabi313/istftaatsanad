import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class GoldAccentCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  const GoldAccentCard({super.key, required this.child, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // الشريط الذهبي
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.goldGradient,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: child),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.gold.withValues(alpha:0.6),
          ),
        ],
      ),
    );

    return onTap != null
        ? Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: card,
            ),
          )
        : card;
  }
}
