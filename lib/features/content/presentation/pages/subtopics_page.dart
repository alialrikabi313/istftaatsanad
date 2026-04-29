import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../presentation/providers/content_providers.dart';

class SubtopicsPage extends ConsumerStatefulWidget {
  final String topicId;
  final String topicName;
  const SubtopicsPage(
      {super.key, required this.topicId, required this.topicName});

  @override
  ConsumerState<SubtopicsPage> createState() => _SubtopicsPageState();
}

class _SubtopicsPageState extends ConsumerState<SubtopicsPage>
    with SingleTickerProviderStateMixin {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = "";
  late final AnimationController _staggerController;

  // ألوان مميزة لكل بطاقة
  static const _accentColors = [
    Color(0xFFD4A843),
    Color(0xFF4A90D9),
    Color(0xFF50B87A),
    Color(0xFFE07C5A),
    Color(0xFF9B72CF),
    Color(0xFF48B5AA),
    Color(0xFFDB7093),
    Color(0xFF6B8E7B),
  ];

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subs = ref.watch(subtopicsProvider(widget.topicId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            // ═══ الهيدر المخصص ═══
            _buildHeader(context, isDark),

            // ═══ المحتوى ═══
            Expanded(
              child: subs.when(
                data: (list) {
                  final filteredList = list.where((element) {
                    return element.name
                        .toLowerCase()
                        .contains(_searchText.toLowerCase());
                  }).toList();

                  if (filteredList.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.gold.withValues(alpha:0.08),
                            ),
                            child: Icon(Icons.search_off_rounded,
                                size: 36,
                                color: AppColors.gold.withValues(alpha:0.4)),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            AppStrings.noMatchingResults,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    );
                  }

                  // إعادة تشغيل الأنيميشن عند البحث
                  _staggerController.forward(from: 0);

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                    itemCount: filteredList.length,
                    itemBuilder: (ctx, i) {
                      final s = filteredList[i];
                      final accent =
                          _accentColors[i % _accentColors.length];

                      return AnimatedBuilder(
                        animation: _staggerController,
                        builder: (context, child) {
                          final delay = (i * 0.08).clamp(0.0, 0.6);
                          final progress = CurvedAnimation(
                            parent: _staggerController,
                            curve: Interval(
                              delay,
                              (delay + 0.4).clamp(0.0, 1.0),
                              curve: Curves.easeOutCubic,
                            ),
                          );
                          return Opacity(
                            opacity: progress.value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - progress.value)),
                              child: child,
                            ),
                          );
                        },
                        child: _SubtopicCard(
                          name: s.name,
                          index: i,
                          accent: accent,
                          isDark: isDark,
                          onTap: () => ref.read(appRouterProvider).go(
                              '/questions?topicId=${widget.topicId}&subtopicId=${s.id}&subtopicName=${Uri.encodeComponent(s.name)}'),
                        ),
                      );
                    },
                  );
                },
                loading: () => _buildLoadingSkeleton(isDark),
                error: (e, _) => Center(child: Text('خطأ: $e')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  الهيدر المخصص
  // ═══════════════════════════════════════════════
  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.headerGradient,
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // زخرفة هندسية
          Positioned(
            top: -15,
            left: -20,
            child: _HeaderDecorCircle(size: 80, opacity: 0.04),
          ),
          Positioned(
            bottom: -10,
            right: -15,
            child: _HeaderDecorCircle(size: 60, opacity: 0.03),
          ),
          // القوس الزخرفي
          Positioned(
            bottom: 0,
            left: 30,
            right: 30,
            height: 40,
            child: CustomPaint(
              painter: _SubtleArchPainter(),
            ),
          ),

          if (_isSearching)
            _buildSearchHeader(context)
          else
            _buildNormalHeader(context),
        ],
      ),
    );
  }

  Widget _buildNormalHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // زر الرجوع
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.maybePop(context),
          ),
          const Spacer(),
          // العنوان
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.topicName,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 6),
              // خط زخرفي
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 16,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.gold.withValues(alpha:0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Transform.rotate(
                    angle: math.pi / 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 16,
                    height: 1.5,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gold.withValues(alpha:0.7),
                          Colors.transparent,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          // زر البحث
          IconButton(
            icon: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha:0.15),
                  width: 0.5,
                ),
              ),
              child: const Icon(Icons.search_rounded,
                  color: Colors.white70, size: 18),
            ),
            onPressed: () => setState(() => _isSearching = true),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchText = "";
                _searchController.clear();
              });
            },
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha:0.15),
                  width: 0.5,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 15),
                cursorColor: AppColors.gold,
                decoration: InputDecoration(
                  hintText: 'ابحث في الأقسام...',
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha:0.35),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear_rounded,
                              size: 18,
                              color: Colors.white.withValues(alpha:0.5)),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchText = "");
                          },
                        )
                      : null,
                ),
                onChanged: (val) => setState(() => _searchText = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton(bool isDark) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      itemCount: 6,
      itemBuilder: (_, i) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cardBackgroundDark
                : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (isDark ? AppColors.borderDark : AppColors.border)
                  .withValues(alpha:0.5),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 5,
                margin: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 140,
                      height: 14,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha:0.06),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 10,
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.white : Colors.black)
                            .withValues(alpha:0.04),
                        borderRadius: BorderRadius.circular(3),
                      ),
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

// ═══════════════════════════════════════════════
//  بطاقة القسم الفرعي
// ═══════════════════════════════════════════════
class _SubtopicCard extends StatelessWidget {
  final String name;
  final int index;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _SubtopicCard({
    required this.name,
    required this.index,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackgroundDark : Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDark.withValues(alpha:0.5)
                    : accent.withValues(alpha:0.12),
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
            child: Row(
              children: [
                // الأيقونة المرقمة
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha:0.12),
                        accent.withValues(alpha:0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: accent.withValues(alpha:0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: accent,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // النص
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.4,
                                ) ??
                            const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),

                // السهم
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha:0.06),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: accent.withValues(alpha:0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══ دائرة زخرفية للهيدر ═══
class _HeaderDecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _HeaderDecorCircle({required this.size, required this.opacity});

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
}

// ═══ قوس زخرفي خفيف ═══
class _SubtleArchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha:0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
        size.width * 0.5, size.height * 0.1, size.width, size.height);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
