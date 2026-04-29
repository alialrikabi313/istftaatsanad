import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class MyQuestionsPage extends ConsumerWidget {
  const MyQuestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(authStateProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (me == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: const CustomAppBar(title: 'أسئلتي'),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 56,
                  color: AppColors.gold.withValues(alpha:0.4),
                ),
                const SizedBox(height: 12),
                Text(
                  'سجّل دخولك لمشاهدة أسئلتك',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final stream = FirebaseFirestore.instance
        .collection('inbox')
        .where('uid', isEqualTo: me.uid)
        .orderBy('sentAt', descending: true)
        .snapshots();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'أسئلتي'),
        body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: stream,
          builder: (ctx, snap) {
            if (snap.hasError) {
              return Center(child: Text('خطأ: ${snap.error}'));
            }
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }
            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 56,
                      color: AppColors.gold.withValues(alpha:0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'لم ترسل أي أسئلة بعد',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: docs.length,
              itemBuilder: (ctx, i) {
                final d = docs[i].data();
                final q = d['text'] as String? ?? '';
                final ans = d['answer'] as String?;
                final status = d['status'] as String? ?? 'new';
                return Container(
                  padding: const EdgeInsets.all(16),
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
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha:0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.help_outline_rounded,
                              color: AppColors.primary,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              q,
                              style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ) ??
                                  const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
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
                          ],
                        ),
                      ),
                      if (ans != null && ans.isNotEmpty)
                        Text(
                          ans,
                          style: Theme.of(context).textTheme.bodyMedium,
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              status == 'reviewed'
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.schedule_rounded,
                              size: 16,
                              color: status == 'reviewed'
                                  ? AppColors.success
                                  : AppColors.gold.withValues(alpha:0.6),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status == 'reviewed'
                                  ? 'تمت المراجعة – سيظهر الجواب قريبًا'
                                  : 'بانتظار الإجابة',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: status == 'reviewed'
                                        ? AppColors.success
                                        : null,
                                  ),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
