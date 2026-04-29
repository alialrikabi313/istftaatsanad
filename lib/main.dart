import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/font_size_provider.dart';
import 'core/providers/palette_provider.dart';
import 'core/services/fcm_service.dart';
import 'core/services/observability.dart';
import 'firebase_options.dart';

/// مزود عام للـ SharedPreferences
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🟣 تهيئة Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 📊 Crashlytics + Analytics
  await Observability.init();

  // 🔔 FCM — حفظ التوكن على users/{uid}.fcmToken والاشتراك بالإشعارات
  await FcmService.instance.init();

  // ✅ ملاحظة: الفلترة المحلية للأسئلة المحذوفة تتم في Providers
  // (isDeleted != true && status != 'deleted')

  // 🟣 تهيئة SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
      ],
      child: const FatawaApp(),
    ),
  );
}

class FatawaApp extends ConsumerWidget {
  const FatawaApp({super.key});

  /// تطبيق حجم الخط على TextTheme بشكل آمن
  static TextTheme _applyFontSize(TextTheme textTheme, double fontSize) {
    if (fontSize == 1.0) {
      // إذا كان الحجم الافتراضي، لا حاجة للتعديل
      return textTheme;
    }
    
    // إنشاء TextTheme جديد مع تطبيق fontSizeFactor على كل TextStyle بشكل فردي
    return TextTheme(
      displayLarge: _applyFontSizeToStyle(textTheme.displayLarge, fontSize),
      displayMedium: _applyFontSizeToStyle(textTheme.displayMedium, fontSize),
      displaySmall: _applyFontSizeToStyle(textTheme.displaySmall, fontSize),
      headlineLarge: _applyFontSizeToStyle(textTheme.headlineLarge, fontSize),
      headlineMedium: _applyFontSizeToStyle(textTheme.headlineMedium, fontSize),
      headlineSmall: _applyFontSizeToStyle(textTheme.headlineSmall, fontSize),
      titleLarge: _applyFontSizeToStyle(textTheme.titleLarge, fontSize),
      titleMedium: _applyFontSizeToStyle(textTheme.titleMedium, fontSize),
      titleSmall: _applyFontSizeToStyle(textTheme.titleSmall, fontSize),
      bodyLarge: _applyFontSizeToStyle(textTheme.bodyLarge, fontSize),
      bodyMedium: _applyFontSizeToStyle(textTheme.bodyMedium, fontSize),
      bodySmall: _applyFontSizeToStyle(textTheme.bodySmall, fontSize),
      labelLarge: _applyFontSizeToStyle(textTheme.labelLarge, fontSize),
      labelMedium: _applyFontSizeToStyle(textTheme.labelMedium, fontSize),
      labelSmall: _applyFontSizeToStyle(textTheme.labelSmall, fontSize),
    );
  }

  /// تطبيق fontSizeFactor على TextStyle بشكل آمن
  static TextStyle? _applyFontSizeToStyle(TextStyle? style, double fontSize) {
    if (style == null) return null;
    
    // إذا كان fontSize موجوداً، نطبقه مباشرة
    if (style.fontSize != null) {
      return style.copyWith(fontSize: style.fontSize! * fontSize);
    }
    
    // إذا لم يكن fontSize موجوداً، نرجع style كما هو
    // (يجب أن يكون fontSize محدداً في AppTheme)
    return style;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);
    final fontSize = ref.watch(fontSizeProvider);
    final palette = ref.watch(paletteProvider);

    final lightTheme = AppTheme.light(palette);
    final darkTheme = AppTheme.dark();

    // تطبيق حجم الخط بشكل آمن - إنشاء TextTheme جديد مع تطبيق fontSizeFactor
    final lightTextTheme = _applyFontSize(lightTheme.textTheme, fontSize);
    final darkTextTheme = _applyFontSize(darkTheme.textTheme, fontSize);

    return MaterialApp.router(
      title: 'استفتاءات الشيخ السند',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: lightTheme.copyWith(
        textTheme: lightTextTheme,
      ),
      darkTheme: darkTheme.copyWith(
        textTheme: darkTextTheme,
      ),
      themeMode: themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}