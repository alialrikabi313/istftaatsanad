import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            // ─── الهيدر الفاخر ───
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              toolbarHeight: 60,
              iconTheme: const IconThemeData(color: Colors.white),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: AppColors.headerGradient,
                    ),
                  ),
                  child: Stack(
                    children: [
                      // زخارف هندسية خفيفة
                      Positioned(
                        top: -30,
                        left: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha:0.08),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 40,
                        right: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha:0.06),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                      // المحتوى
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            // الأيقونة
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: AppColors.gold.withValues(alpha:0.5),
                                  width: 1.5,
                                ),
                                color: Colors.white.withValues(alpha:0.08),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.gold,
                                size: 38,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'استفتاءات الشيخ السند',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: 50,
                              height: 2.5,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'الإصدار 1.0.0',
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
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "حول التطبيق",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      width: 30,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ],
                ),
                centerTitle: true,
                titlePadding: const EdgeInsets.only(bottom: 14),
              ),
            ),

            // ─── المحتوى ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الوصف
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.cardBackgroundDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                          width: 0.8,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryDeep
                                .withValues(alpha:isDark ? 0.2 : 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 22,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: AppColors.goldGradient,
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'عن التطبيق',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'يوفر هذا التطبيق خدمة طرح الأسئلة الشرعية مباشرةً، '
                            'مع إمكانية متابعة الإجابات المراجَعة من قبل الإدارة. '
                            'التطبيق مخصص لعرض استفتاءات سماحة الشيخ السند (حفظه الله) '
                            'بطريقة سهلة ومنظمة.',
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      height: 1.8,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // عنوان المزايا
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 22,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: AppColors.goldGradient,
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'مزايا التطبيق',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // المزايا
                    _buildFeatureItem(context, isDark,
                        Icons.help_outline_rounded, 'طرح الأسئلة ومتابعتها'),
                    _buildFeatureItem(context, isDark,
                        Icons.category_outlined, 'تصفح الأقسام والموضوعات'),
                    _buildFeatureItem(context, isDark, Icons.search_rounded,
                        'البحث الشامل في الإجابات والكتب'),
                    _buildFeatureItem(
                        context,
                        isDark,
                        Icons.star_outline_rounded,
                        'المفضلة لحفظ الأسئلة الهامة'),
                    _buildFeatureItem(context, isDark,
                        Icons.menu_book_outlined, 'مكتبة كتب متكاملة'),
                    _buildFeatureItem(context, isDark,
                        Icons.notifications_outlined, 'إشعارات بالتحديثات'),

                    const SizedBox(height: 28),

                    // المطور
                    Center(
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 40),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 1,
                                  color: AppColors.gold.withValues(alpha:0.4),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    height: 0.5,
                                    color: isDark
                                        ? AppColors.dividerDark
                                        : AppColors.divider,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 24,
                                  height: 1,
                                  color: AppColors.gold.withValues(alpha:0.4),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'تطوير: علي الراكبي',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    bool isDark,
    IconData icon,
    String text,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:isDark ? 0.15 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.gold, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
