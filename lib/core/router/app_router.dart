import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../main.dart';
import '../constants/app_routes.dart';

// صفحات الاستفتاءات
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/content/presentation/pages/home_page.dart';
import '../../features/content/presentation/pages/subtopics_page.dart';
import '../../features/content/presentation/pages/questions_page.dart';
import '../../features/content/presentation/pages/my_questions_page.dart';
import '../../features/content/presentation/pages/question_detail_page.dart';

// صفحات المكتبة
import '../../features/library/presentation/pages/book_reader_page.dart';
import '../../features/library/domain/entities/book.dart';

// صفحة الإعدادات
import '../pages/settings_page.dart';

final authStateChangesProvider =
StreamProvider<User?>((ref) => FirebaseAuth.instance.authStateChanges());

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);

  return GoRouter(
    initialLocation: AppRoutes.signIn,
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),

    redirect: (ctx, state) {
      final loggingIn = state.matchedLocation == AppRoutes.signIn;
      final firebaseUser = FirebaseAuth.instance.currentUser;
      final isGuest = prefs.getBool('isGuest') ?? false;
      final isLoggedIn = firebaseUser != null || isGuest;

      if (!isLoggedIn && !loggingIn) return AppRoutes.signIn;
      if (isLoggedIn && loggingIn) return AppRoutes.home;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.signIn,
        name: AppRoutes.signInName,
        builder: (ctx, st) => const SignInPage(),
      ),
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (ctx, st) => const HomePage(),
        routes: [
          // مسارات الاستفتاءات
          GoRoute(
            path: AppRoutes.subtopics,
            name: AppRoutes.subtopicsName,
            builder: (ctx, st) => SubtopicsPage(
              topicId: st.uri.queryParameters['topicId']!,
              topicName: st.uri.queryParameters['topicName']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.questions,
            name: AppRoutes.questionsName,
            builder: (ctx, st) => QuestionsPage(
              topicId: st.uri.queryParameters['topicId']!,
              subtopicId: st.uri.queryParameters['subtopicId']!,
              subtopicName: st.uri.queryParameters['subtopicName']!,
            ),
          ),
          GoRoute(
            path: AppRoutes.questionDetail,
            name: AppRoutes.questionDetailName,
            builder: (ctx, st) => QuestionDetailPage(
              id: st.uri.queryParameters['id']!,
              question: st.uri.queryParameters['q']!,
              answer: st.uri.queryParameters['a'] ?? '',
              topicName: st.uri.queryParameters['topicName'] ?? '',
              subtopicName: st.uri.queryParameters['subtopicName'] ?? '',
            ),
          ),
          GoRoute(
            path: AppRoutes.myQuestions,
            name: AppRoutes.myQuestionsName,
            builder: (ctx, st) => const MyQuestionsPage(),
          ),

          // مسار الإعدادات
          GoRoute(
            path: 'settings',
            name: 'settings',
            builder: (ctx, st) => const SettingsPage(),
          ),

          // مسار قارئ الكتب
          GoRoute(
            path: AppRoutes.bookReader,
            name: AppRoutes.bookReaderName,
            builder: (context, state) {
              final extra = state.extra;

              Map<String, dynamic> args;

              // 1. الحالة الأولى: قادم من المكتبة (Book object)
              if (extra is Book) {
                args = {
                  'book': extra,
                  'initialPage': 0, // ابدأ من المقدمة
                };
              }
              // 2. الحالة الثانية: قادم من البحث (Map)
              else if (extra is Map<String, dynamic>) {
                args = extra;
              }
              // 3. حالة خطأ (احتياط)
              else {
                throw Exception('Invalid arguments passed to BookReaderPage');
              }

              return BookReaderPage(args: args);
            },
          ),
        ],
      ),
    ],
  );
});