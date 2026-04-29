import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/decorative_widgets.dart';
import '../providers/content_providers.dart';

class QuestionDetailPage extends ConsumerWidget {
  final String id;
  final String question;
  final String answer;
  final String topicName;
  final String subtopicName;

  const QuestionDetailPage({
    super.key,
    required this.id,
    required this.question,
    required this.answer,
    required this.topicName,
    required this.subtopicName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favorites = ref.watch(favoritesProvider).value ?? {};
    final isFavorite = favorites.contains(id);

    return SafeArea(
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.scaffoldBackgroundDark
              : Theme.of(context).scaffoldBackgroundColor,
          body: Column(
            children: [
              // ─── الهيدر المزخرف ───
              _buildHeader(context, isDark),

              // ─── المحتوى ───
              Expanded(
                child: SelectionArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // شارة القسم
                        if (subtopicName.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.gold.withValues(alpha:0.15),
                                  AppColors.gold.withValues(alpha:0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha:0.25),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.folder_outlined,
                                    size: 13, color: AppColors.goldDark),
                                const SizedBox(width: 6),
                                Text(
                                  subtopicName,
                                  style: const TextStyle(
                                    color: AppColors.goldDark,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 20),

                        // ─── بطاقة السؤال بإطار مزخرف ───
                        OrnamentalFrame(
                          padding: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // عنوان السؤال
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            AppColors.primary.withValues(alpha:0.15),
                                            AppColors.primary.withValues(alpha:0.05),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Icon(
                                        Icons.help_outline_rounded,
                                        color: AppColors.primary,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      AppStrings.theQuestion,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primary,
                                          ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // نص السؤال
                                Text(
                                  question,
                                  style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                            height: 1.6,
                                          ) ??
                                      const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          height: 1.6),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // ─── فاصل زخرفي ───
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: OrnamentalDivider(),
                        ),

                        const SizedBox(height: 24),

                        // ─── قسم الجواب ───
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // عنوان الجواب
                              Row(
                                children: [
                                  // شريط ذهبي مزخرف
                                  Column(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: AppColors.gold,
                                          borderRadius:
                                              BorderRadius.circular(1.5),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Container(
                                        width: 3,
                                        height: 14,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: AppColors.goldGradient,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(1.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 10),
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.gold.withValues(alpha:0.15),
                                          AppColors.gold.withValues(alpha:0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.chat_rounded,
                                      color: AppColors.goldDark,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    AppStrings.theAnswer,
                                    style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                            ) ??
                                        const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // نص الجواب
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.cardBackgroundDark
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border(
                                    right: BorderSide(
                                      color: AppColors.gold.withValues(alpha:0.4),
                                      width: 3,
                                    ),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryDeep
                                          .withValues(alpha:isDark ? 0.2 : 0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  answer.isEmpty
                                      ? AppStrings.notAnsweredYet
                                      : answer,
                                  textAlign: TextAlign.justify,
                                  style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(height: 2.0) ??
                                      const TextStyle(
                                          fontSize: 17, height: 2.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // ─── شريط الإجراءات السفلي ───
              _buildActionBar(context, ref, isDark, isFavorite),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(top: 8, bottom: 16, right: 8, left: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryDeep, AppColors.primary],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 20),
            onPressed: () => Navigator.maybePop(context),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تفاصيل الاستفتاء',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                // خط زخرفي
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 16,
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
                    const SizedBox(width: 4),
                    Transform.rotate(
                      angle: math.pi / 4,
                      child: Container(
                        width: 4,
                        height: 4,
                        color: AppColors.gold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 16,
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
              ],
            ),
          ),
          const SizedBox(width: 48), // لتوازن مع زر الرجوع
        ],
      ),
    );
  }

  Widget _buildActionBar(
      BuildContext context, WidgetRef ref, bool isDark, bool isFavorite) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withValues(alpha:0.15),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ActionButton(
            icon: Icons.copy_rounded,
            label: AppStrings.copy,
            onTap: () {
              Clipboard.setData(
                  ClipboardData(text: "س: $question\n\nج: $answer"));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(AppStrings.copiedQA),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  backgroundColor: AppColors.primaryDeep,
                ),
              );
            },
          ),
          // فاصل عمودي
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _ActionButton(
            icon: Icons.share_rounded,
            label: AppStrings.share,
            onTap: () {
              Share.share(
                "س: $question\n\nج: $answer\n\n— استفتاءات الشيخ السند",
              );
            },
          ),
          Container(
            width: 1,
            height: 30,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          _ActionButton(
            icon: isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
            label: isFavorite ? 'محفوظ' : AppStrings.save,
            isActive: isFavorite,
            onTap: () async {
              await ref
                  .read(contentRepositoryProvider)
                  .toggleFavorite(id, !isFavorite);
              ref.invalidate(favoritesProvider);
            },
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.gold.withValues(alpha:0.15)
                    : AppColors.gold.withValues(alpha:0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isActive ? AppColors.favoriteActive : AppColors.gold,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? AppColors.goldDark : null,
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
