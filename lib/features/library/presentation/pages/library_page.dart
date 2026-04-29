import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/library_providers.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/decorative_widgets.dart';
import '../../../../core/constants/app_colors.dart';

class LibraryPage extends ConsumerWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          drawer: const AppDrawer(),
          body: CustomScrollView(
            slivers: [
              // ─── الهيدر ───
              SliverToBoxAdapter(
                child: _buildHeader(context, isDark),
              ),

              // ─── المحتوى ───
              booksAsync.when(
                data: (books) {
                  if (books.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.gold.withValues(alpha:0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(
                                Icons.menu_book_outlined,
                                size: 36,
                                color: AppColors.gold.withValues(alpha:0.5),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "لا توجد كتب مضافة بعد",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.72,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) =>
                            _buildBookCard(context, books[i], i, isDark),
                        childCount: books.length,
                      ),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(
                    child:
                        CircularProgressIndicator(color: AppColors.gold),
                  ),
                ),
                error: (e, st) => SliverFillRemaining(
                  child: Center(child: Text('خطأ: $e')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primaryDeep, AppColors.primary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          // زخارف
          Positioned(
            top: -20,
            left: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha:0.05),
                  width: 1,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            right: -10,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha:0.04),
                  width: 1,
                ),
              ),
            ),
          ),
          // القوس الزخرفي
          Positioned(
            bottom: -5,
            left: 40,
            right: 40,
            height: 40,
            child: CustomPaint(
              painter: IslamicArchPainter(
                color: AppColors.gold.withValues(alpha:0.1),
              ),
            ),
          ),
          // المحتوى
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha:0.3),
                      width: 1,
                    ),
                    color: Colors.white.withValues(alpha:0.06),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: AppColors.gold,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'المكتبة',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'كتب ومؤلفات الشيخ',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          // زر القائمة
          Positioned(
            top: 12,
            right: 12,
            child: Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu_rounded,
                    color: Colors.white70, size: 26),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookCard(
      BuildContext context, dynamic book, int index, bool isDark) {
    // ألوان مميزة لكل بطاقة
    const accentColors = [
      Color(0xFF1B3A5C),
      Color(0xFF2E5984),
      Color(0xFF1A3C4A),
      Color(0xFF2D3A5C),
      Color(0xFF3A5A2E),
      Color(0xFF6A4A2E),
    ];
    final accent = accentColors[index % accentColors.length];

    if (isDark) {
      // ═══ الوضع الليلي: بطاقات داكنة كلاسيكية ═══
      return _buildDarkBookCard(context, book, accent);
    } else {
      // ═══ الوضع النهاري: بطاقات فاتحة أنيقة ═══
      return _buildLightBookCard(context, book, accent);
    }
  }

  Widget _buildLightBookCard(
      BuildContext context, dynamic book, Color accent) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.pushNamed('bookReader', extra: book),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accent.withValues(alpha:0.1),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha:0.08),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // شريط علوي ملون
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        accent.withValues(alpha:0.7),
                        AppColors.gold.withValues(alpha:0.5),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                ),
              ),
              // زخرفة هندسية خفيفة
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accent.withValues(alpha:0.05),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // المحتوى
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // أيقونة الكتاب
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            accent.withValues(alpha:0.1),
                            accent.withValues(alpha:0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: accent.withValues(alpha:0.15),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: accent,
                        size: 22,
                      ),
                    ),
                    // معلومات الكتاب
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            book.description,
                            style: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha:0.7),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 10),
                        // زر القراءة
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                accent.withValues(alpha:0.08),
                                AppColors.gold.withValues(alpha:0.06),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(9),
                            border: Border.all(
                              color: accent.withValues(alpha:0.15),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'اقرأ',
                                style: TextStyle(
                                  color: accent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 9,
                                color: accent.withValues(alpha:0.6),
                              ),
                            ],
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
      ),
    );
  }

  Widget _buildDarkBookCard(
      BuildContext context, dynamic book, Color accent) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => context.pushNamed('bookReader', extra: book),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent, accent.withValues(alpha:0.7)],
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              // زخرفة هندسية
              Positioned(
                top: -15,
                right: -15,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha:0.08),
                      width: 1,
                    ),
                  ),
                ),
              ),
              // إطار ذهبي داخلي
              Positioned(
                top: 8,
                left: 8,
                right: 8,
                bottom: 8,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha:0.12),
                      width: 0.5,
                    ),
                  ),
                ),
              ),
              // المحتوى
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha:0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.menu_book_rounded,
                        color: AppColors.gold,
                        size: 20,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (book.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            book.description,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha:0.5),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha:0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha:0.25),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'اقرأ',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 9,
                                color: AppColors.gold.withValues(alpha:0.7),
                              ),
                            ],
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
      ),
    );
  }
}
