import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/question.dart';
import '../../../../core/widgets/text_highlighter.dart';

class QaTile extends StatelessWidget {
  final Question item;
  final bool isFavorite;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleFavorite;
  final String? highlightQuery;
  final bool showNewBadge;

  const QaTile({
    super.key,
    required this.item,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.highlightQuery,
    this.showNewBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final answerText =
        item.answer.isNotEmpty ? item.answer : 'لم تتم الإجابة بعد';
    final hasAnswer = item.answer.isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackgroundDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha:isDark ? 0.2 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── القسم العلوي: السؤال ───
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // الأيقونة مع خلفية
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withValues(alpha:0.12),
                            AppColors.primary.withValues(alpha:0.04),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // نص السؤال
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showNewBadge)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFF0DCA4),
                                    Color(0xFFD4A843),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'جديد',
                                style: TextStyle(
                                  color: AppColors.primaryDeep,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          _buildText(
                            context,
                            item.question,
                            Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      height: 1.5,
                                    ) ??
                                const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  height: 1.5,
                                ),
                            3,
                          ),
                        ],
                      ),
                    ),
                    // زر المفضلة
                    const SizedBox(width: 4),
                    InkWell(
                      onTap: () => onToggleFavorite(!isFavorite),
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Icon(
                          isFavorite
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFavorite
                              ? AppColors.favoriteActive
                              : AppColors.favoriteInactive,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ─── الفاصل المزخرف ───
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.gold.withValues(alpha:0.5),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 20,
                      height: 1,
                      color: AppColors.gold.withValues(alpha:0.3),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 0.5,
                        color: isDark
                            ? AppColors.dividerDark
                            : AppColors.divider,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── القسم السفلي: الجواب ───
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: hasAnswer
                            ? AppColors.gold.withValues(alpha:0.1)
                            : Colors.grey.withValues(alpha:0.08),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: Icon(
                        hasAnswer
                            ? Icons.chat_rounded
                            : Icons.schedule_rounded,
                        color: hasAnswer
                            ? AppColors.gold
                            : Colors.grey,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildText(
                        context,
                        answerText,
                        Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                  color: hasAnswer ? null : Colors.grey,
                                ) ??
                            const TextStyle(fontSize: 14, height: 1.5),
                        3,
                      ),
                    ),
                  ],
                ),
              ),

              // ─── زر اقرأ المزيد ───
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.gold.withValues(alpha:0.04)
                      : AppColors.gold.withValues(alpha:0.03),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: AppColors.gold.withValues(alpha:0.1),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "اقرأ المزيد",
                      style: TextStyle(
                        color: AppColors.gold,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: AppColors.gold,
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

  Widget _buildText(
    BuildContext context,
    String text,
    TextStyle style,
    int maxLines,
  ) {
    if (highlightQuery != null && highlightQuery!.isNotEmpty) {
      return TextHighlighter(
        text: text,
        query: highlightQuery!,
        style: style,
        maxLines: maxLines,
      );
    }
    return Text(
      text,
      style: style,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
