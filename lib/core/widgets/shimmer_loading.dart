import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// ويدجت تأثير نبض للتحميل
class PulseBox extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const PulseBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  State<PulseBox> createState() => _PulseBoxState();
}

class _PulseBoxState extends State<PulseBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _opacity = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? AppColors.borderDark : AppColors.shimmerBase;

    return FadeTransition(
      opacity: _opacity,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

/// هيكل تحميل لبطاقة القسم
class TopicCardSkeleton extends StatelessWidget {
  const TopicCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          // شريط جانبي
          Container(
            width: 5,
            height: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.shimmerBase,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // أيقونة
          const PulseBox(width: 44, height: 44, borderRadius: 12),
          const SizedBox(width: 14),
          // نص
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PulseBox(width: 160, height: 14, borderRadius: 4),
                SizedBox(height: 8),
                PulseBox(width: 100, height: 10, borderRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}
