import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../constants/app_strings.dart';
import '../constants/app_colors.dart';
import '../constants/app_routes.dart';
import 'aboutpage.dart';
import '../../main.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authStateProvider).value;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final displayName = auth?.displayName ?? 'زائر';
    final email = auth?.email ?? '';

    return Drawer(
      backgroundColor: isDark
          ? AppColors.scaffoldBackgroundDark
          : Theme.of(context).scaffoldBackgroundColor,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ─── الهيدر الفاخر مع زخارف ───
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 28,
                bottom: 28,
                right: 24,
                left: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: AppColors.headerGradient,
                ),
              ),
              child: Stack(
                children: [
                  // زخارف هندسية
                  Positioned(
                    top: -20,
                    left: -10,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha:0.06),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -15,
                    right: -10,
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.gold.withValues(alpha:0.04),
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // الصورة الرمزية مع إطار ذهبي مزدوج
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.gold.withValues(alpha:0.5),
                              width: 2),
                          color: Colors.white.withValues(alpha:0.06),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha:0.1),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_rounded,
                            color: Colors.white70, size: 32),
                      ),
                      const SizedBox(height: 16),
                      // الاسم
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.5),
                            fontSize: 13,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      // خط ذهبي مزخرف
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.gold,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Transform.rotate(
                            angle: math.pi / 4,
                            child: Container(
                              width: 4,
                              height: 4,
                              color: AppColors.gold.withValues(alpha:0.6),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 12,
                            height: 1,
                            color: AppColors.gold.withValues(alpha:0.3),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── القائمة ───
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                children: [
                  _DrawerItem(
                    icon: Icons.question_answer_outlined,
                    title: AppStrings.myQuestions,
                    subtitle: 'عرض أسئلتك وأجوبتها',
                    onTap: () {
                      Navigator.pop(context);
                      context.goNamed(AppRoutes.myQuestionsName);
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    title: AppStrings.settings,
                    subtitle: 'المظهر وحجم الخط',
                    onTap: () {
                      Navigator.pop(context);
                      context.pushNamed('settings');
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: AppStrings.about,
                    subtitle: 'معلومات التطبيق',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AboutPage()),
                      );
                    },
                  ),
                  _DrawerItem(
                    icon: Icons.share_outlined,
                    title: AppStrings.shareApp,
                    subtitle: 'شارك التطبيق مع الآخرين',
                    onTap: () async {
                      const packageName =
                          "com.alialrikabi313.istftaatsanad";
                      final link =
                          "https://play.google.com/store/apps/details?id=$packageName";
                      await Share.share(
                          "جرّب تطبيق استفتاءات الشيخ السند: $link");
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 16,
                          height: 1,
                          color: AppColors.gold.withValues(alpha:0.3),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Divider(
                            color: isDark
                                ? AppColors.dividerDark
                                : AppColors.divider,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.logout_rounded,
                    title: AppStrings.signOut,
                    isDestructive: true,
                    onTap: () => _handleSignOut(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSignOut(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: const Text(
              AppStrings.confirmSignOut,
              style: TextStyle(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج؟',
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(AppStrings.cancel),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(AppStrings.signOut),
              ),
            ],
          ),
        );
      },
    );

    if (confirm == true) {
      final prefs = ref.read(sharedPrefsProvider);
      await prefs.setBool('isGuest', false);
      await prefs.remove('uid');
      await prefs.remove('email');
      await prefs.remove('name');
      await ref.read(authRepositoryProvider).signOut();
      if (context.mounted) context.goNamed(AppRoutes.signInName);
    }
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDestructive
                        ? AppColors.error.withValues(alpha:0.08)
                        : (isDark
                            ? AppColors.primary.withValues(alpha:0.15)
                            : AppColors.primary.withValues(alpha:0.06)),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(
                    icon,
                    color: color ?? AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontSize: 11,
                                    color: isDestructive
                                        ? AppColors.error.withValues(alpha:0.6)
                                        : null,
                                  ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isDestructive)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.gold.withValues(alpha:0.4),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
