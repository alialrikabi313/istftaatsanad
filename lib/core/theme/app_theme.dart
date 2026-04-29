import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sanad_ui/sanad_ui.dart';
import 'app_palette.dart';

/// ثيم Material 3 يقرأ من `AppPalette` المختارة في الإعدادات،
/// مع الحفاظ على الخط العربي والذهبي كهوية للعلامة.
class AppTheme {
  AppTheme._();

  static TextTheme _arabicTextTheme(TextTheme base, {required bool dark}) {
    final c = dark ? Colors.white : SanadColors.textPrimary;
    final c2 = dark ? Colors.white70 : SanadColors.textSecondary;
    final c3 = dark ? Colors.white60 : SanadColors.textSecondary;
    return GoogleFonts.tajawalTextTheme(base).copyWith(
      displayLarge: TextStyle(fontSize: 57, color: c, fontWeight: FontWeight.w300),
      displayMedium: TextStyle(fontSize: 45, color: c, fontWeight: FontWeight.w300),
      displaySmall: TextStyle(fontSize: 36, color: c, fontWeight: FontWeight.w400),
      headlineLarge: TextStyle(fontSize: 32, color: c, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(fontSize: 28, color: c, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(fontSize: 24, color: c, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(fontSize: 22, color: c, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(fontSize: 16, color: c, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(fontSize: 14, color: c, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(fontSize: 16, color: c, height: 1.6),
      bodyMedium: TextStyle(fontSize: 14, color: c2, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, color: c3, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, color: c, fontWeight: FontWeight.w500),
      labelMedium: TextStyle(fontSize: 12, color: c2, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(fontSize: 11, color: c3),
    ).apply(fontFamily: GoogleFonts.tajawal().fontFamily);
  }

  static ThemeData light([AppPalette palette = AppPalette.beige]) {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: palette.primary,
      scaffoldBackgroundColor: palette.scaffoldLight,
      dividerColor: palette.dividerLight,
    );
    return base.copyWith(
      textTheme: _arabicTextTheme(base.textTheme, dark: false),
      primaryTextTheme: _arabicTextTheme(base.primaryTextTheme, dark: false),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.borderLight, width: 1.2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: palette.borderLight, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: SanadColors.gold, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: palette.cardLight,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: SanadColors.textOnPrimary,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: palette.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: palette.borderLight, width: 0.8),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: SanadColors.gold,
        foregroundColor: SanadColors.primaryDeep,
        elevation: 4,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: palette.cardLight,
        selectedColor: SanadColors.gold.withValues(alpha: 0.15),
        side: BorderSide(color: palette.borderLight),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: palette.primaryDeep,
        contentTextStyle: const TextStyle(color: Colors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  static ThemeData dark() => SanadTheme.dark();
}
