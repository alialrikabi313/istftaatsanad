import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fatawa_sanad/core/widgets/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../providers/content_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/qa_tile.dart';

class MyQuestionsPage extends ConsumerWidget {
  const MyQuestionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;

    if (user == null) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          appBar: const CustomAppBar(title: 'أسئلتي'),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha:0.08),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 36,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'هذه الميزة متاحة للأعضاء فقط',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ) ??
                        const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الرجاء تسجيل الدخول لعرض أسئلتك وأجوبتها.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final prefs = ref.read(sharedPrefsProvider);
                      await prefs.setBool('isGuest', false);
                      if (context.mounted) context.goNamed('signin');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.primaryDeep,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.login_rounded, size: 20),
                    label: const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final myQuestions = ref.watch(myQuestionsProvider(user.uid));
    final favorites = ref.watch(favoritesProvider).value ?? {};

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'أسئلتي'),
        body: myQuestions.when(
          data: (items) {
            if (items.isEmpty) {
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
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (ctx, i) => QaTile(
                item: items[i],
                isFavorite: favorites.contains(items[i].id),
                onTap: () => context.pushNamed(
                  'questionDetail',
                  queryParameters: {
                    'id': items[i].id,
                    'q': items[i].question,
                    'a': items[i].answer,
                    'topicName': '',
                    'subtopicName': 'أسئلتي',
                  },
                ),
                onToggleFavorite: (val) => ref
                    .read(favoritesProvider.notifier)
                    .toggle(items[i].id, val),
              ),
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          ),
          error: (e, st) => Center(child: Text('خطأ: $e')),
        ),
      ),
    );
  }
}
