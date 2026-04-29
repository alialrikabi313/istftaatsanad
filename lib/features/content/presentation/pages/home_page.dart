import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/decorative_widgets.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/question.dart';
import '../providers/content_providers.dart';
import '../widgets/ask_question_sheet.dart';
import '../pages/questions_page.dart';
import '../../../../features/library/presentation/pages/library_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _entranceController;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      const LibraryPage(),
      _buildIstiftaatTab(isDark),
      const QuestionsPage(
        topicId: 'fav',
        subtopicId: 'fav',
        subtopicName: 'المفضلة',
      ),
      const QuestionsPage(
        topicId: 'all',
        subtopicId: 'search',
        subtopicName: 'بحث',
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: pages,
          ),
          bottomNavigationBar: _buildBottomNav(isDark),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  //  تبويب الاستفتاءات - التصميم الجديد بالكامل
  // ═══════════════════════════════════════════════════════════
  Widget _buildIstiftaatTab(bool isDark) {
    final topics = ref.watch(topicsProvider);
    final newQuestions = ref.watch(newQuestionsProvider);
    final favorites = ref.watch(favoritesProvider).value ?? {};

    return SafeArea(
      child: Scaffold(
        drawer: const AppDrawer(),
        body: CustomScrollView(
          slivers: [
            // ─── الهيدر البطولي ───
            SliverToBoxAdapter(
              child: _buildHeroSection(isDark),
            ),

            // ─── شريط الإحصائيات ───
            SliverToBoxAdapter(
              child: _buildStatsRow(topics, newQuestions),
            ),

            // ─── قسم الاستفتاءات الجديدة ───
            SliverToBoxAdapter(
              child: newQuestions.when(
                data: (questions) {
                  if (questions.isEmpty) return const SizedBox.shrink();
                  return _buildNewQuestionsSection(
                      questions, favorites, isDark);
                },
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 140,
                        height: 16,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white10 : Colors.black12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: 3,
                          separatorBuilder: (_, __) => const SizedBox(width: 12),
                          itemBuilder: (_, __) => Container(
                            width: 280,
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04),
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                error: (e, _) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      const Expanded(child: Text('تعذر تحميل الاستفتاءات الحديثة')),
                      TextButton(
                        onPressed: () => ref.invalidate(newQuestionsProvider),
                        child: const Text('إعادة', style: TextStyle(color: AppColors.gold)),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ─── فاصل زخرفي ───
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
                child: OrnamentalDivider(),
              ),
            ),

            // ─── عنوان الأقسام ───
            SliverToBoxAdapter(
              child: SectionTitle(
                title: AppStrings.allTopics,
                subtitle: 'تصفح حسب الموضوع',
              ),
            ),

            // ─── شبكة الأقسام ───
            topics.when(
              data: (items) {
                if (items.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.folder_open_outlined,
                              size: 56,
                              color: AppColors.gold.withValues(alpha:0.4),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppStrings.noTopics,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final delay = (i * 0.08).clamp(0.0, 0.5);
                        final end = (delay + 0.5).clamp(0.0, 1.0);
                        final fadeAnim = Tween<double>(
                          begin: 0.0,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _entranceController,
                          curve:
                              Interval(delay, end, curve: Curves.easeOutCubic),
                        ));
                        final scaleAnim = Tween<double>(
                          begin: 0.85,
                          end: 1.0,
                        ).animate(CurvedAnimation(
                          parent: _entranceController,
                          curve:
                              Interval(delay, end, curve: Curves.easeOutCubic),
                        ));

                        return FadeTransition(
                          opacity: fadeAnim,
                          child: ScaleTransition(
                            scale: scaleAnim,
                            child: _buildTopicGridCard(
                                items[i], i, isDark),
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                );
              },
              loading: () => SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => const TopicCardSkeleton(),
                    childCount: 6,
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60),
                  child: Center(child: Text('خطأ: $e')),
                ),
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFAB(context),
      ),
    );
  }

  // ─── الهيدر البطولي ───
  Widget _buildHeroSection(bool isDark) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.headerGradient,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // الزخارف الهندسية
          Positioned(
            top: -30,
            right: -30,
            child: _buildGeometricDecor(120, 0.05),
          ),
          Positioned(
            bottom: 20,
            left: -20,
            child: _buildGeometricDecor(80, 0.04),
          ),
          Positioned(
            top: 15,
            left: 30,
            child: _buildGeometricDecor(35, 0.06),
          ),
          // القوس الزخرفي في الأسفل
          Positioned(
            bottom: -5,
            left: 30,
            right: 30,
            height: 50,
            child: CustomPaint(
              painter: IslamicArchPainter(
                color: AppColors.gold.withValues(alpha:0.12),
                strokeWidth: 1,
              ),
            ),
          ),
          // المحتوى
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // أيقونة مع إطار ذهبي
                Container(
                  width: 56,
                  height: 56,
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
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                // العنوان الرئيسي
                const Text(
                  'استفتاءات الشيخ السند',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                // خط زخرفي
                _buildOrnamentalLine(),
                const SizedBox(height: 8),
                Text(
                  'مرجعكم الموثوق للأحكام الشرعية',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
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
                icon: const Icon(Icons.menu_rounded, color: Colors.white70, size: 26),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeometricDecor(double size, double opacity) {
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
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha:opacity * 0.5),
                  width: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrnamentalLine() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.transparent, AppColors.gold.withValues(alpha:0.5)],
            ),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 4),
        Transform.rotate(
          angle: 0.785, // pi/4
          child: Container(width: 5, height: 5, color: AppColors.gold),
        ),
        const SizedBox(width: 4),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.gold,
          ),
        ),
        const SizedBox(width: 6),
        Container(
          width: 24,
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gold.withValues(alpha:0.5), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }

  // ─── شريط الإحصائيات ───
  Widget _buildStatsRow(AsyncValue topics, AsyncValue newQ) {
    final topicCount = topics.whenOrNull(data: (t) => t.length) ?? 0;
    final newCount = newQ.whenOrNull(data: (q) => q.length) ?? 0;

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            Expanded(
              child: StatCard(
                value: '$topicCount',
                label: 'قسم',
                icon: Icons.category_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '$newCount',
                label: 'حديثة',
                icon: Icons.fiber_new_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatCard(
                value: '24h',
                label: 'آخر تحديث',
                icon: Icons.schedule_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── قسم الاستفتاءات الجديدة ───
  Widget _buildNewQuestionsSection(
    List<Question> questions,
    Set<String> favorites,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان
        SectionTitle(
          title: AppStrings.newQuestions,
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha:0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.gold.withValues(alpha:0.25),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.schedule_rounded,
                    size: 12, color: AppColors.gold.withValues(alpha:0.7)),
                const SizedBox(width: 4),
                Text(
                  '${questions.length} ${AppStrings.last48Hours}',
                  style: TextStyle(
                    color: AppColors.goldDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // القائمة الأفقية
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: questions.length,
            itemBuilder: (ctx, i) => _buildNewQuestionCard(
              context,
              questions[i],
              favorites.contains(questions[i].id),
              isDark,
              i,
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ─── بطاقة استفتاء جديد - تصميم جديد ───
  Widget _buildNewQuestionCard(
    BuildContext context,
    Question question,
    bool isFavorite,
    bool isDark,
    int index,
  ) {
    return Container(
      width: 290,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            context.pushNamed('questionDetail', queryParameters: {
              'id': question.id,
              'q': question.question,
              'a': question.answer,
              'topicName': question.topicName,
              'subtopicName': question.subtopicName,
            });
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? [
                        const Color(0xFF1A2F45),
                        const Color(0xFF162535),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFFCF9F2),
                      ],
              ),
              border: Border.all(
                color: AppColors.gold.withValues(alpha:0.25),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDeep
                      .withValues(alpha:isDark ? 0.3 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // زخرفة الزاوية
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomRight: Radius.circular(30),
                      ),
                      color: AppColors.gold.withValues(alpha:0.06),
                    ),
                  ),
                ),
                // المحتوى
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الشارة والقسم
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFF0DCA4),
                                  Color(0xFFD4A843),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.fiber_new_rounded,
                                    size: 12, color: AppColors.primaryDeep),
                                const SizedBox(width: 3),
                                Text(
                                  'جديد',
                                  style: TextStyle(
                                    color: AppColors.primaryDeep,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (question.topicName.isNotEmpty)
                            Flexible(
                              child: Text(
                                question.topicName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark
                                      ? Colors.white38
                                      : AppColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // نص السؤال
                      Expanded(
                        child: Text(
                          question.question,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    height: 1.5,
                                  ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // الإجراءات
                      Row(
                        children: [
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 11, color: AppColors.gold),
                          const SizedBox(width: 4),
                          Text(
                            'اقرأ الجواب',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          InkWell(
                            onTap: () async {
                              await ref
                                  .read(contentRepositoryProvider)
                                  .toggleFavorite(
                                      question.id, !isFavorite);
                              ref.invalidate(favoritesProvider);
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Icon(
                                isFavorite
                                    ? Icons.star_rounded
                                    : Icons.star_outline_rounded,
                                size: 22,
                                color: isFavorite
                                    ? AppColors.favoriteActive
                                    : AppColors.favoriteInactive,
                              ),
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
      ),
    );
  }

  // ─── بطاقة قسم في الشبكة - تصميم جديد ───
  Widget _buildTopicGridCard(dynamic topic, int index, bool isDark) {
    // ألوان متنوعة لكل بطاقة
    final accentColors = [
      const Color(0xFFD4A843),
      const Color(0xFF4A7FAD),
      const Color(0xFF6B8E6B),
      const Color(0xFFC0785C),
      const Color(0xFF8B7BBE),
      const Color(0xFF5C9EAD),
    ];
    final accent = accentColors[index % accentColors.length];

    final icons = [
      Icons.auto_stories_rounded,
      Icons.gavel_rounded,
      Icons.mosque_rounded,
      Icons.family_restroom_rounded,
      Icons.account_balance_rounded,
      Icons.volunteer_activism_rounded,
    ];
    final icon = icons[index % icons.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          context.pushNamed('subtopics', queryParameters: {
            'topicId': topic.id,
            'topicName': topic.name,
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? AppColors.cardBackgroundDark : Colors.white,
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDeep
                    .withValues(alpha:isDark ? 0.25 : 0.06),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Stack(
            children: [
              // الزخرفة العلوية
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha:0.08),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(30),
                    ),
                  ),
                ),
              ),
              // المحتوى
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // الأيقونة
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: accent.withValues(alpha:0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Icon(icon, color: accent, size: 22),
                    ),
                    // الاسم
                    Text(
                      topic.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // سهم صغير
              Positioned(
                bottom: 12,
                left: 12,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: accent.withValues(alpha:0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── زر إرسال سؤال ───
  Widget _buildFAB(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFF0DCA4), Color(0xFFD4A843)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha:0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        onPressed: () {
          final user = FirebaseAuth.instance.currentUser;
          final senderIdentity = user?.email ?? "(المستخدم ضيف)";
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (ctx) =>
                AskQuestionSheet(senderIdentity: senderIdentity),
          );
        },
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.primaryDeep,
        elevation: 0,
        icon: const Icon(Icons.edit_rounded, size: 20),
        label: const Text(
          AppStrings.sendQuestion,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    );
  }

  // ─── شريط التنقل السفلي - تصميم محسّن ───
  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryDeep, AppColors.primary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:0.4),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.menu_book_outlined,
                  Icons.menu_book_rounded, AppStrings.library),
              _buildNavItem(1, Icons.question_answer_outlined,
                  Icons.question_answer_rounded, AppStrings.questions),
              _buildNavItem(2, Icons.star_outline_rounded,
                  Icons.star_rounded, AppStrings.favorites),
              _buildNavItem(3, Icons.search_rounded,
                  Icons.search_rounded, AppStrings.search),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index, IconData icon, IconData activeIcon, String label) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () => setState(() => _selectedIndex = index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 18 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gold.withValues(alpha:0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(
                  color: AppColors.gold.withValues(alpha:0.2), width: 0.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.gold : Colors.white38,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.gold : Colors.white38,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
