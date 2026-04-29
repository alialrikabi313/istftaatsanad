import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════
//  زخارف إسلامية وعناصر تزيينية فاخرة
// ═══════════════════════════════════════════════════════════

/// قوس زخرفي إسلامي - يُرسم أعلى الأقسام
class IslamicArchPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  IslamicArchPainter({
    this.color = const Color(0x30D4A843),
    this.strokeWidth = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final w = size.width;
    final h = size.height;

    // القوس الرئيسي
    final archPath = Path();
    archPath.moveTo(0, h);
    archPath.quadraticBezierTo(w * 0.1, h * 0.15, w * 0.5, h * 0.05);
    archPath.quadraticBezierTo(w * 0.9, h * 0.15, w, h);
    canvas.drawPath(archPath, paint);

    // القوس الداخلي
    final innerPaint = Paint()
      ..color = color.withValues(alpha:color.a * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 0.6;
    final innerPath = Path();
    innerPath.moveTo(w * 0.08, h);
    innerPath.quadraticBezierTo(w * 0.15, h * 0.25, w * 0.5, h * 0.15);
    innerPath.quadraticBezierTo(w * 0.85, h * 0.25, w * 0.92, h);
    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// فاصل زخرفي إسلامي (ماسة مع خطوط)
class OrnamentalDivider extends StatelessWidget {
  final double width;
  final Color? color;

  const OrnamentalDivider({super.key, this.width = double.infinity, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.gold.withValues(alpha:0.4);
    return SizedBox(
      width: width,
      height: 20,
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, c],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // الماسة الزخرفية
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: c,
                border: Border.all(color: c, width: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: c,
            ),
          ),
          const SizedBox(width: 6),
          Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: c,
                border: Border.all(color: c, width: 0.5),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 0.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنوان قسم فاخر مع خط ذهبي وزخرفة
class SectionTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // الشريط الذهبي المزخرف
          Column(
            children: [
              Container(
                width: 3,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: AppColors.goldGradient,
                  ),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 3,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.gold.withValues(alpha:0.7),
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// بطاقة إحصائية صغيرة
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardBackgroundDark
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.gold.withValues(alpha:0.15),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.goldDark,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// هيدر بطولي فاخر مع قوس إسلامي
class HeroHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double height;

  const HeroHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.headerGradient,
        ),
      ),
      child: Stack(
        children: [
          // زخارف هندسية خلفية
          Positioned(
            top: -20,
            right: -20,
            child: _GeometricCircle(size: 140, opacity: 0.04),
          ),
          Positioned(
            bottom: -10,
            left: -30,
            child: _GeometricCircle(size: 100, opacity: 0.03),
          ),
          Positioned(
            top: 20,
            left: 40,
            child: _GeometricCircle(size: 50, opacity: 0.05),
          ),
          // القوس الزخرفي
          Positioned(
            bottom: 0,
            left: 20,
            right: 20,
            height: 60,
            child: CustomPaint(
              painter: IslamicArchPainter(
                color: AppColors.gold.withValues(alpha:0.15),
                strokeWidth: 1.0,
              ),
            ),
          ),
          // المحتوى
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                // أيقونة
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha:0.4),
                      width: 1,
                    ),
                    color: Colors.white.withValues(alpha:0.06),
                  ),
                  child: const Icon(
                    Icons.auto_stories_rounded,
                    color: AppColors.gold,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                // خط ذهبي مزخرف
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.gold.withValues(alpha:0.6),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 4,
                        height: 4,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 20,
                      height: 1,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.gold.withValues(alpha:0.6),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.gold.withValues(alpha:0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// دائرة هندسية زخرفية
class _GeometricCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _GeometricCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.gold.withValues(alpha:opacity),
                width: 1,
              ),
            ),
          ),
          Center(
            child: Container(
              width: size * 0.65,
              height: size * 0.65,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha:opacity * 0.6),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// إطار مزخرف للبطاقات المميزة
class OrnamentalFrame extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const OrnamentalFrame({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha:0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:isDark ? 0.25 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          // زخرفة الزاوية العليا اليمنى
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _CornerOrnamentPainter(isTopRight: true),
            ),
          ),
          // زخرفة الزاوية السفلى اليسرى
          Positioned(
            bottom: 0,
            left: 0,
            child: CustomPaint(
              size: const Size(40, 40),
              painter: _CornerOrnamentPainter(isTopRight: false),
            ),
          ),
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}

class _CornerOrnamentPainter extends CustomPainter {
  final bool isTopRight;
  _CornerOrnamentPainter({required this.isTopRight});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha:0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    if (isTopRight) {
      canvas.drawLine(
        Offset(size.width - 12, 0),
        Offset(size.width, 0),
        paint,
      );
      canvas.drawLine(
        Offset(size.width, 0),
        Offset(size.width, 12),
        paint,
      );
      // القوس
      final arcRect = Rect.fromLTWH(
          size.width - 24, -12, 24, 24);
      canvas.drawArc(arcRect, 0, math.pi / 2, false, paint);
    } else {
      canvas.drawLine(
        Offset(0, size.height - 12),
        Offset(0, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(0, size.height),
        Offset(12, size.height),
        paint,
      );
      final arcRect = Rect.fromLTWH(
          0, size.height - 12, 24, 24);
      canvas.drawArc(arcRect, math.pi, math.pi / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
